#!/usr/bin/env python3

import warnings
# Suppress pkg_resources deprecation warning from Pyramid
warnings.filterwarnings("ignore", category=UserWarning, message=".*pkg_resources is deprecated.*")

import random
import datetime
import logging
import sqlite3
import json
import sys
import os
import inspect
import objects
import time
import hashlib
import csv
import io
import operator
import re
from zoneinfo import ZoneInfo

from waitress import serve
from pyramid.config import Configurator
from pyramid.events import NewRequest, subscriber, ApplicationCreated, NewResponse
from pyramid.exceptions import NotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.url import route_url
from pyramid.session import SignedCookieSessionFactory
from pyramid.view import view_config
from pyramid.response import Response
from pyramid.request import Request
try:
    from pyramid_mailer.message import Message
    from pyramid_mailer import get_mailer
    from pyramid_mailer.mailer import DummyMailer
except ImportError:
    pass

from auth.views import login, logout, redirect_guild_login
from auth.models import AuthUser
from sqlalchemy import engine_from_config
import pyramid.url
import pconf
import db

from slpp import slpp as lua

from get_request import get_request

from guild_profiles import BBC as gdata
#from guild_profiles import Akaviri as gdata

try:
    from random import SystemRandom
except ImportError:
    import random
else:
    random = SystemRandom()

logging.basicConfig()
log = logging.getLogger(__file__)

here = os.path.dirname(os.path.abspath(__file__))

CANONICAL_PUBLIC_HOST = "raffles.bbcguild.com"
PUBLIC_ALIAS_HOSTS = {"raffle.bbcguild.com", "tickets.bbcguild.com"}
ADMIN_HOST = "raffle-admin.bbcguild.com"
PRIZE_STYLE_CHOICES = {"standard", "featured", "grand", "jackpot"}
PRIZE_STYLE_ALIASES = {
    "flagship": "jackpot",
    "premier": "jackpot",
    "signature": "grand",
}


def safe_ticket_int(value):
    if value is None:
        return 0
    if isinstance(value, bool):
        return int(value)
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    text = str(value).strip()
    if not text:
        return 0
    text = text.replace(",", "")
    try:
        return int(text)
    except Exception:
        return 0

def current_auth_user_id(request):
    if request is None or getattr(request, "user", None) is None:
        return None
    try:
        return int(request.user.id)
    except Exception:
        return None


def ticket_totals_from_row(row):
    if not row:
        return 0, 0, 0
    paid = int(row["ticket_count"] or 0)
    free = int(row["ticket_free"] or 0)
    barter = int(row["ticket_barter"] or 0)
    return paid, free, barter


def parse_confirm_entry(line):
    parts = [p.strip() for p in str(line or "").split(",")]
    if len(parts) < 2:
        return None

    user = parts[0]
    if not user:
        return None

    def parse_int_at(idx):
        try:
            return int(parts[idx])
        except Exception:
            return 0

    paid = parse_int_at(1)
    barter = parse_int_at(2) if len(parts) >= 3 else 0
    total = parse_int_at(3) if len(parts) >= 4 else (paid + barter)
    return user, paid, barter, total


def normalize_prize_style(raw_style):
    style = (raw_style or "standard")
    if not isinstance(style, str):
        style = str(style)
    style = style.strip().lower()
    style = PRIZE_STYLE_ALIASES.get(style, style)
    if style not in PRIZE_STYLE_CHOICES:
        return "standard"
    return style

def request_host(request):
    host = (request.host or "").split(":", 1)[0].strip().lower()
    return host

def is_admin_host(request):
    return request_host(request) == ADMIN_HOST

def is_public_alias_host(request):
    return request_host(request) in PUBLIC_ALIAS_HOSTS

def is_fallback_host(request):
    host = request_host(request)
    return (
        host.endswith(".fly.dev")
        or host in {"localhost", "127.0.0.1"}
    )

def redirect_to_host(request, target_host, path=None, query_string=None):
    scheme = request.scheme or "https"
    path = path if path is not None else request.path
    query_string = request.query_string if query_string is None else query_string
    location = "%s://%s%s" % (scheme, target_host, path)
    if query_string:
        location += "?" + query_string
    return HTTPFound(location=location)

def guild_bonus_five (request):
    return False

    if request.matchdict:
        if "guild" in request.matchdict:
            g = request.matchdict["guild"].lower()
            if g == "exchange" or g == "imports":
                return True
            else:
                return False

def guild_bonus_two (request):
    if request.matchdict:
        if "guild" in request.matchdict:
            g = request.matchdict["guild"].lower()
            if g == "imports_whale":
                return True
            else:
                return False

def allowed_guilds (info, request):
    if "match" in info and "guild" in info["match"]:
        if info['match']['guild'].lower() in gdata.guilds:
            return True
        return False
    else:
        return True

def Result (res, flash=None):
    if flash is None:
        return {"result": res}
    
    return {"result": res, "flash": flash}

def get_select_guilds():
    cur = db.cursor()
    cur.execute("SELECT guild_id, guild_shortname, guild_name, guild_sister_guilds FROM guilds ORDER BY guild_id")
    return [dict(row) for row in cur.fetchall()]

@view_config(route_name="get_guild_choices", renderer="json", permission="admin_access")
def get_guild_choices(request):
    return {"guilds": get_select_guilds()}

def get_admin_guilds_for_user(user):
    guilds = get_select_guilds()
    if user is None:
        return []
    if user.has_global_role("superadmin"):
        return guilds
    return [
        guild for guild in guilds
        if user.has_guild_role("guild_admin", guild.get("guild_shortname"))
    ]

def get_visible_guilds_for_request(request):
    if request.user is not None and request.user.in_group("admin_access") and (is_admin_host(request) or is_fallback_host(request)):
        admin_guilds = get_admin_guilds_for_user(request.user)
        if admin_guilds:
            return admin_guilds
    return get_select_guilds()

def get_single_admin_guild_redirect(request):
    if request.user is None:
        return None
    if not request.user.in_group("admin_access"):
        return None
    if not (is_admin_host(request) or is_fallback_host(request)):
        return None
    if request.user.has_global_role("superadmin"):
        return None

    admin_guilds = get_admin_guilds_for_user(request.user)
    if len(admin_guilds) != 1:
        return None

    return HTTPFound(route_url('guild_landing', request, guild=admin_guilds[0]["guild_shortname"]))

@view_config(route_name='home', renderer="mako_templates/select.mako")
def home (request):
    if is_public_alias_host(request):
        return redirect_to_host(request, CANONICAL_PUBLIC_HOST)
    if is_admin_host(request) and request.user is None:
        return HTTPFound(location=request.route_url('apex_login'))
    guild_redirect = get_single_admin_guild_redirect(request)
    if guild_redirect is not None:
        return guild_redirect
    return {"guilds": get_visible_guilds_for_request(request)}

@view_config(route_name='health', renderer='json')
def health_check(request):
    """Health check endpoint for fly.io"""
    try:
        # Test database connection by checking if db file exists
        import dbconf
        import os
        db_exists = os.path.exists(dbconf.DATABASE)
        return {
            "status": "healthy",
            "database": "connected" if db_exists else "not_found",
            "timestamp": int(time.time())
        }
    except Exception as e:
        request.response.status_code = 503
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": int(time.time())
        }

@view_config(route_name='guild_landing_noslash', renderer="mako_templates/select.mako")
def landing_noslash (request):
    if is_public_alias_host(request):
        return redirect_to_host(request, CANONICAL_PUBLIC_HOST)
    if is_admin_host(request) and request.user is None:
        return HTTPFound(location=request.route_url('apex_login', _query={"came_from": request.current_route_url()}))
    guild_redirect = get_single_admin_guild_redirect(request)
    if guild_redirect is not None and "guild" not in request.matchdict:
        return guild_redirect
    if "guild" in request.matchdict:
        guild = request.matchdict["guild"]

        return HTTPFound(route_url('guild_landing', request, guild=guild))
    else:
        return {}

@view_config(route_name='guild_landing', renderer="mako_templates/index.mako")
@view_config(route_name='guild_landing_raffle', renderer="mako_templates/index.mako")
def landing (request):
    if is_public_alias_host(request):
        return redirect_to_host(request, CANONICAL_PUBLIC_HOST)

    # Auth system re-enabled - check for admin user
    # IMPORTANT: Do NOT force admin mode on archived raffle URLs.
    # Public/archive view for /{guild}/{raffle}/ should work even when logged in.
    is_archive_view = bool(request.matchdict and request.matchdict.get("raffle"))

    if is_admin_host(request) and request.user is None and not is_archive_view:
        return HTTPFound(location=request.route_url('apex_login', _query={"came_from": request.current_route_url()}))

    if request.user is not None:
        if request.user.in_group("admin_access") and not is_archive_view and (is_admin_host(request) or is_fallback_host(request)):
            request.override_renderer = "mako_templates/admin_index.mako"
        if gdata.extended:
            request.extended_tickets = True
        else:
            request.extended_tickets = False

    return {}


@view_config(route_name='raffle_lookup')
def raffle_lookup(request):
    if is_public_alias_host(request):
        return redirect_to_host(request, CANONICAL_PUBLIC_HOST)
    if is_admin_host(request) and request.user is None:
        return HTTPFound(location=request.route_url('apex_login', _query={"came_from": request.current_route_url()}))
    guild = request.matchdict.get("guild")
    raffle_code = request.params.get("raffle_lookup", "").strip()

    if not guild:
        return HTTPFound(route_url('home', request))

    if not raffle_code:
        return HTTPFound(route_url('guild_landing', request, guild=guild))

    resolved = db.resolve_raffle_lookup_code(raffle_code=raffle_code)

    if not resolved:
        return HTTPFound(route_url('guild_landing', request, guild=guild))

    return HTTPFound(route_url('guild_landing_raffle', request, guild=guild, raffle=resolved))

#------------- ALL THE API ------------#
# Both of these are admin functions
@view_config(route_name="get_guild_roster", renderer="json", permission="admin_access")
@view_config(route_name="get_guild_roster_id", renderer="json", permission="admin_access")
def get_guild_roster (request):
    roster = db.get_guild_roster()
    if roster:
        roster = roster.split(",")
    return roster

@view_config(route_name="set_guild_roster", renderer="json", permission="admin_access")
def set_guild_roster (request):
    # Do something here at some point

    return {"roster": True}

@view_config(route_name="set_guild_settings", renderer="json", permission="admin_access")
def set_guild_settings (request):
    guild = db.get_guild_by_id()
    if not guild:
        return json_error("Guild not found.")

    previous_shortname = str(guild["guild_shortname"] or "").strip().lower()
    guild_name = str(request.params.get("guild_name", guild["guild_name"]) or "").strip()
    guild_shortname = str(request.params.get("guild_shortname", guild["guild_shortname"]) or "").strip().lower()
    existing_eso_id = guild["guild_eso_id"] if "guild_eso_id" in guild.keys() else ""
    existing_expected_accounts = guild["guild_expected_mail_accounts"] if "guild_expected_mail_accounts" in guild.keys() else ""
    existing_import_blacklist = guild["guild_import_blacklist"] if "guild_import_blacklist" in guild.keys() else ""
    existing_timezone = guild["guild_timezone"] if "guild_timezone" in guild.keys() and guild["guild_timezone"] else DEFAULT_GUILD_DISPLAY_TIMEZONE
    existing_game_server = guild["guild_game_server"] if "guild_game_server" in guild.keys() and guild["guild_game_server"] else DEFAULT_GUILD_GAME_SERVER
    existing_logo_url = guild["guild_logo_url"] if "guild_logo_url" in guild.keys() and guild["guild_logo_url"] else DEFAULT_GUILD_LOGO_URL
    existing_favicon_url = guild["guild_favicon_url"] if "guild_favicon_url" in guild.keys() and guild["guild_favicon_url"] else DEFAULT_GUILD_FAVICON_URL
    existing_primary_color = guild["guild_primary_color"] if "guild_primary_color" in guild.keys() and guild["guild_primary_color"] else DEFAULT_GUILD_PRIMARY_COLOR
    existing_accent_color = guild["guild_accent_color"] if "guild_accent_color" in guild.keys() and guild["guild_accent_color"] else DEFAULT_GUILD_ACCENT_COLOR
    existing_sister_guilds = guild["guild_sister_guilds"] if "guild_sister_guilds" in guild.keys() else ""
    guild_eso_id = str(request.params.get("guild_eso_id", existing_eso_id) or "").strip()
    expected_accounts = parse_expected_mail_accounts(request.params.get("guild_expected_mail_accounts", existing_expected_accounts))
    import_blacklist = parse_import_blacklist(request.params.get("guild_import_blacklist", existing_import_blacklist))
    guild_timezone = str(request.params.get("guild_timezone", existing_timezone) or "").strip() or DEFAULT_GUILD_DISPLAY_TIMEZONE
    guild_game_server = str(request.params.get("guild_game_server", existing_game_server) or "").strip().upper() or DEFAULT_GUILD_GAME_SERVER
    guild_logo_url = str(request.params.get("guild_logo_url", existing_logo_url) or "").strip()
    guild_favicon_url = str(request.params.get("guild_favicon_url", existing_favicon_url) or "").strip()
    guild_primary_color = normalize_hex_color(request.params.get("guild_primary_color", existing_primary_color))
    guild_accent_color = normalize_hex_color(request.params.get("guild_accent_color", existing_accent_color))
    sister_guilds = parse_guild_shortname_list(request.params.get("guild_sister_guilds", existing_sister_guilds))

    if not guild_name:
        return json_error("Guild name is required.")
    if not guild_shortname:
        return json_error("Guild shortname is required.")
    if not re.match(r"^[a-z0-9_-]+$", guild_shortname):
        return json_error("Guild shortname may only use letters, numbers, dashes, and underscores.")
    existing_shortname_owner = db.get_guild_by_shortname(guild_shortname)
    if existing_shortname_owner and existing_shortname_owner["guild_id"] != guild["guild_id"]:
        return json_error("That guild shortname is already in use.")
    try:
        ZoneInfo(guild_timezone)
    except Exception:
        return json_error("Guild time zone must be a valid IANA zone like America/New_York.")
    if guild_game_server not in VALID_GUILD_GAME_SERVERS:
        return json_error("Please choose a valid game server.")
    if guild_primary_color is None:
        return json_error("Primary color must be a valid hex color like #284CA6.")
    if guild_accent_color is None:
        return json_error("Accent color must be a valid hex color like #5078D2.")
    valid_guild_shortnames = {row["guild_shortname"].lower() for row in get_select_guilds() if row.get("guild_shortname")}
    sister_guilds = [slug for slug in sister_guilds if slug != guild_shortname]
    invalid_sisters = [slug for slug in sister_guilds if slug not in valid_guild_shortnames]
    if invalid_sisters:
        return json_error("One or more sister guild links are invalid.")

    db.set_guild_settings(
        guild_name=guild_name,
        guild_shortname=guild_shortname,
        guild_eso_id=guild_eso_id,
        guild_expected_mail_accounts=",".join(expected_accounts),
        guild_import_blacklist=",".join(import_blacklist),
        guild_timezone=guild_timezone,
        guild_game_server=guild_game_server,
        guild_logo_url=guild_logo_url,
        guild_favicon_url=guild_favicon_url,
        guild_primary_color=guild_primary_color or DEFAULT_GUILD_PRIMARY_COLOR,
        guild_accent_color=guild_accent_color or DEFAULT_GUILD_ACCENT_COLOR,
        guild_sister_guilds=",".join(sister_guilds),
    )

    for row in get_select_guilds():
        row_shortname = str(row.get("guild_shortname") or "").strip().lower()
        if not row_shortname or row.get("guild_id") == guild["guild_id"]:
            continue

        current_links = parse_guild_shortname_list(row.get("guild_sister_guilds") or "")
        next_links = [slug for slug in current_links if slug not in {previous_shortname, guild_shortname}]
        if row_shortname in sister_guilds:
            next_links.append(guild_shortname)
        next_links = parse_guild_shortname_list(",".join(next_links))

        if next_links != current_links:
            db.set_guild_sister_guilds(target_guild_id=row["guild_id"], guild_sister_guilds=",".join(next_links))

    updated = db.get_guild_by_id()
    return json_ok(guild=dict(gget_guild_info(guild_data=updated)))
# Available to all
@view_config(route_name="get_current_raffle_info", renderer="json")
@view_config(route_name="get_current_raffle_info_id", renderer="json")
def get_current_raffle_info (request):
    info = db.get_cur_raffle_info()

    if not info:
        return {}

    info = merge_raffle_import_rule_state(info)
    info["raffle_title"] = (info.get("raffle_title") or "").strip()
    info["raffle_status"] = (info.get("raffle_status") or "LIVE").strip() or "LIVE"
    info["raffle_opened_at"] = int(info.get("raffle_opened_at") or 0)
    info["raffle_barter_enabled"] = int(info.get("raffle_barter_enabled") or 0)
    info["raffle_notes"] = info.get("raffle_notes") or ""
    info["raffle_notes_admin"] = info.get("raffle_notes_admin") or ""
    info["raffle_notes_public_2"] = info.get("raffle_notes_public_2") or ""
    return info

def parse_keys (cur, new, keys, builder):
    n = builder()

    if cur is None:
        cur = {}
    else:
        cur = dict(cur)

    for key in n.keys():
        if key in cur:
            n[key] = cur[key]

    for key in keys:
        if key not in n:
            continue

        if key in new:
            n[key] = new[key]

    return n

def normalize_raffle_status_value(status):
    value = (status or "LIVE").strip().upper()
    if value == "CLOSED":
        value = "COMPLETE"
    if value not in ("LIVE", "ROLLING", "COMPLETE"):
        value = "LIVE"
    return value

def parse_toggle_param(value, default=0):
    if value is None:
        return int(default)
    return 1 if str(value).strip().lower() in ("1", "true", "yes", "on") else 0

def get_raffle_import_rule_state(source):
    source = dict(source or {})
    legacy_barter_enabled = parse_toggle_param(source.get("raffle_barter_enabled"), 0)
    return {
        "raffle_gold_mail_enabled": parse_toggle_param(source.get("raffle_gold_mail_enabled"), 1),
        "raffle_gold_bank_enabled": parse_toggle_param(source.get("raffle_gold_bank_enabled"), 1),
        "raffle_barter_mail_enabled": parse_toggle_param(source.get("raffle_barter_mail_enabled"), legacy_barter_enabled),
        "raffle_barter_bank_enabled": parse_toggle_param(source.get("raffle_barter_bank_enabled"), legacy_barter_enabled),
    }

def merge_raffle_import_rule_state(target):
    target = dict(target or {})
    rule_state = get_raffle_import_rule_state(target)
    target.update(rule_state)
    target["raffle_barter_enabled"] = 1 if (rule_state["raffle_barter_mail_enabled"] or rule_state["raffle_barter_bank_enabled"]) else 0
    return target

def get_current_raffle_status():
    info = db.get_cur_raffle_info()
    if not info:
        return "LIVE"
    info = dict(info)
    return normalize_raffle_status_value(info.get("raffle_status"))

def json_error(message):
    return {"ok": False, "error": message}

def json_ok(**kwargs):
    payload = {"ok": True}
    payload.update(kwargs)
    return payload

def require_superadmin(request):
    if request.user is None or not (request.user.has_global_role("owner") or request.user.has_global_role("superadmin")):
        return json_error("Superadmin access is required for user management.")
    return None

def require_owner(request):
    if request.user is None or not request.user.has_global_role("owner"):
        return json_error("Owner access is required for that change.")
    return None

def serialize_auth_user(user_row):
    user_id = user_row["auth_id"]
    roles = db.get_auth_roles_for_user(user_id) or []
    return {
        "auth_id": user_id,
        "auth_name": user_row["auth_name"],
        "is_owner": any(r["auth_role"] == "owner" and r["auth_guild"] is None for r in roles),
        "is_superadmin": any(r["auth_role"] == "superadmin" and r["auth_guild"] is None for r in roles),
        "must_change_password": bool(user_row["auth_must_change_password"]) if "auth_must_change_password" in user_row.keys() else False,
        "guild_admins": sorted([
            (r["guild_shortname"] or "").lower()
            for r in roles
            if r["auth_role"] == "guild_admin" and r["guild_shortname"]
        ]),
        "auth_timezone": user_row["auth_timezone"] if "auth_timezone" in user_row.keys() else None,
        "auth_datetime_format": user_row["auth_datetime_format"] if "auth_datetime_format" in user_row.keys() and user_row["auth_datetime_format"] else DEFAULT_AUTH_DATETIME_FORMAT,
    }

def serialize_account_settings(user_row):
    return {
        "auth_timezone": user_row["auth_timezone"] if "auth_timezone" in user_row.keys() else None,
        "auth_datetime_format": user_row["auth_datetime_format"] if "auth_datetime_format" in user_row.keys() and user_row["auth_datetime_format"] else DEFAULT_AUTH_DATETIME_FORMAT,
    }

def validate_new_password(password, confirm_password):
    if len(password or "") < 8:
        return "Password must be at least 8 characters long."
    if password != confirm_password:
        return "New password and confirmation do not match."
    return None

def all_current_prizes_finalised():
    prizes = db.get_all_prizes()
    if not prizes:
        return False
    return all((dict(p).get("prize_finalised") or 0) != 0 for p in prizes)

def find_duplicate_raffle_number(guild_id, raffle_number, exclude_raffle_id=None):
    number = str(raffle_number or "").strip()
    if not guild_id or not number:
        return None
 
    cur = db.cursor()
    duplicate_id = db.get_raffle_id_by_number(cur, guild_id, number)
    if duplicate_id is None:
        return None

    if exclude_raffle_id is not None and int(duplicate_id) == int(exclude_raffle_id):
        return None

    return duplicate_id

# Admin only
@view_config(route_name="set_current_raffle_info", renderer="json", permission="admin_access")
def set_current_raffle_info (request):
    current_info = db.get_cur_raffle_info()
    if not current_info:
        return json_error("No active raffle found.")

    data = merge_raffle_import_rule_state(current_info)
    previous_barter_enabled = int(data.get("raffle_barter_enabled") or 0)
    data["raffle_guild_num"] = request.params.get("raffle_guild_num", data.get("raffle_guild_num", ""))
    data["raffle_time"] = request.params.get("raffle_time", data.get("raffle_time", ""))
    data["raffle_ticket_cost"] = request.params.get("raffle_ticket_cost", data.get("raffle_ticket_cost", ""))
    data["raffle_notes"] = request.params.get("raffle_notes", data.get("raffle_notes", ""))
    data["raffle_title"] = request.params.get("raffle_title", data.get("raffle_title", ""))
    current_status = normalize_raffle_status_value(data.get("raffle_status"))
    requested_status = request.params.get("raffle_status", data.get("raffle_status", "LIVE")) or "LIVE"
    data["raffle_status"] = normalize_raffle_status_value(requested_status)
    data["raffle_opened_at"] = int(data.get("raffle_opened_at") or 0)
    for field_name, default_value in (
        ("raffle_gold_mail_enabled", data.get("raffle_gold_mail_enabled", 1)),
        ("raffle_gold_bank_enabled", data.get("raffle_gold_bank_enabled", 1)),
        ("raffle_barter_mail_enabled", data.get("raffle_barter_mail_enabled", data.get("raffle_barter_enabled", 0))),
        ("raffle_barter_bank_enabled", data.get("raffle_barter_bank_enabled", data.get("raffle_barter_enabled", 0))),
    ):
        data[field_name] = parse_toggle_param(request.params.get(field_name, data.get(field_name, default_value)), default_value)
    data["raffle_barter_enabled"] = 1 if (data["raffle_barter_mail_enabled"] or data["raffle_barter_bank_enabled"]) else 0
    data["raffle_notes_admin"] = request.params.get("raffle_notes_admin", data.get("raffle_notes_admin", ""))
    data["raffle_notes_public_2"] = request.params.get("raffle_notes_public_2", data.get("raffle_notes_public_2", ""))

    duplicate_id = find_duplicate_raffle_number(data.get("raffle_guild"), data.get("raffle_guild_num"), data.get("raffle_id"))
    if duplicate_id is not None:
        return json_error('That raffle number already exists for this guild. Use a unique recovery suffix like "2614b" only if you are intentionally creating an emergency fallback raffle.')

    if current_status != "COMPLETE" and data["raffle_status"] == "COMPLETE" and not all_current_prizes_finalised():
        return json_error('All prizes must be locked before the raffle can be marked "COMPLETE".')

    cur = db.cursor()
    cur.execute(
        "UPDATE raffles SET raffle_guild=?, raffle_guild_num=?, raffle_opened_at=?, raffle_time=?, raffle_ticket_cost=?, raffle_closed=?, raffle_notes=?, raffle_title=?, raffle_status=?, raffle_barter_enabled=?, raffle_gold_mail_enabled=?, raffle_gold_bank_enabled=?, raffle_barter_mail_enabled=?, raffle_barter_bank_enabled=?, raffle_notes_admin=?, raffle_notes_public_2=? WHERE raffle_id=?",
        (
            data["raffle_guild"],
            data["raffle_guild_num"],
            data["raffle_opened_at"],
            data["raffle_time"],
            data["raffle_ticket_cost"],
            data["raffle_closed"],
            data["raffle_notes"],
            data["raffle_title"],
            data["raffle_status"],
            data["raffle_barter_enabled"],
            data["raffle_gold_mail_enabled"],
            data["raffle_gold_bank_enabled"],
            data["raffle_barter_mail_enabled"],
            data["raffle_barter_bank_enabled"],
            data["raffle_notes_admin"],
            data["raffle_notes_public_2"],
            data["raffle_id"],
        )
    )
    raffle_snapshot_items = []
    if data["raffle_barter_enabled"] and not previous_barter_enabled:
        raffle_snapshot_items = snapshot_guild_bounty_list_to_raffle(data["raffle_id"])
    return json_ok(
        raffle_guild_num=data["raffle_guild_num"],
        raffle_time=data["raffle_time"],
        raffle_ticket_cost=data["raffle_ticket_cost"],
        raffle_title=data["raffle_title"],
        raffle_status=data["raffle_status"],
        raffle_barter_enabled=data["raffle_barter_enabled"],
        raffle_gold_mail_enabled=data["raffle_gold_mail_enabled"],
        raffle_gold_bank_enabled=data["raffle_gold_bank_enabled"],
        raffle_barter_mail_enabled=data["raffle_barter_mail_enabled"],
        raffle_barter_bank_enabled=data["raffle_barter_bank_enabled"],
        raffle_bounty_items=raffle_snapshot_items,
    )

@view_config(route_name="set_current_raffle_notes", renderer="json", permission="admin_access")
def set_current_raffle_notes(request):
    current_info = db.get_cur_raffle_info()
    if not current_info:
        return json_error("No active raffle found.")

    data = dict(current_info)
    data["raffle_notes"] = request.params.get("raffle_notes", data.get("raffle_notes", ""))
    data["raffle_notes_admin"] = request.params.get("raffle_notes_admin", data.get("raffle_notes_admin", ""))
    data["raffle_notes_public_2"] = request.params.get("raffle_notes_public_2", data.get("raffle_notes_public_2", ""))

    cur = db.cursor()
    cur.execute(
        "UPDATE raffles SET raffle_notes=?, raffle_notes_admin=?, raffle_notes_public_2=? WHERE raffle_id=?",
        (
            data["raffle_notes"],
            data["raffle_notes_admin"],
            data["raffle_notes_public_2"],
            data["raffle_id"],
        )
    )

    return json_ok()

@view_config(route_name="close_current_raffle", renderer="json", permission="admin_access")
def close_current_raffle (request):
    return {}

@view_config(route_name="open_new_raffle", renderer="json", permission="admin_access")
def open_new_raffle (request):
    cur_id = db.get_cur_raffle_id()
    current_info = db.get_cur_raffle_info()
    current_info = dict(current_info) if current_info else {}
    requested_number = (request.params.get("raffle_guild_num") or "").strip()
    clone_prizes = str(request.params.get("clone_prizes", "")).strip().lower() in ("1", "true", "yes", "on")
    guild_info = db.get_guild_by_shortname(request.matchdict["guild"])
    guild_id = guild_info[0] if guild_info else None

    if get_current_raffle_status() != "COMPLETE":
        return json_error('Set the raffle status to "COMPLETE" before opening a new raffle.')

    duplicate_id = find_duplicate_raffle_number(guild_id, requested_number)
    if duplicate_id is not None:
        return json_error('That raffle number already exists for this guild. If this is an intentional emergency recovery raffle, use a unique suffix like "2614b".')

    new_raffle_info = {
        "raffle_guild_num": requested_number or 0,
        "raffle_opened_at": int(time.time()),
        "raffle_time": request.params.get("raffle_time", current_info.get("raffle_time", "Fill this in!")),
        "raffle_ticket_cost": request.params.get("raffle_ticket_cost", current_info.get("raffle_ticket_cost", "1000g")),
        "raffle_closed": 0,
        "raffle_notes": request.params.get("raffle_notes", ""),
        "raffle_title": request.params.get("raffle_title", ""),
        "raffle_status": (request.params.get("raffle_status") or "LIVE").strip() or "LIVE",
        "raffle_gold_mail_enabled": parse_toggle_param(request.params.get("raffle_gold_mail_enabled", 1), 1),
        "raffle_gold_bank_enabled": parse_toggle_param(request.params.get("raffle_gold_bank_enabled", 1), 1),
        "raffle_barter_mail_enabled": parse_toggle_param(request.params.get("raffle_barter_mail_enabled", 0), 0),
        "raffle_barter_bank_enabled": parse_toggle_param(request.params.get("raffle_barter_bank_enabled", 0), 0),
        "raffle_notes_admin": request.params.get("raffle_notes_admin", ""),
        "raffle_notes_public_2": request.params.get("raffle_notes_public_2", "")
    }
    new_raffle_info["raffle_barter_enabled"] = 1 if (new_raffle_info["raffle_barter_mail_enabled"] or new_raffle_info["raffle_barter_bank_enabled"]) else 0

    db.close_raffle_by_id(cur_id)
    
    if db.create_new_raffle(new_raffle_info):
        new_raffle_id = db.get_cur_raffle_id()
        if new_raffle_info["raffle_barter_enabled"] and new_raffle_id:
            snapshot_guild_bounty_list_to_raffle(new_raffle_id)
        if clone_prizes and cur_id and new_raffle_id:
            if not db.clone_prizes_to_raffle(source_raffle_id=cur_id, target_raffle_id=new_raffle_id):
                return json_error("New raffle created, but prize cards could not be cloned.")
        return json_ok()

    return json_error("Unable to create the new raffle.")

@view_config(route_name="get_auth_users", renderer="json", permission="admin_access")
def get_auth_users(request):
    auth_error = require_superadmin(request)
    if auth_error:
        return auth_error

    users = [serialize_auth_user(row) for row in (db.get_all_auth_users() or [])]
    return json_ok(users=users, guilds=get_select_guilds())

@view_config(route_name="get_barter_bounty_list", renderer="json", permission="admin_access")
def get_barter_bounty_list(request):
    items = [serialize_barter_bounty_item(row) for row in (db.get_barter_bounty_items() or [])]
    return json_ok(items=items)

@view_config(route_name="get_current_raffle_bounty_list", renderer="json")
def get_current_raffle_bounty_list(request):
    current_info = db.get_cur_raffle_info()
    if not current_info:
        return json_ok(raffle_barter_enabled=0, items=[])

    raffle = merge_raffle_import_rule_state(current_info)
    raffle_id = raffle.get("raffle_id")
    barter_enabled = int(raffle.get("raffle_barter_enabled") or 0)
    items = []
    if barter_enabled:
        items = [serialize_barter_bounty_item(row) for row in (db.get_barter_bounty_items() or [])]
    return json_ok(
        raffle_barter_enabled=barter_enabled,
        raffle_id=raffle_id,
        raffle_guild_num=str(raffle.get("raffle_guild_num") or ""),
        raffle_title=str(raffle.get("raffle_title") or ""),
        items=items,
    )

@view_config(route_name="get_current_barter_summary", renderer="json", permission="admin_access")
def get_current_barter_summary(request):
    current_info = db.get_cur_raffle_info()
    if not current_info:
        return json_ok(rows=[], totals={"total_bartered": 0, "total_row_value": 0, "total_tickets": 0})

    raffle = dict(current_info)
    rows = [serialize_barter_summary_row(row) for row in (db.get_barter_summary() or [])]
    total_bartered = sum(int(row.get("total_bartered") or 0) for row in rows)
    total_row_value = sum(int(row.get("total_row_value") or 0) for row in rows)
    total_tickets = sum(int(row.get("total_tickets") or 0) for row in rows)

    return json_ok(
        raffle_guild_num=str(raffle.get("raffle_guild_num") or ""),
        raffle_title=str(raffle.get("raffle_title") or ""),
        rows=rows,
        totals={
            "total_bartered": total_bartered,
            "total_row_value": total_row_value,
            "total_tickets": total_tickets,
        },
    )

@view_config(route_name="set_barter_bounty_list", renderer="json", permission="admin_access")
def set_barter_bounty_list(request):
    raw_payload = request.params.get("items_json", "").strip()
    if not raw_payload:
        items = []
    else:
        try:
            items = json.loads(raw_payload)
        except Exception:
            return json_error("Bounty list payload was not valid JSON.")

    if not isinstance(items, list):
        return json_error("Bounty list payload must be a list.")

    normalized = []
    seen_codes = set()
    for index, item in enumerate(items, start=1):
        if not isinstance(item, dict):
            return json_error("Each bounty list row must be an object.")
        item_name = str(item.get("item_name") or "").strip()
        item_code = str(item.get("item_code") or "").strip()
        if not item_name:
            return json_error(f"Row {index}: Item name is required.")
        if not item_code:
            return json_error(f"Row {index}: Item code is required.")
        normalized_code = item_code.lower()
        if normalized_code in seen_codes:
            return json_error(f"Row {index}: Item code {item_code} is duplicated.")
        seen_codes.add(normalized_code)
        try:
            quantity = parse_nonnegative_int(item.get("quantity"), 1)
            item_value = parse_nonnegative_int(item.get("item_value"), 0)
            barter_rate = parse_nonnegative_int(item.get("barter_rate"), 0)
        except Exception:
            return json_error(f"Row {index}: Quantity, item value, and barter rate must be non-negative whole numbers.")
        if quantity <= 0:
            return json_error(f"Row {index}: Quantity must be at least 1.")
        normalized.append({
            "item_name": item_name,
            "item_code": item_code,
            "quantity": quantity,
            "item_value": item_value,
            "barter_rate": barter_rate,
            "active": 1,
        })

    db.replace_barter_bounty_items(items=normalized)
    saved_items = [serialize_barter_bounty_item(row) for row in (db.get_barter_bounty_items() or [])]
    return json_ok(items=saved_items)

@view_config(route_name="create_auth_user", renderer="json", permission="admin_access")
def create_auth_user(request):
    auth_error = require_superadmin(request)
    if auth_error:
        return auth_error

    username = (request.params.get("auth_name") or "").strip()
    password = request.params.get("auth_password") or ""
    confirm_password = request.params.get("auth_password_confirm") or ""
    is_superadmin = str(request.params.get("is_superadmin", "")).strip().lower() in ("1", "true", "yes", "on")
    guild_admins_raw = (request.params.get("guild_admins") or "").strip()
    guild_admin_slugs = sorted({slug.strip().lower() for slug in guild_admins_raw.split(",") if slug.strip()})

    if not username:
        return json_error("Username is required.")
    password_error = validate_new_password(password, confirm_password)
    if password_error:
        return json_error(password_error)
    if AuthUser.find_by_name(username):
        return json_error("That username already exists.")
    if is_superadmin and require_owner(request):
        return json_error("Only the owner can create another superadmin.")

    user = AuthUser()
    user.name = username
    user.password = password
    user.must_change_password = True
    user.save()
    created = AuthUser.find_by_name(username)
    if not created:
        return json_error("Unable to create that user.")

    if is_superadmin:
        db.add_auth_role_to_user(created.id, "superadmin")

    for slug in guild_admin_slugs:
        guild = db.get_guild_by_shortname(slug)
        if guild:
            db.add_auth_role_to_user(created.id, "guild_admin", guild["guild_id"])

    return json_ok(user=serialize_auth_user(db.get_auth_user_by_id(created.id)))

@view_config(route_name="set_auth_user_roles", renderer="json", permission="admin_access")
def set_auth_user_roles(request):
    auth_error = require_superadmin(request)
    if auth_error:
        return auth_error

    try:
        user_id = int(request.params.get("auth_id") or 0)
    except Exception:
        user_id = 0
    if not user_id:
        return json_error("Missing user id.")

    user_row = db.get_auth_user_by_id(user_id)
    if not user_row:
        return json_error("User not found.")

    is_superadmin = str(request.params.get("is_superadmin", "")).strip().lower() in ("1", "true", "yes", "on")
    guild_admins_raw = (request.params.get("guild_admins") or "").strip()
    desired_guild_admins = sorted({slug.strip().lower() for slug in guild_admins_raw.split(",") if slug.strip()})

    current_roles = db.get_auth_roles_for_user(user_id) or []
    current_guild_admins = {
        (role["guild_shortname"] or "").lower(): role["auth_guild"]
        for role in current_roles
        if role["auth_role"] == "guild_admin" and role["guild_shortname"]
    }
    target_is_owner = any(role["auth_role"] == "owner" and role["auth_guild"] is None for role in current_roles)
    currently_superadmin = any(role["auth_role"] == "superadmin" and role["auth_guild"] is None for role in current_roles)
    acting_is_owner = request.user is not None and request.user.has_global_role("owner")

    if target_is_owner and (request.user is None or int(request.user.id) != user_id):
        return json_error("The owner account cannot be changed by another user.")

    if not acting_is_owner and currently_superadmin != is_superadmin:
        return json_error("Only the owner can change superadmin access.")

    if currently_superadmin and not is_superadmin:
        superadmin_count = int(db.count_auth_roles("superadmin") or 0)
        if superadmin_count <= 1:
            return json_error("At least one superadmin must remain.")
        if request.user and int(request.user.id) == user_id:
            return json_error("Use another superadmin account before removing your own superadmin access.")

    if is_superadmin:
        db.add_auth_role_to_user(user_id, "superadmin")
    else:
        db.remove_auth_role_from_user(user_id, "superadmin")

    for slug, guild_id in current_guild_admins.items():
        if slug not in desired_guild_admins:
            db.remove_auth_role_from_user(user_id, "guild_admin", guild_id)

    for slug in desired_guild_admins:
        guild = db.get_guild_by_shortname(slug)
        if guild:
            db.add_auth_role_to_user(user_id, "guild_admin", guild["guild_id"])

    return json_ok(user=serialize_auth_user(db.get_auth_user_by_id(user_id)))

@view_config(route_name="delete_auth_user", renderer="json", permission="admin_access")
def delete_auth_user(request):
    auth_error = require_superadmin(request)
    if auth_error:
        return auth_error

    try:
        user_id = int(request.params.get("auth_id") or 0)
    except Exception:
        user_id = 0
    if not user_id:
        return json_error("Missing user id.")

    user_row = db.get_auth_user_by_id(user_id)
    if not user_row:
        return json_error("User not found.")
    if request.user and int(request.user.id) == user_id:
        return json_error("You cannot delete the account you are currently using.")

    current_roles = db.get_auth_roles_for_user(user_id) or []
    currently_superadmin = any(role["auth_role"] == "superadmin" and role["auth_guild"] is None for role in current_roles)
    if currently_superadmin:
        superadmin_count = int(db.count_auth_roles("superadmin") or 0)
        if superadmin_count <= 1:
            return json_error("At least one superadmin must remain.")
    if any(role["auth_role"] == "owner" and role["auth_guild"] is None for role in current_roles):
        return json_error("The owner account cannot be deleted.")

    db.delete_auth_user(user_id)
    return json_ok(deleted_auth_id=user_id)

@view_config(route_name="reset_auth_user_password", renderer="json", permission="admin_access")
def reset_auth_user_password(request):
    auth_error = require_superadmin(request)
    if auth_error:
        return auth_error

    try:
        user_id = int(request.params.get("auth_id") or 0)
    except Exception:
        user_id = 0
    if not user_id:
        return json_error("Missing user id.")

    user_row = db.get_auth_user_by_id(user_id)
    if not user_row:
        return json_error("User not found.")

    new_password = request.params.get("auth_password") or ""
    confirm_password = request.params.get("auth_password_confirm") or ""
    password_error = validate_new_password(new_password, confirm_password)
    if password_error:
        return json_error(password_error)

    user = AuthUser.find_by_id(user_id)
    if not user:
        return json_error("User not found.")
    user.password = new_password
    db.update_auth_user_password(user_id, user.password, True)
    return json_ok(user=serialize_auth_user(db.get_auth_user_by_id(user_id)))

@view_config(route_name="change_own_password", renderer="json", permission="authenticated")
def change_own_password(request):
    if request.user is None:
        return json_error("You must be logged in.")

    current_password = request.params.get("current_password") or ""
    new_password = request.params.get("new_password") or ""
    confirm_password = request.params.get("confirm_password") or ""

    if not request.user.check(current_password):
        return json_error("Current password is incorrect.")

    password_error = validate_new_password(new_password, confirm_password)
    if password_error:
        return json_error(password_error)

    user = AuthUser.find_by_id(request.user.id)
    if not user:
        return json_error("User not found.")
    user.password = new_password
    db.update_auth_user_password(user.id, user.password, False)
    return json_ok()

@view_config(route_name="get_own_account_settings", renderer="json", permission="authenticated")
def get_own_account_settings(request):
    if request.user is None:
        return json_error("You must be logged in.")

    user_row = db.get_auth_user_by_id(request.user.id)
    if not user_row:
        return json_error("User not found.")

    return json_ok(settings=serialize_account_settings(user_row))

@view_config(route_name="set_own_account_settings", renderer="json", permission="authenticated")
def set_own_account_settings(request):
    if request.user is None:
        return json_error("You must be logged in.")

    timezone_value = str(request.params.get("auth_timezone", "") or "").strip()
    datetime_format = str(request.params.get("auth_datetime_format", "") or "").strip().lower() or DEFAULT_AUTH_DATETIME_FORMAT

    if timezone_value and timezone_value != "browser":
        try:
            ZoneInfo(timezone_value)
        except Exception:
            return json_error("Choose a valid time zone.")
    else:
        timezone_value = None

    if datetime_format not in VALID_AUTH_DATETIME_FORMATS:
        return json_error("Choose a valid date/time format.")

    if not db.update_auth_user_preferences(request.user.id, timezone_value, datetime_format):
        return json_error("Unable to save account settings right now.")

    user_row = db.get_auth_user_by_id(request.user.id)
    if not user_row:
        return json_error("User not found.")

    return json_ok(settings=serialize_account_settings(user_row))

# For everyone!
@view_config(route_name="get_all_tickets", renderer="json")
@view_config(route_name="get_all_tickets_id", renderer="json")
def get_all_tickets (request):
    return make_all_tickets(request)

@view_config(route_name="get_extended_tickets", renderer="json")
@view_config(route_name="get_extended_tickets_id", renderer="json")
def get_extended_tickets (request):
    return make_all_tickets(request, True)

def build_ticket_ranges_by_user(request, ticket_rows):
    if not ticket_rows:
        return {}

    tno = 1
    ranges_by_user = {}

    for ticket_row in [dict(x) for x in ticket_rows]:
        user_name = ticket_row.get("ticket_user_name")
        if not user_name:
            continue

        ticket_count = safe_ticket_int(ticket_row.get("ticket_count"))
        ticket_barter = safe_ticket_int(ticket_row.get("ticket_barter"))
        total = ticket_count + ticket_barter

        if guild_bonus_five(request):
            if total % 5 == 0:
                total = total + int(total / 5)
        elif guild_bonus_two(request):
            if total % 2 == 0:
                total = total + int(total / 2)

        if total <= 0:
            continue

        start = tno
        end = tno + total - 1
        range_text = str(start) if start == end else f"{start}-{end}"
        ranges_by_user.setdefault(user_name, []).append(range_text)
        tno = end + 1

    return {
        user_name: ", ".join(user_ranges)
        for user_name, user_ranges in ranges_by_user.items()
    }

def make_all_tickets (request, extended=False):
    tickets = db.get_tickets()

    if not tickets:
        return []

    data = [dict(x) for x in tickets]
    ticket_ranges_by_user = build_ticket_ranges_by_user(request, tickets)

    res = []

    build = []

    for i in data:
        ticket_count = safe_ticket_int(i.get("ticket_count"))
        ticket_barter = safe_ticket_int(i.get("ticket_barter"))
        if ticket_count != 0 or ticket_barter != 0:
            i["ticket_count"] = ticket_count
            i["ticket_barter"] = ticket_barter
            build.append(i)

    data = sorted(build, key=lambda x: x["ticket_user_name"].lower())

    for i in range(len(data)):
        d = data[i]
        ticket_count = safe_ticket_int(d.get("ticket_count"))
        barter_val = safe_ticket_int(d.get("ticket_barter"))
        total = ticket_count + barter_val

        if total == 0:
            continue

        if extended:
            new = [i+1, d["ticket_user_name"], total, ticket_count, barter_val, ticket_ranges_by_user.get(d["ticket_user_name"], "")]
        else:
            new = [i+1, d["ticket_user_name"], total]

        res.append(new)

    return res

@view_config(route_name="export_csv")
def export_csv (request):
    data = [dict(x) for x in db.get_tickets()]

    build = []

    for i in data:
        ticket_count = safe_ticket_int(i.get("ticket_count"))
        barter_val = safe_ticket_int(i.get("ticket_barter"))
        if ticket_count != 0 or barter_val != 0:
            i["ticket_count"] = ticket_count
            i["ticket_barter"] = barter_val
            i["ticket_user_name"] = i["ticket_user_name"].replace('"', "'")
            build.append(i)

    f = io.StringIO()
    writer = csv.writer(f, delimiter="\t", quotechar="'", quoting=csv.QUOTE_MINIMAL)
    for i in sorted(build, key=operator.itemgetter("ticket_user_name")):
        ticket_count = safe_ticket_int(i.get("ticket_count"))
        barter_val = safe_ticket_int(i.get("ticket_barter"))
        total = ticket_count + barter_val
        writer.writerow([i["ticket_user_name"], "note", total])

    f.seek(0)
    res = f.read()
    f.close()

    headers = request.response.headers
    headers['Content-Type'] = "text/csv"
    headers['Content-Disposition'] = "attachment; filename=raffle_export.txt"

    request.response.text = res

    return request.response

@view_config(route_name="set_all_tickets", renderer="json", permission="admin_access")
def set_all_tickets (request):
    try:
        if not request.json_body:
            return False
    except AttributeError:
        return False

    reference = db.get_tickets()

    to_update = []

    for row in request.json_body:
        if not row:
            continue

        u_name, u_count = None, None

        if hasattr(row, "get"):
            u_name = row.get("1", None)
            u_count = row.get("2", None)
        elif isinstance(row, list):
            u_name = row[1] if len(row) > 1 else None
            u_count = row[2] if len(row) > 2 else None

        if u_name is None or u_count is None:
            continue

        found_name = False

        for t in reference:
            if t["ticket_user_name"] == u_name:
                found_name = True
                if t["ticket_count"] != u_count:
                    to_update.append((u_name, u_count))

        if found_name == False:
            to_update.append((u_name, u_count))

    cur = db.cursor()
    change_count = 0
    updater_auth_id = current_auth_user_id(request)

    for u in to_update:
        if db.set_user_tickets(user_name=u[0], ticket_count=u[1], updated_by_auth=updater_auth_id):
            change_count = change_count + 1

    return change_count

@view_config(route_name="set_extended_tickets", renderer="json", permission="admin_access")
def set_extended_tickets (request):
    try:
        if not request.json_body:
            return False
    except AttributeError:
        return False

    reference = db.get_tickets()

    to_update = []

    for row in request.json_body:
        if not row:
            continue

        u_name, u_count, u_free, u_barter = None, None, 0, None

        if hasattr(row, "get"):
            u_name = row.get("1", None)
            u_count = row.get("3", None)
            u_barter = row.get("4", None)
        elif isinstance(row, list):
            u_name = row[1] if len(row) > 1 else None
            u_count = row[3] if len(row) > 3 else None
            u_barter = row[4] if len(row) > 4 else None

        if u_name is None or u_count is None:
            continue

        if u_barter is None or u_barter == "":
            u_barter = 0

        found_name = False

        for t in reference:
            if t["ticket_user_name"] == u_name:
                found_name = True
                if t["ticket_count"] != u_count or t["ticket_free"] != u_free or t["ticket_barter"] != u_barter:
                    to_update.append((u_name, u_count, u_free, u_barter))

        if found_name == False:
            to_update.append((u_name, u_count, u_free, u_barter))

    cur = db.cursor()
    change_count = 0
    updater_auth_id = current_auth_user_id(request)

    for u in to_update:
        if db.set_user_tickets(user_name=u[0], ticket_count=u[1], ticket_free=u[2], ticket_barter=u[3], updated_by_auth=updater_auth_id):
            change_count = change_count + 1

    return change_count

def make_ticket_list (request):
    ticks = db.get_tickets()

    if not ticks:
        return []

    data = [dict(x) for x in ticks]

    tno = 1 # starting ticket number

    res = []

    for user in data:
        cu = gdata.prefix + user["ticket_user_name"]

        count = safe_ticket_int(user.get("ticket_count"))
        barter = safe_ticket_int(user.get("ticket_barter"))

        total = count + barter

        if guild_bonus_five(request):
            if total % 5 == 0:
                total = total + int(total / 5)
        elif guild_bonus_two(request):
            if total % 2 == 0:
                total = total + int(total / 2)
        for i in range(total):
            res.append([tno, cu])
            tno = tno + 1
    return res

@view_config(route_name="get_ticket_list", renderer="json")
@view_config(route_name="get_ticket_list_id", renderer="json")
def get_ticket_list (request):
    return make_ticket_list(request)

def build_import_summary(total_added, new_participants, existing_participants):
    return {
        "total_added": int(total_added or 0),
        "new_participants": int(new_participants or 0),
        "existing_participants": int(existing_participants or 0),
    }


DEFAULT_MAIL_IMPORT_EXPECTED_ACCOUNTS = {
    "bbc1": ["@bbcguild"],
    "bbc2": ["@raftix"],
}
DEFAULT_GUILD_DISPLAY_TIMEZONE = "America/New_York"
DEFAULT_GUILD_GAME_SERVER = "PC-NA"
DEFAULT_GUILD_LOGO_URL = "https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif"
DEFAULT_GUILD_FAVICON_URL = "/static/favicon-256.png"
DEFAULT_GUILD_PRIMARY_COLOR = "#284CA6"
DEFAULT_GUILD_ACCENT_COLOR = "#5078D2"
DEFAULT_AUTH_DATETIME_FORMAT = "us_12"
VALID_GUILD_GAME_SERVERS = {
    "PC-NA",
    "PC-EU",
    "XBOX-NA",
    "XBOX-EU",
    "PS-NA",
    "PS-EU",
}
VALID_AUTH_DATETIME_FORMATS = {"us_12", "us_24", "intl_12", "intl_24"}


def get_expected_mail_import_accounts(guild_slug):
    guild_row = db.get_guild_by_shortname(guild_slug)
    if guild_row:
        configured = str((guild_row["guild_expected_mail_accounts"] if "guild_expected_mail_accounts" in guild_row.keys() else "") or "").strip()
        if configured:
            return [account.strip() for account in configured.split(",") if account.strip()]

    expected_accounts = {
        slug: list(accounts)
        for slug, accounts in DEFAULT_MAIL_IMPORT_EXPECTED_ACCOUNTS.items()
    }

    raw = os.getenv("MAIL_IMPORT_EXPECTED_ACCOUNTS_JSON", "").strip()
    if raw:
        try:
            loaded = json.loads(raw)
            if isinstance(loaded, dict):
                for slug, accounts in loaded.items():
                    if not isinstance(slug, str):
                        continue
                    if isinstance(accounts, str):
                        accounts = [accounts]
                    if isinstance(accounts, list):
                        expected_accounts[slug.lower()] = [
                            str(account).strip()
                            for account in accounts
                            if str(account).strip()
                        ]
        except Exception:
            pass

    return expected_accounts.get((guild_slug or "").lower(), [])


def get_import_blacklist(guild_slug):
    guild_row = db.get_guild_by_shortname(guild_slug)
    if not guild_row:
        return []
    configured = guild_row["guild_import_blacklist"] if "guild_import_blacklist" in guild_row.keys() else ""
    return parse_import_blacklist(configured)


def extract_import_export_metadata(account_data):
    export_metadata = account_data.get("export_metadata", {})
    if not isinstance(export_metadata, dict):
        export_metadata = {}

    mail_metadata = export_metadata.get("mail", {})
    bank_metadata = export_metadata.get("bank", {})

    if not isinstance(mail_metadata, dict):
        mail_metadata = {}
    if not isinstance(bank_metadata, dict):
        bank_metadata = {}

    return {
        "mail": mail_metadata,
        "bank": bank_metadata,
    }


def normalize_import_guild_identity(name):
    value = str(name or "").strip().lower()
    if not value:
        return ""

    value = re.sub(r"\bcompany\b", "co", value)
    value = re.sub(r"\bcorporation\b", "corp", value)
    value = re.sub(r"[^a-z0-9]+", " ", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value


def parse_expected_mail_accounts(raw):
    if raw is None:
        return []
    return [account.strip() for account in str(raw).split(",") if account.strip()]

def normalize_import_account_name(raw):
    value = str(raw or "").strip()
    if not value:
        return ""
    return value.lstrip("@").strip().lower()

def parse_import_blacklist(raw):
    if raw is None:
        return []
    values = []
    seen = set()
    for item in str(raw).split(","):
        normalized = normalize_import_account_name(item)
        if normalized and normalized not in seen:
            values.append(normalized)
            seen.add(normalized)
    return values

def parse_guild_shortname_list(raw):
    if raw is None:
        return []
    values = []
    seen = set()
    for item in str(raw).split(","):
        shortname = str(item or "").strip().lower()
        if shortname and shortname not in seen:
            values.append(shortname)
            seen.add(shortname)
    return values

def normalize_hex_color(raw_value):
    value = str(raw_value or "").strip()
    if not value:
        return ""
    if not value.startswith("#"):
        value = "#" + value
    if not re.match(r"^#[0-9a-fA-F]{6}$", value):
        return None
    return value.upper()

def parse_nonnegative_int(raw_value, default_value=0):
    value = str(raw_value if raw_value is not None else "").strip()
    if value == "":
        return default_value
    value = value.replace(",", "")
    parsed = int(value)
    if parsed < 0:
        raise ValueError("must be non-negative")
    return parsed

def serialize_barter_bounty_item(row):
    data = dict(row)
    return {
        "barter_bounty_item_id": data.get("barter_bounty_item_id"),
        "item_name": str(data.get("barter_bounty_item_name") or ""),
        "item_code": str(data.get("barter_bounty_item_code") or ""),
        "quantity": int(data.get("barter_bounty_quantity") or 0),
        "item_value": int(data.get("barter_bounty_value") or 0),
        "barter_rate": int(data.get("barter_bounty_rate") or 0),
        "sort_order": int(data.get("barter_bounty_sort") or 0),
        "active": int(data.get("barter_bounty_active") or 0),
    }

def serialize_raffle_bounty_item(row):
    data = dict(row)
    return {
        "raffle_bounty_item_id": data.get("raffle_bounty_item_id"),
        "source_item_id": data.get("raffle_bounty_source_item"),
        "item_name": str(data.get("raffle_bounty_item_name") or ""),
        "item_code": str(data.get("raffle_bounty_item_code") or ""),
        "quantity": int(data.get("raffle_bounty_quantity") or 0),
        "item_value": int(data.get("raffle_bounty_value") or 0),
        "barter_rate": int(data.get("raffle_bounty_rate") or 0),
        "sort_order": int(data.get("raffle_bounty_sort") or 0),
    }

def serialize_barter_summary_row(row):
    data = dict(row)
    return {
        "item_name": str(data.get("barter_entry_item_name") or ""),
        "item_code": str(data.get("barter_entry_item_code") or ""),
        "total_bartered": int(data.get("total_bartered") or 0),
        "total_row_value": int(data.get("total_row_value") or 0),
        "total_tickets": int(data.get("total_tickets") or 0),
    }

def snapshot_guild_bounty_list_to_raffle(raffle_id):
    if not raffle_id:
        return []

    guild_items = [serialize_barter_bounty_item(row) for row in (db.get_barter_bounty_items() or [])]
    db.replace_raffle_bounty_items(raffle_id=raffle_id, items=guild_items)
    return [serialize_raffle_bounty_item(row) for row in (db.get_raffle_bounty_items(raffle_id=raffle_id) or [])]

def get_or_backfill_current_raffle_bounty_items(raffle_id, barter_enabled):
    if not barter_enabled or not raffle_id:
        return []

    items = [serialize_raffle_bounty_item(row) for row in (db.get_raffle_bounty_items(raffle_id=raffle_id) or [])]
    if items:
        return items

    return snapshot_guild_bounty_list_to_raffle(raffle_id)

def build_live_bounty_match_map():
    items = [serialize_barter_bounty_item(row) for row in (db.get_barter_bounty_items() or [])]
    by_code = {}
    for item in items:
        raw_code = str(item.get("item_code") or "").strip()
        normalized_codes = normalize_barter_item_code_candidates(raw_code)
        if not normalized_codes:
            continue
        for code in normalized_codes:
            by_code[code] = item
    return by_code

def normalize_barter_item_code_candidates(raw_code):
    code = str(raw_code or "").strip()
    if not code:
        return []

    normalized = []
    lowered = code.lower()
    normalized.append(lowered)

    item_link_match = re.search(r"item:(\d+)", lowered)
    if item_link_match:
        normalized.append(item_link_match.group(1))

    plain_id_match = re.fullmatch(r"\d+", code)
    if plain_id_match:
        normalized.append(plain_id_match.group(0))

    # Preserve order but remove duplicates.
    return list(dict.fromkeys([entry for entry in normalized if entry]))

def calculate_barter_ticket_count(quantity, bounty_item):
    quantity = int(quantity or 0)
    required_qty = int(bounty_item.get("quantity") or 0)
    barter_rate = int(bounty_item.get("barter_rate") or 0)
    if quantity <= 0 or required_qty <= 0 or barter_rate <= 0:
        return 0
    return (quantity // required_qty) * barter_rate

def extract_barter_items_from_record(line, source_type, uid, timestamp, bounty_map):
    raw_items = line.get("barter_items")
    if raw_items is None:
        raw_items = line.get("items")
    if raw_items is None:
        raw_items = line.get("attachments")

    if isinstance(raw_items, dict):
        raw_items = normalize_lua_table_records(raw_items)
    elif not isinstance(raw_items, list):
        return [], 0, 0

    accepted = []
    total_tickets = 0
    total_value = 0

    for item in raw_items:
        if not isinstance(item, dict):
            continue
        item_code = str(item.get("item_code") or item.get("code") or "").strip()
        match = None
        for candidate_code in normalize_barter_item_code_candidates(item_code):
            match = bounty_map.get(candidate_code)
            if match:
                break
        if not match:
            continue

        try:
            quantity = parse_nonnegative_int(item.get("quantity", item.get("quant", 0)), 0)
        except Exception:
            continue

        awarded_tickets = calculate_barter_ticket_count(quantity, match)
        if awarded_tickets <= 0:
            continue

        item_value = int(match.get("item_value") or 0) * quantity
        accepted.append({
            "source_type": source_type,
            "source_uid": uid,
            "source_timestamp": int(timestamp or 0) if str(timestamp or "").strip() else 0,
            "item_name": str(match.get("item_name") or item.get("item_name") or item.get("name") or "").strip(),
            "item_code": item_code,
            "quantity": quantity,
            "item_value": item_value,
            "barter_rate": int(match.get("barter_rate") or 0),
            "awarded_tickets": awarded_tickets,
        })
        total_tickets += awarded_tickets
        total_value += item_value

    return accepted, total_tickets, total_value

def format_import_timestamp(timestamp, timezone_name=DEFAULT_GUILD_DISPLAY_TIMEZONE):
    try:
        timestamp = int(timestamp)
    except (TypeError, ValueError):
        return ""

    try:
        tzinfo = ZoneInfo(timezone_name or DEFAULT_GUILD_DISPLAY_TIMEZONE)
    except Exception:
        tzinfo = ZoneInfo(DEFAULT_GUILD_DISPLAY_TIMEZONE)

    dt = datetime.datetime.fromtimestamp(timestamp, tzinfo)
    hour = dt.hour % 12 or 12
    am_pm = "AM" if dt.hour < 12 else "PM"
    tz_label = dt.tzname() or ""
    rendered = f"{dt.month}/{dt.day}/{dt.year} {hour}:{dt.minute:02d}:{dt.second:02d} {am_pm}"
    if tz_label:
        rendered += f" {tz_label}"
    return rendered

def normalize_preview_barter_item(item):
    if not isinstance(item, dict):
        return None

    item_name = str(item.get("item_name") or item.get("name") or "").strip()
    item_code = str(item.get("item_code") or item.get("code") or "").strip()
    source_type = str(item.get("source_type") or "").strip()
    source_uid = str(item.get("source_uid") or "").strip()
    try:
        quantity = parse_nonnegative_int(item.get("quantity", item.get("quant", 0)), 0)
        item_value = parse_nonnegative_int(item.get("item_value", item.get("value", 0)), 0)
        barter_rate = parse_nonnegative_int(item.get("barter_rate", item.get("rate", 0)), 0)
        awarded_tickets = parse_nonnegative_int(item.get("awarded_tickets", item.get("ticket_count", 0)), 0)
        source_timestamp = parse_nonnegative_int(item.get("source_timestamp", item.get("timestamp", 0)), 0)
    except Exception:
        return None

    if not item_name and not item_code:
        return None

    return {
        "item_name": item_name,
        "item_code": item_code,
        "quantity": quantity,
        "item_value": item_value,
        "barter_rate": barter_rate,
        "awarded_tickets": awarded_tickets,
        "source_type": source_type,
        "source_uid": source_uid,
        "source_timestamp": source_timestamp,
    }

def build_preview_row(name, paid_tickets, barter_tickets, subject, timestamp, uid, source_type=None, barter_items=None):
    paid_tickets = int(paid_tickets or 0)
    barter_tickets = int(barter_tickets or 0)
    normalized_items = []
    if isinstance(barter_items, list):
        normalized_items = [item for item in (normalize_preview_barter_item(x) for x in barter_items) if item]

    return {
        "name": str(name or "").strip(),
        "paid_tickets": paid_tickets,
        "barter_tickets": barter_tickets,
        "total_tickets": paid_tickets + barter_tickets,
        "subject": str(subject or "").strip(),
        "timestamp": timestamp,
        "uid": str(uid or "").strip(),
        "source_type": str(source_type or "").strip(),
        "barter_items": normalized_items,
    }

def get_preview_row_name(row):
    if isinstance(row, dict):
        return str(row.get("name") or "")
    return str(row[0] if len(row) > 0 else "")

def get_preview_row_paid_tickets(row):
    if isinstance(row, dict):
        return int(row.get("paid_tickets") or 0)
    return int(row[1] if len(row) > 1 else 0)

def get_preview_row_barter_tickets(row):
    if isinstance(row, dict):
        return int(row.get("barter_tickets") or 0)
    return 0

def get_preview_row_total_tickets(row):
    if isinstance(row, dict):
        return int(row.get("total_tickets") or 0)
    return int(row[1] if len(row) > 1 else 0)

def get_preview_row_subject(row):
    if isinstance(row, dict):
        return str(row.get("subject") or "")
    return str(row[2] if len(row) > 2 else "")

def get_preview_row_timestamp(row):
    if isinstance(row, dict):
        return row.get("timestamp")
    return row[3] if len(row) > 3 else ""

def get_preview_row_uid(row):
    if isinstance(row, dict):
        return str(row.get("uid") or "")
    return str(row[4] if len(row) > 4 else "")

@view_config(route_name="barter_import", renderer="json", permission="admin_access")
def barter_import (request):
    if "barter_import_string" not in request.params:
        return {}

    data = request.params["barter_import_string"]
    confirm_data = request.params.get("barter_confirm_string", "")

    confirms = {}
    updater_auth_id = current_auth_user_id(request)

    for line in confirm_data.split("|"):
        parsed = parse_confirm_entry(line)
        if not parsed:
            continue
        user, paid_amount, barter_amount, total_after = parsed
        confirms[user] = [paid_amount, barter_amount, total_after]

    lines = data.split("\n")

    names = []
    confirm = ""

    barter_data = {}
    total_added = 0
    new_participants = 0
    existing_participants = 0

    for line in lines:
        if line.count("\t") != 1:
            continue

        user, amount = line.split("\t")

        user = user.replace("@", "").strip()

        try:
            amount = int(amount)
        except:
            continue

        if user in barter_data:
            barter_data[user] = barter_data[user] + amount
        else:
            barter_data[user] = amount

    for user, amount in barter_data.items():
        u = db.get_user_tickets(user)

        if u:
            prev_tickets, free_tickets, bart_tickets = ticket_totals_from_row(u)
        else:
            prev_tickets = 0
            free_tickets = 0
            bart_tickets = 0

        added_amount = amount
        previous_total = prev_tickets + free_tickets + bart_tickets
        new_barter_total = bart_tickets + added_amount

        db.set_user_tickets(
            user_name=user,
            ticket_count=prev_tickets,
            ticket_free=free_tickets,
            ticket_barter=new_barter_total,
            updated_by_auth=updater_auth_id
        )

        if added_amount != 0:
            total_added = total_added + added_amount
            if previous_total > 0:
                existing_participants = existing_participants + 1
            else:
                new_participants = new_participants + 1
            new_total = prev_tickets + free_tickets + new_barter_total
            if user in confirms:
                confirms[user][1] = confirms[user][1] + added_amount
                confirms[user][2] = new_total
            else:
                confirms[user] = [0, added_amount, new_total]

    for k, v in confirms.items():
        confirm = confirm + "%s,%s,%s,%s|" % (k, v[0], v[1], v[2])
        names.append("@%s" % k)

    return {
        "confirm_string": confirm,
        "confirm_names": ", ".join(names),
        "import_summary": build_import_summary(total_added, new_participants, existing_participants),
    }

@view_config(route_name="paid_import", renderer="json", permission="admin_access")
def paid_import (request):
    """Import paid tickets - adds imported paid tickets to existing paid tickets"""
    if "paid_import_string" not in request.params:
        return {}

    data = request.params["paid_import_string"]
    confirm_data = request.params.get("paid_confirm_string", "")

    confirms = {}
    updater_auth_id = current_auth_user_id(request)

    for line in confirm_data.split("|"):
        parsed = parse_confirm_entry(line)
        if not parsed:
            continue
        user, paid_amount, barter_amount, total_after = parsed
        confirms[user] = [paid_amount, barter_amount, total_after]

    lines = data.split("\n")

    names = []
    confirm = ""

    paid_data = {}
    total_added = 0
    new_participants = 0
    existing_participants = 0

    for line in lines:
        if line.count("\t") != 1:
            continue

        user, amount = line.split("\t")

        user = user.replace("@", "").strip()

        try:
            amount = int(amount)
        except:
            continue

        if user in paid_data:
            paid_data[user] = paid_data[user] + amount
        else:
            paid_data[user] = amount

    for user, amount in paid_data.items():
        u = db.get_user_tickets(user)

        if u:
            prev_tickets, free_tickets, bart_tickets = ticket_totals_from_row(u)
        else:
            prev_tickets = 0
            free_tickets = 0
            bart_tickets = 0

        added_amount = amount
        previous_total = prev_tickets + free_tickets + bart_tickets
        new_paid_total = prev_tickets + added_amount

        db.set_user_tickets(
            user_name=user,
            ticket_count=new_paid_total,
            ticket_free=free_tickets,
            ticket_barter=bart_tickets,
            updated_by_auth=updater_auth_id
        )

        if added_amount != 0:
            total_added = total_added + added_amount
            if previous_total > 0:
                existing_participants = existing_participants + 1
            else:
                new_participants = new_participants + 1
            new_total = new_paid_total + free_tickets + bart_tickets
            if user in confirms:
                confirms[user][0] = confirms[user][0] + added_amount
                confirms[user][2] = new_total
            else:
                confirms[user] = [added_amount, 0, new_total]

    for k, v in confirms.items():
        confirm = confirm + "%s,%s,%s,%s|" % (k, v[0], v[1], v[2])
        names.append("@%s" % k)

    return {
        "confirm_string": confirm,
        "confirm_names": ", ".join(names),
        "import_summary": build_import_summary(total_added, new_participants, existing_participants),
    }

# No reason for any of the next ones to be allowed

def normalize_lua_table_records(section):
    """
    Normalize decoded Lua table data so import code can safely handle:
    - missing sections
    - empty Lua tables decoded as []
    - dict-style keyed tables
    - list-style tables
    """
    if not section:
        return []

    if isinstance(section, dict):
        return [v for _, v in sorted(section.items(), key=lambda item: item[0]) if isinstance(v, dict)]

    if isinstance(section, list):
        return [v for v in section if isinstance(v, dict)]

    return []


def strip_non_import_lua_fields(raw_text):
    """
    Some ESO SavedVariables strings, especially the mail receipt body template,
    can be written as multi-line quoted strings that the lightweight Lua parser
    chokes on. Those fields are irrelevant for ticket imports, so strip them
    from a retry parse path.
    """
    lines = raw_text.splitlines()
    cleaned_lines = []
    skipping_body = False

    for line in lines:
        if not skipping_body and re.match(r'^\s*\["body"\]\s*=', line):
            indent = re.match(r'^(\s*)', line).group(1)
            cleaned_lines.append(f'{indent}["body"] = "",')
            if re.match(r'^\s*\["body"\]\s*=\s*".*",\s*$', line):
                skipping_body = False
            else:
                skipping_body = True
            continue

        if skipping_body:
            if re.match(r'^\s*\["[^"]+"\]\s*=', line):
                skipping_body = False
                cleaned_lines.append(line)
            continue

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines)


@view_config(route_name="import_tickets", renderer="json", permission="admin_access")
def import_tickets (request):
    if "file" not in request.POST:
        return {}

    ginfo = db.get_guild_by_id()
    gid = ginfo[0]
    guild_slug = (ginfo["guild_shortname"] or "").lower()
    guild_name = ginfo["guild_name"] or guild_slug

    t_cost = db.get_guild_ticket_cost()
    if not t_cost:
        t_cost = 1000
    else:
        if "g" in t_cost.lower() or "k" in t_cost.lower():
            t_cost = t_cost.lower().strip("gk")
        
        try:
            t_cost = int(t_cost)
        except:
            t_cost = 1000

    f = request.POST['file']

    if not hasattr(f, "file"):
        return {}

    if not f.filename or not f.filename.endswith(".lua") or "RaffleManager" not in f.filename:
        return {}

    raffle_file = ""
    f.file.seek(0)

    while True:
        data = f.file.read(8192)
        if not data:
            break

        # Handle bytes properly
        if isinstance(data, bytes):
            data = data.decode('utf-8')
        raffle_file = raffle_file + data

    raffle_file = raffle_file.splitlines()
    if not raffle_file[0].startswith("RaffleManager_SavedVariables"):
        return {}

    raffle_file = "\n".join(raffle_file[1:])

    try:
        data = lua.decode(raffle_file)
    except Exception:
        try:
            data = lua.decode(strip_non_import_lua_fields(raffle_file))
        except Exception:
            return {}

    data = data["Default"]

    timestamp_keys = []

    for k, v in data.items():
        if "$AccountWide" in v:
            v = v["$AccountWide"]

        ts = v.get("timestamp", 0)

        timestamp_keys.append((ts, k))

    timestamp_keys.sort()

    key = timestamp_keys[-1][1]
    selected_account = key

    if key not in data:
        return {}

    data = data[key]

    if "$AccountWide" in data:
        data = data["$AccountWide"]
    else:
        return {}

    bank_data = normalize_lua_table_records(data.get("bank_data", {}))
    mail_data = normalize_lua_table_records(data.get("mail_data", {}))
    export_metadata = extract_import_export_metadata(data)
    bank_metadata = export_metadata["bank"]
    mail_metadata = export_metadata["mail"]
    import_context = {
        "selected_account": selected_account,
        "metadata_detected": bool(mail_metadata or bank_metadata),
        "mail_row_count": len(mail_data),
        "bank_row_count": len(bank_data),
        "mail_source_account": str(mail_metadata.get("source_account", "")).strip(),
        "bank_source_guild_name": str(bank_metadata.get("source_guild_name", "")).strip(),
        "bank_source_guild_id": str(bank_metadata.get("source_guild_id", "")).strip(),
        "bank_selected_days": bank_metadata.get("selected_days", ""),
        "addon_mail_barter_enabled": parse_toggle_param(mail_metadata.get("barter_enabled"), 0),
        "addon_bank_barter_enabled": parse_toggle_param(bank_metadata.get("barter_enabled"), 0),
    }
    current_raffle_info = db.get_cur_raffle_info()
    raffle_rules = merge_raffle_import_rule_state(current_raffle_info) if current_raffle_info else get_raffle_import_rule_state({})
    import_context["raffle_import_rules"] = dict(raffle_rules)
    barter_enabled = bool(raffle_rules["raffle_barter_mail_enabled"] or raffle_rules["raffle_barter_bank_enabled"])
    bounty_map = build_live_bounty_match_map()

    potential_tickets = []
    warnings = []
    import_blacklist = set(get_import_blacklist(guild_slug))
    skipped_blacklist_mail = 0
    skipped_blacklist_bank = 0
    skipped_blacklist_names = []
    suppressed_counts = {
        "mail_gold": 0,
        "bank_gold": 0,
        "mail_barter": 0,
        "bank_barter": 0,
    }

    source_bank_guild_name = str(bank_metadata.get("source_guild_name", "")).strip()
    bank_matches_current_guild = True

    if source_bank_guild_name:
        bank_matches_current_guild = (
            normalize_import_guild_identity(source_bank_guild_name)
            == normalize_import_guild_identity(guild_name)
        )

    if bank_data and not bank_matches_current_guild:
        warning_guild = source_bank_guild_name or "another guild"
        warnings.append("Warning: This import contains deposits from a different guild: %s. They will not be processed." % warning_guild)
    else:
        for line in bank_data:
            uid = line.get("id")
            user = str(line.get("user", "")).lstrip("@")
            timestamp = line.get("timestamp")
            amount = line.get("amount", 0)
            normalized_user = normalize_import_account_name(user)

            if not uid or not user or timestamp is None:
                continue
            if normalized_user and normalized_user in import_blacklist:
                skipped_blacklist_bank += 1
                if user not in skipped_blacklist_names:
                    skipped_blacklist_names.append(user)
                continue

            try:
                timestamp = int(timestamp)
            except (TypeError, ValueError):
                continue

            r = db.get_import_by_id(uid, gid)
            if r:
                continue

            try:
                amount = int(amount)
            except (TypeError, ValueError):
                amount = 0

            paid_tickets = 0
            if amount > 0 and amount % t_cost == 0:
                paid_tickets = int(amount / t_cost)
            if paid_tickets > 0 and not raffle_rules["raffle_gold_bank_enabled"]:
                suppressed_counts["bank_gold"] += paid_tickets
                paid_tickets = 0

            barter_items = []
            barter_tickets = 0
            if raffle_rules["raffle_barter_bank_enabled"]:
                barter_items, barter_tickets, _ = extract_barter_items_from_record(line, "BANK", uid, timestamp, bounty_map)
            else:
                suppressed_items, suppressed_barter_tickets, _ = extract_barter_items_from_record(line, "BANK", uid, timestamp, bounty_map)
                if suppressed_barter_tickets > 0:
                    suppressed_counts["bank_barter"] += suppressed_barter_tickets

            if paid_tickets <= 0 and barter_tickets <= 0:
                continue

            potential_tickets.append(build_preview_row(user, paid_tickets, barter_tickets, "GUILD BANK DEPOSIT", timestamp, uid, source_type="BANK", barter_items=barter_items))

    expected_mail_accounts = get_expected_mail_import_accounts(guild_slug)
    source_mail_account = str(mail_metadata.get("source_account", "")).strip()
    if source_mail_account and expected_mail_accounts:
        normalized_source = source_mail_account.lower()
        normalized_expected = [account.lower() for account in expected_mail_accounts]
        if normalized_source not in normalized_expected:
            warnings.append(
                "Warning: This mail export was scraped from %s, but %s normally expects mail imports from %s. Review carefully before importing." % (
                    source_mail_account,
                    guild_name,
                    " or ".join(expected_mail_accounts),
                )
            )

    for line in mail_data:
        uid = line.get("id")
        user = str(line.get("user", "")).lstrip("@")
        subject = line.get("subject", "")
        amount = line.get("amount", 0)
        timestamp = line.get("timestamp")
        normalized_user = normalize_import_account_name(user)

        if not uid or not user:
            continue
        if normalized_user and normalized_user in import_blacklist:
            skipped_blacklist_mail += 1
            if user not in skipped_blacklist_names:
                skipped_blacklist_names.append(user)
            continue

        try:
            amount = int(amount)
        except (TypeError, ValueError):
            amount = 0

        r = db.get_import_by_id(uid, gid)
        if r:
            continue

        paid_tickets = 0
        if amount > 0 and amount % t_cost == 0:
            paid_tickets = int(amount / t_cost)
        if paid_tickets > 0 and not raffle_rules["raffle_gold_mail_enabled"]:
            suppressed_counts["mail_gold"] += paid_tickets
            paid_tickets = 0

        barter_items = []
        barter_tickets = 0
        if raffle_rules["raffle_barter_mail_enabled"]:
            barter_items, barter_tickets, _ = extract_barter_items_from_record(line, "MAIL", uid, timestamp, bounty_map)
        else:
            suppressed_items, suppressed_barter_tickets, _ = extract_barter_items_from_record(line, "MAIL", uid, timestamp, bounty_map)
            if suppressed_barter_tickets > 0:
                suppressed_counts["mail_barter"] += suppressed_barter_tickets
        if paid_tickets <= 0 and barter_tickets <= 0:
            continue
        potential_tickets.append(build_preview_row(user, paid_tickets, barter_tickets, subject, timestamp, uid, source_type="MAIL", barter_items=barter_items))

    total_blacklist_skips = skipped_blacklist_mail + skipped_blacklist_bank
    if total_blacklist_skips:
        labels = []
        if skipped_blacklist_mail:
            labels.append("%s mail" % skipped_blacklist_mail)
        if skipped_blacklist_bank:
            labels.append("%s bank" % skipped_blacklist_bank)
        warning = "Ignored %s transaction%s from blacklisted name%s" % (
            ", ".join(labels),
            "" if total_blacklist_skips == 1 else "s",
            "" if len(skipped_blacklist_names) == 1 else "s",
        )
        if skipped_blacklist_names:
            warning += ": " + ", ".join("@%s" % str(name).lstrip("@") for name in skipped_blacklist_names[:6])
            if len(skipped_blacklist_names) > 6:
                warning += ", ..."
        warning += "."
        warnings.append(warning)

    import_context["suppressed_counts"] = dict(suppressed_counts)
    import_context["has_any_suppressed"] = any(int(value or 0) > 0 for value in suppressed_counts.values())

    if suppressed_counts["mail_gold"] > 0:
        warnings.append("Warning: Gold-Mail is OFF for this raffle. %s eligible mail-gold ticket%s were ignored." % (
            f"{suppressed_counts['mail_gold']:,}",
            "" if suppressed_counts["mail_gold"] == 1 else "s",
        ))
    if suppressed_counts["bank_gold"] > 0:
        warnings.append("Warning: Gold-Bank is OFF for this raffle. %s eligible bank-gold ticket%s were ignored." % (
            f"{suppressed_counts['bank_gold']:,}",
            "" if suppressed_counts["bank_gold"] == 1 else "s",
        ))
    if suppressed_counts["mail_barter"] > 0:
        warnings.append("Warning: Barter-Mail is OFF for this raffle. %s eligible mail-barter ticket%s were ignored." % (
            f"{suppressed_counts['mail_barter']:,}",
            "" if suppressed_counts["mail_barter"] == 1 else "s",
        ))
    if suppressed_counts["bank_barter"] > 0:
        warnings.append("Warning: Barter-Bank is OFF for this raffle. %s eligible bank-barter ticket%s were ignored." % (
            f"{suppressed_counts['bank_barter']:,}",
            "" if suppressed_counts["bank_barter"] == 1 else "s",
        ))

    addon_mismatch_labels = []
    if import_context["addon_mail_barter_enabled"] != int(raffle_rules["raffle_barter_mail_enabled"]):
        addon_mismatch_labels.append("Barter-Mail")
    if import_context["addon_bank_barter_enabled"] != int(raffle_rules["raffle_barter_bank_enabled"]):
        addon_mismatch_labels.append("Barter-Bank")
    if addon_mismatch_labels:
        warnings.append("Warning: Addon settings and settings for this raffle do not match for %s." % ", ".join(addon_mismatch_labels))

    return {
        "rows": potential_tickets,
        "warnings": warnings,
        "export_metadata": export_metadata,
        "import_context": import_context,
    }

@view_config(route_name="import_tickets2", renderer="json", permission="admin_access")
def import_tickets2 (request):
    import logging
    logger = logging.getLogger(__name__)
    logger.info("import_tickets2 called")
    logger.info("Request params: %s", dict(request.params))
    updater_auth_id = current_auth_user_id(request)
    
    grouped_rows = {}

    # Rebuild rows by explicit row index instead of relying on request param order.
    for key, item in request.params.items():
        match = re.match(r"^row(\d+)_(.+)$", str(key))
        if not match:
            continue
        row_index = int(match.group(1))
        grouped_rows.setdefault(row_index, []).append((key, item))

    rows = [grouped_rows[index] for index in sorted(grouped_rows.keys())]

    ginfo = db.get_guild_by_shortname(request.matchdict["guild"])

    guild = ginfo[1]
    guild_id = ginfo[0]

    # sanitize data, discard non-required pieces
    new_rows = []

    for row in rows:
        this_row = {}
        for k, v in row:
            key_parts = k.split("_", 1)
            if len(key_parts) != 2:
                continue
            this_row[key_parts[1]] = v

        try:
            this_row["paid_tickets"] = parse_nonnegative_int(this_row.get("paid_tickets", this_row.get("amount", 0)), 0)
        except Exception:
            this_row["paid_tickets"] = 0
        try:
            this_row["barter_tickets"] = parse_nonnegative_int(this_row.get("barter_tickets", 0), 0)
        except Exception:
            this_row["barter_tickets"] = 0
        barter_items_json = str(this_row.get("barter_items_json") or "").strip()
        if barter_items_json:
            try:
                loaded_items = json.loads(barter_items_json)
            except Exception:
                loaded_items = []
        else:
            loaded_items = []
        this_row["barter_items"] = [item for item in (normalize_preview_barter_item(x) for x in loaded_items) if item]
        computed_barter_tickets = 0
        for barter_item in this_row["barter_items"]:
            try:
                computed_barter_tickets += int(barter_item.get("awarded_tickets") or 0)
            except Exception:
                continue
        if computed_barter_tickets != int(this_row.get("barter_tickets") or 0):
            logger.warning(
                "Import preview mismatch for uid=%s user=%s: visible barter_tickets=%s hidden barter_items total=%s",
                this_row.get("uid"),
                this_row.get("name"),
                this_row.get("barter_tickets"),
                computed_barter_tickets,
            )

        if this_row.get("confirmed", False):
            new_rows.append(this_row)
        else:
            db.record_import(this_row["uid"], int(time.time()), 1, guild_id)

    uids = []

    # final pass, convert data to a dictionary, collapsing multi-deposit tickets into one

    data = {}

    for row in new_rows:
        db.record_import(row["uid"], int(time.time()), 0, guild_id)

        existing = data.get(row["name"])
        if not existing:
            existing = {
                "paid_tickets": 0,
                "barter_tickets": 0,
                "barter_items": [],
            }
            data[row["name"]] = existing

        existing["paid_tickets"] += int(row.get("paid_tickets") or 0)
        existing["barter_tickets"] += int(row.get("barter_tickets") or 0)
        existing["barter_items"].extend(row.get("barter_items") or [])

    # actually set tickets!


    confirms = ""

    names = []
    total_added = 0
    new_participants = 0
    existing_participants = 0

    for user_name, ticket_info in data.items():
        names.append("@"+user_name)
        paid_tickets = int(ticket_info.get("paid_tickets") or 0)
        barter_tickets_to_add = int(ticket_info.get("barter_tickets") or 0)

        u = db.get_user_tickets(user_name)
        if u:
            prev_tickets, free_tickets, existing_barter_tickets = ticket_totals_from_row(u)
        else:
            prev_tickets = 0
            free_tickets = 0
            existing_barter_tickets = 0

        previous_total = prev_tickets + free_tickets + existing_barter_tickets

        #if not isinstance(free_tickets, int):
        #    free_tickets = 0
        #if not isinstance(barter_tickets, int):
        #    barter_tickets = 0

        db.set_user_tickets(
            user_name,
            prev_tickets + paid_tickets,
            free_tickets,
            existing_barter_tickets + barter_tickets_to_add,
            updated_by_auth=updater_auth_id
        )

        added_total = paid_tickets + barter_tickets_to_add
        new_total = prev_tickets + paid_tickets + free_tickets + existing_barter_tickets + barter_tickets_to_add
        if added_total != 0:
            total_added = total_added + added_total
            if previous_total > 0:
                existing_participants = existing_participants + 1
            else:
                new_participants = new_participants + 1

        confirms = confirms + "%s,%s,%s,%s|" % (user_name, paid_tickets, barter_tickets_to_add, new_total)

        for barter_item in ticket_info.get("barter_items") or []:
            db.record_barter_entry(
                user_name=user_name,
                source_type=barter_item.get("source_type") or "MAIL",
                source_uid=barter_item.get("source_uid") or "",
                source_timestamp=int(barter_item.get("source_timestamp") or 0),
                item_name=barter_item.get("item_name") or "",
                item_code=barter_item.get("item_code") or "",
                quantity=int(barter_item.get("quantity") or 0),
                item_value=int(barter_item.get("item_value") or 0),
                rate=int(barter_item.get("barter_rate") or 0),
                ticket_count=int(barter_item.get("awarded_tickets") or 0),
                import_uid=barter_item.get("source_uid") or None
            )

    result = {
        "confirm_string": confirms,
        "confirm_names": ", ".join(names),
        "import_summary": build_import_summary(total_added, new_participants, existing_participants),
    }
    logger.info("import_tickets2 returning: %s", result)
    return result

@view_config(route_name="clear_imports", renderer="json", permission="admin_access")
def clear_imports (request):
    return db.clear_imports()

# I see no reason why this should be available for others so making it admin
@view_config(route_name="get_user_tickets", renderer="json", permission="admin_access")
@view_config(route_name="get_user_tickets_id", renderer="json", permission="admin_access")
def get_user_tickets (request):
    return {}

@view_config(route_name="fix_dupes", renderer="json", permission="admin_access")
def fix_tickets (request):
    return db.fix_dupes()

@view_config(route_name="set_user_tickets", renderer="json", permission="admin_access")
def set_user_tickets (request):
    return {}
# Prizes, everyone needs to see this
@view_config(route_name="get_all_prizes", renderer="json")
@view_config(route_name="get_all_prizes_id", renderer="json")
def get_all_prizes (request):
    # this has to be a lot more complicated than you might think
    tlist = make_ticket_list(request)

    tlist2 = make_all_tickets(request)

    prizes = db.get_all_prizes()

    if not prizes:
        return []

    prizes = [dict(x) for x in prizes]

    for p in prizes:
        raw_prize_text = (p.get("prize_text") or "").strip()
        p["prize_text_display"] = raw_prize_text or "Prize Details Soon"

        raw_prize_value = p.get("prize_value")
        if raw_prize_value in (None, ""):
            p["prize_value_display"] = ""
        else:
            try:
                p["prize_value_display"] = f"{int(raw_prize_value):,}"
            except (TypeError, ValueError):
                p["prize_value_display"] = str(raw_prize_value)

        p["prize_style"] = normalize_prize_style(p.get("prize_style"))

        winner = p["prize_winner"]
        if winner != 0 and winner != "":
            if winner > 0:
                try:
                    winner = tlist[winner-1][1]
                except IndexError:
                    p["prize_winner_name"] = "*** INVALID TICKET ***"
                else:
                    p["prize_winner_name"] = winner
            elif winner < 0:
                try:
                    winner = -winner
                    p["prize_winner"] = "P" + str(winner)
                    winner = tlist2[winner-1][1]
                except IndexError:
                    p["prize_winner_name"] = "*** INVALID TICKET ***"
                else:
                    p["prize_winner_name"] = winner


    return prizes

# And from here out all admin yo
@view_config(route_name="add_new_prize", renderer="json", permission="admin_access")
def add_new_prize (request):
    # not a post request!
    return db.add_new_prize()

@view_config(route_name="clone_last_prize", renderer="json", permission="admin_access")
def clone_last_prize (request):
    if not db.clone_last_prize():
        return json_error("There is no prize card to clone yet.")
    return json_ok()

@view_config(route_name="clone_prize_below", renderer="json", permission="admin_access")
def clone_prize_below (request):
    prize_id = request.matchdict.get("prize_id")
    if not prize_id:
        return json_error("Missing prize id.")
    if not db.clone_prize_below(prize_id=prize_id):
        return json_error("Unable to duplicate that prize card.")
    return json_ok()

# Delete a prize entry
@view_config(route_name="delete_prize", renderer="json", permission="admin_access")
def delete_prize (request):
    if request.matchdict and "prize_id" in request.matchdict:
        prize = db.get_prize(request.matchdict["prize_id"])
        if prize and dict(prize).get("prize_finalised"):
            return json_error("Unlock this prize before deleting it.")
        return db.delete_prize(request.matchdict["prize_id"])

    return False

@view_config(route_name="finalise_prize", renderer="json", permission="admin_access")
def finalise_prize (request):
    if request.matchdict and "prize_id" in request.matchdict:
        if get_current_raffle_status() != "ROLLING":
            return json_error("Set raffle status to ROLLING before locking in winners.")
        if not db.finalise_prize(request.matchdict["prize_id"]):
            return json_error("Choose a winning ticket before locking this prize.")
        return json_ok(all_finalised=all_current_prizes_finalised())

    return json_error("Missing prize id.")

@view_config(route_name="unfinalise_prize", renderer="json", permission="admin_access")
def unfinalise_prize (request):
    if request.matchdict and "prize_id" in request.matchdict:
        status = get_current_raffle_status()
        if status not in ("ROLLING", "COMPLETE"):
            return json_error('Prizes can only be unlocked while the raffle is ROLLING or COMPLETE.')
        if not db.unfinalise_prize(request.matchdict["prize_id"]):
            return json_error("Unable to unlock this prize.")
        return json_ok()

    return json_error("Missing prize id.")

# Okay, I lied, maybe this might be needed
@view_config(route_name="get_prize", renderer="json")
@view_config(route_name="get_prize_id", renderer="json")
def get_prize (request):
    if "prize_id" in request.params:
        return dict(db.get_prize(request.params["prize_id"]))

    return {}

@view_config(route_name="set_prize", renderer="json", permission="admin_access")
def set_prize (request):
    if "prize_id" not in request.params:
        return json_error("Missing prize id.")

    p_id = request.params["prize_id"]
    current_prize = db.get_prize(p_id)
    if not current_prize:
        return json_error("Prize not found.")

    current_prize = dict(current_prize)
    if current_prize.get("prize_finalised"):
        return json_error("Unlock this prize before editing it.")

    data = parse_keys(current_prize, request.params, ["prize_text", "prize_text2", "prize_winner", "prize_value", "prize_style"], objects.Prize)
    data["prize_text"] = (data.get("prize_text") or "").strip()
    data["prize_style"] = normalize_prize_style(request.params.get("prize_style", data.get("prize_style")))

    raw_prize_value = request.params.get("prize_value", data.get("prize_value"))
    prize_value_digits = re.sub(r"[^\d]", "", "" if raw_prize_value is None else str(raw_prize_value))
    data["prize_value"] = int(prize_value_digits) if prize_value_digits else None

    raw_prize_winner = data.get("prize_winner", "")
    if raw_prize_winner in (None, ""):
        data["prize_winner"] = 0

    if isinstance(data["prize_winner"], str) and data["prize_winner"].startswith("P"):
        data["prize_winner"] = -int(data["prize_winner"][1:])

    if str(data.get("prize_winner", "")) != str(current_prize.get("prize_winner", "")):
        if get_current_raffle_status() != "ROLLING":
            return json_error("Set raffle status to ROLLING before entering or changing winning ticket numbers.")

    if db.set_prize(data):
        return json_ok()

    return json_error("Unable to update prize.")

# This is for rolling stuff
@view_config(route_name="roll_prize", renderer="json", permission="admin_access")
def roll_prize (request):
    if "prize_id" not in request.matchdict:
        return json_error("Missing prize id.")

    if get_current_raffle_status() != "ROLLING":
        return json_error("Set raffle status to ROLLING before rolling winners.")

    p_id = request.matchdict["prize_id"]

    o = dict(db.get_prize(p_id))
    if o.get("prize_finalised"):
        return json_error("Unlock this prize before rolling it again.")

    t = make_ticket_list(request)
    if not t:
        return json_error("There are no tickets to roll from.")

    roll = random.randint(1, len(t))

    o["prize_winner"] = roll

    if not db.set_prize(o):
        return json_error("Unable to roll a winner for this prize.")

    return json_ok()

    #return {"name": t[roll-1][1], "ticket": roll}

# This is needed
@view_config(route_name="get_guild_info", renderer="json")
@view_config(route_name="get_guild_info_id", renderer="json")
def get_guild_info (request):
    return dict(gget_guild_info(guild_data=db.get_guild_by_id()))

def gget_guild_info (guild_name=None, guild_data=None):
    if guild_name is None and guild_data is not None:
        g = guild_data
    else:
        g = db.get_guild_by_shortname(guild_name)

    if not g:
        return None

    n = objects.Guild()
    n["guild_name"] = g["guild_name"]
    n["guild_shortname"] = g["guild_shortname"]
    n["guild_id"] = g["guild_id"]
    n["guild_eso_id"] = g["guild_eso_id"] if "guild_eso_id" in g.keys() else ""
    n["guild_expected_mail_accounts"] = parse_expected_mail_accounts(g["guild_expected_mail_accounts"] if "guild_expected_mail_accounts" in g.keys() else "")
    n["guild_import_blacklist"] = parse_import_blacklist(g["guild_import_blacklist"] if "guild_import_blacklist" in g.keys() else "")
    n["guild_timezone"] = g["guild_timezone"] if "guild_timezone" in g.keys() and g["guild_timezone"] else DEFAULT_GUILD_DISPLAY_TIMEZONE
    n["guild_game_server"] = g["guild_game_server"] if "guild_game_server" in g.keys() and g["guild_game_server"] else DEFAULT_GUILD_GAME_SERVER
    n["guild_logo_url"] = g["guild_logo_url"] if "guild_logo_url" in g.keys() and g["guild_logo_url"] else DEFAULT_GUILD_LOGO_URL
    n["guild_favicon_url"] = g["guild_favicon_url"] if "guild_favicon_url" in g.keys() and g["guild_favicon_url"] else DEFAULT_GUILD_FAVICON_URL
    n["guild_primary_color"] = g["guild_primary_color"] if "guild_primary_color" in g.keys() and g["guild_primary_color"] else DEFAULT_GUILD_PRIMARY_COLOR
    n["guild_accent_color"] = g["guild_accent_color"] if "guild_accent_color" in g.keys() and g["guild_accent_color"] else DEFAULT_GUILD_ACCENT_COLOR
    n["guild_sister_guilds"] = parse_guild_shortname_list(g["guild_sister_guilds"] if "guild_sister_guilds" in g.keys() else "")
    del n["guild_roster"]
    return n

@view_config(route_name="get_timestamp", renderer="json")
@view_config(route_name="get_timestamp_id", renderer="json")
def get_timestamp (request):
    g = db.get_last_update_info()

    if not g:
        return None

    return {
        "timestamp": g["timestamp"],
        "updated_by": g["updated_by"],
    }

# This is needed even more
@view_config(route_name="import_roster_slash", renderer="mako_templates/roster.mako")
def import_roster (request):
    return {}

@view_config(route_name="import_roster", renderer="mako_templates/roster.mako")
def import_roster_noslash (request):
    return HTTPFound(route_url('import_roster_slash', request))

@view_config(route_name="parse_roster", renderer="json")
def parse_roster (request):
    try:
        if "file" not in request.POST:
            return {"error": "No file uploaded"}

        f = request.POST['file']

        if not hasattr(f, "file"):
            return {"error": "Invalid file object"}

        if f.filename != "RaffleManager.lua":
            return {"error": f"Wrong filename: {f.filename}. Expected RaffleManager.lua"}

        raffle_file = ""
        f.file.seek(0)

        while True:
            data = f.file.read(8192)
            if not data:
                break

            # Handle bytes properly
            if isinstance(data, bytes):
                data = data.decode('utf-8')
            raffle_file = raffle_file + data

        raffle_file = raffle_file.splitlines()
        if not raffle_file or not raffle_file[0].startswith("RaffleManager_SavedVariables"):
            return {"error": "File doesn't start with 'RaffleManager_SavedVariables'"}

        raffle_file = "\n".join(raffle_file[1:])

        try:
            data = lua.decode(raffle_file)
        except Exception as e:
            return {"error": f"Lua decode error: {e}"}

        data = data["Default"]

        timestamp_keys = []

        for k, v in data.items():
            if "$AccountWide" in v:
                v = v["$AccountWide"]

            ts = v.get("roster_timestamp", 0)
            timestamp_keys.append((ts, k))

        timestamp_keys.sort()

        # Debug: Log what we found
        if not timestamp_keys:
            return {"error": "No accounts with roster data found"}

        # If no accounts have roster_timestamp > 0, find accounts with roster_data
        if all(ts == 0 for ts, _ in timestamp_keys):
            accounts_with_roster = []
            for k, v in data.items():
                if "$AccountWide" in v and "roster_data" in v["$AccountWide"]:
                    accounts_with_roster.append(k)
            
            if not accounts_with_roster:
                return {"error": "No accounts found with roster_data"}
            
            # Use the first account found with roster_data
            key = accounts_with_roster[0]
        else:
            key = timestamp_keys[-1][1]

        data = data[key]

        if "$AccountWide" not in data:
            return {"error": "$AccountWide not found in data"}

        data = data["$AccountWide"]

        if "roster_data" not in data:
            return {"error": "roster_data not found in data"}

        data = data["roster_data"]

        # Debug: Check the structure of roster data
        if not data:
            return {"error": "roster_data is empty"}

        # Check if this is the incomplete roster data (only purchases10)
        sample_entry = list(data.values())[0] if data else {}
        if "account" not in sample_entry:
            # Create a detailed error message about what's missing
            found_fields = list(sample_entry.keys()) if sample_entry else []
            missing_fields = ["account", "joined", "sales30", "sales10", "purchases30"]
            
            error_msg = f"Roster data is incomplete. Found fields: {found_fields}. "
            error_msg += f"Missing required fields: {missing_fields}. "
            error_msg += "This appears to be partial data that only contains purchase information. "
            error_msg += "To generate a complete roster TSV, you need an addon export that includes "
            error_msg += "full guild member information with account names, join dates, and sales data."
            
            return {"error": error_msg}

        # name, joined, sales30, sales10, purchases30, purchases10

        full_path, filename = gdata.get_import()

        #with open(filename, "w") as f:
        with open(os.path.join(full_path, filename), "w") as f:
            writer = csv.writer(f, delimiter="\t", quotechar='"', quoting=csv.QUOTE_MINIMAL)
            writer.writerow(["Name", "Joined", "Sales30", "Sales10", "Purchases30", "Purchases10"])
            for k, v in data.items():

                joined = v["joined"]
                if joined == 0:
                    joined = None

                writer.writerow((v["account"].replace("''", "'").strip("'"), joined, v["sales30"], v["sales10"], v["purchases30"], v["purchases10"]))

        excel_formula = '=IMPORTDATA("' + gdata.roster_url + filename + '")'
        return excel_formula
    
    except Exception as e:
        return {"error": f"General error: {e}"}

def add_info (event):
    request = event.request
    if request.matchdict and request.matchdict in "guild":
        n = gget_guild_info(request.matchdict["guild"])
        request.guild = n

def make_app ():
    # Initialize database if it doesn't exist (preserves existing databases)
    try:
        from init_db import init_database
        actual_db_path = init_database()
        
        # Update dbconf with the actual database path used
        import dbconf
        if actual_db_path and actual_db_path != dbconf.DATABASE_PATH:
            print(f"Updating database configuration to use: {actual_db_path}")
            dbconf.DATABASE_PATH = actual_db_path
            dbconf.DATABASE = actual_db_path
    except Exception as e:
        print(f"Database initialization error: {e}")
        # Continue anyway - the app might still work if database exists
    
    session_factory = SignedCookieSessionFactory("supersupersecretpasswordgoeshereYAY!!!1")
    config = Configurator(settings=pconf.settings, session_factory=session_factory)

    config.add_static_view('static', 'static')
    config.add_static_view('import', 'import')

    config.include("pyramid_mako")

    def g_route (*args, **kwargs):
        kwargs["custom_predicates"] = (allowed_guilds, )
        return config.add_route(*args, **kwargs)

    config.add_route('import_roster', '/roster')
    config.add_route('import_roster_slash', '/roster/')
    config.add_route('parse_roster', '/roster/json/set/parse')

    g_route('guild_landing', '/{guild}/')
    g_route('guild_landing_noslash', '/{guild}')
    g_route('guild_landing_raffle', '/{guild}/{raffle}/')
    g_route('raffle_lookup', '/{guild}/lookup')

    g_route('home', '/')
    config.add_route('health', '/health')

    # List of potential routes:
    # -- Roster
    g_route("get_guild_roster", "/{guild}/json/get/roster")
    g_route("set_guild_roster", "/{guild}/json/set/roster")
    g_route("set_guild_settings", "/{guild}/json/set/guild_settings")
    g_route("get_guild_info",   "/{guild}/json/get/guild")
    g_route("get_guild_choices", "/{guild}/json/get/guild_choices")
    g_route("get_barter_bounty_list", "/{guild}/json/get/barter_bounty_list")
    g_route("set_barter_bounty_list", "/{guild}/json/set/barter_bounty_list")

    g_route("get_guild_roster_id", "/{guild}/{raffle}/json/get/roster")
    g_route("get_guild_info_id",   "/{guild}/{raffle}/json/get/guild")
    # -- Raffles
    g_route("get_current_raffle_info", "/{guild}/json/get/raffle")
    g_route("get_current_raffle_bounty_list", "/{guild}/json/get/raffle_bounty_list")
    g_route("get_current_barter_summary", "/{guild}/json/get/barter_summary")
    g_route("set_current_raffle_info", "/{guild}/json/set/raffle")
    g_route("set_current_raffle_notes", "/{guild}/json/set/raffle_notes")
    g_route("close_current_raffle", "/{guild}/json/set/close_raffle")
    g_route("open_new_raffle", "/{guild}/json/set/open_raffle")
    g_route("get_auth_users", "/{guild}/json/get/auth_users")
    g_route("create_auth_user", "/{guild}/json/set/auth_user_create")
    g_route("set_auth_user_roles", "/{guild}/json/set/auth_user_roles")
    g_route("delete_auth_user", "/{guild}/json/set/auth_user_delete")
    g_route("reset_auth_user_password", "/{guild}/json/set/auth_user_reset_password")
    g_route("change_own_password", "/{guild}/json/set/change_password")
    g_route("get_own_account_settings", "/{guild}/json/get/account_settings")
    g_route("set_own_account_settings", "/{guild}/json/set/account_settings")

    g_route("get_current_raffle_info_id", "/{guild}/{raffle}/json/get/raffle")
    # -- Tickets
    g_route("get_all_tickets", "/{guild}/json/get/tickets")
    g_route("set_all_tickets", "/{guild}/json/set/tickets")
    # -- Extended tickets
    g_route("get_extended_tickets", "/{guild}/json/get/tickets_extended")
    g_route("get_extended_tickets_id", "/{guild}/{raffle}/json/get/tickets_extended")
    g_route("set_extended_tickets", "/{guild}/json/set/tickets_extended")

    g_route("get_ticket_list", "{guild}/json/get/ticket_list")
    g_route("import_tickets", "/{guild}/json/set/tickets_import")
    g_route("import_tickets2", "/{guild}/json/set/tickets_import2")
    g_route("barter_import", "/{guild}/json/set/barter_import")
    g_route("paid_import", "/{guild}/json/set/paid_import")
    g_route("get_user_tickets", "/{guild}/json/get/tickets_{username}")
    g_route("set_user_tickets", "/{guild}/json/set/tickets_{username}")
    g_route("fix_dupes", "/{guild}/json/set/dupes")
    g_route("clear_imports", "/{guild}/json/set/clear_imports")

    g_route("get_timestamp", "/{guild}/json/get/timestamp")
    g_route("get_timestamp_id", "/{guild}/{raffle}/json/get/timestamp")

    g_route("export_csv", "/{guild}/json/get/csv")

    g_route("get_all_tickets_id", "/{guild}/{raffle}/json/get/tickets")
    g_route("get_ticket_list_id", "{guild}/{raffle}/json/get/ticket_list")
    g_route("get_user_tickets_id", "/{guild}/{raffle}/json/get/tickets_{username}")
    # -- Prizes
    g_route("get_all_prizes", "/{guild}/json/get/prizes")
    g_route("add_new_prize", "/{guild}/json/set/prize_add")
    g_route("clone_last_prize", "/{guild}/json/set/prize_clone_last")
    g_route("clone_prize_below", "/{guild}/json/set/prize_clone_below/{prize_id}")
    g_route("delete_prize", "/{guild}/json/set/prize_delete/{prize_id}")
    g_route("get_prize", "/{guild}/json/get/prize/{prize_id}")
    g_route("set_prize", "/{guild}/json/set/prize")

    g_route("get_all_prizes_id", "/{guild}/{raffle}/json/get/prizes")
    g_route("get_prize_id", "/{guild}/{raffle}/json/get/prize/{prize_id}")
    # -- Prize manipulation
    g_route("roll_prize", "/{guild}/json/set/prize_roll/{prize_id}")
    g_route("finalise_prize", "/{guild}/json/set/prize_finalise/{prize_id}")
    g_route("unfinalise_prize", "/{guild}/json/set/prize_unfinalise/{prize_id}")

    # Re-enable auth module - all Python 2/3 issues resolved
    # Include auth module at root level and also with guild prefix
    config.include('auth')
    
    # Add guild-specific auth routes  
    config.add_route('guild_auth_login', '/{guild}/auth/login')
    config.add_view(redirect_guild_login, route_name='guild_auth_login')
    config.add_route('guild_auth_logout', '/{guild}/auth/logout')  
    config.add_view(logout, route_name='guild_auth_logout')
    
    config.scan()
    
    return config.make_wsgi_app()

if __name__ == "__main__":
    serve(make_app(), host='0.0.0.0', port=80)
