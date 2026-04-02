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

from auth.views import login, logout
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
    cur.execute("SELECT guild_id, guild_shortname, guild_name FROM guilds ORDER BY guild_id")
    return [dict(row) for row in cur.fetchall()]


def ensure_raffle_schema():
    cur = db.cursor()
    cur.execute("PRAGMA table_info(raffles)")
    columns = {row[1] for row in cur.fetchall()}

    if "raffle_title" not in columns:
        cur.execute("ALTER TABLE raffles ADD COLUMN raffle_title TEXT DEFAULT ''")

    if "raffle_status" not in columns:
        cur.execute("ALTER TABLE raffles ADD COLUMN raffle_status TEXT DEFAULT 'LIVE'")


@view_config(route_name='home', renderer="mako_templates/select.mako")
def home (request):
    return {"guilds": get_select_guilds()}

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
    if "guild" in request.matchdict:
        guild = request.matchdict["guild"]

        return HTTPFound(route_url('guild_landing', request, guild=guild))
    else:
        return {}

@view_config(route_name='guild_landing', renderer="mako_templates/index.mako")
@view_config(route_name='guild_landing_raffle', renderer="mako_templates/index.mako")
def landing (request):
    # Auth system re-enabled - check for admin user
    if request.user is not None:
        if request.user.in_group("akaviri"):
            request.override_renderer = "mako_templates/admin_index.mako"
        if gdata.extended:
            request.extended_tickets = True
        else:
            request.extended_tickets = False

    return {}

#------------- ALL THE API ------------#
# Both of these are admin functions
@view_config(route_name="get_guild_roster", renderer="json", permission="akaviri")
@view_config(route_name="get_guild_roster_id", renderer="json", permission="akaviri")
def get_guild_roster (request):
    roster = db.get_guild_roster()
    if roster:
        roster = roster.split(",")
    return roster

@view_config(route_name="set_guild_roster", renderer="json", permission="akaviri")
def set_guild_roster (request):
    # Do something here at some point

    return {"roster": True}
# Available to all
@view_config(route_name="get_current_raffle_info", renderer="json")
@view_config(route_name="get_current_raffle_info_id", renderer="json")
def get_current_raffle_info (request):
    raffle_id = request.matchdict.get("raffle")

if raffle_id:
    info = db.get_raffle_info_by_id(raffle_id)
else:
    info = db.get_cur_raffle_info()
    if not info:
        return {}

    info = dict(info)
    info["raffle_title"] = (info.get("raffle_title") or "").strip()
    info["raffle_status"] = (info.get("raffle_status") or "LIVE").strip() or "LIVE"
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

# Admin only
@view_config(route_name="set_current_raffle_info", renderer="json", permission="akaviri")
def set_current_raffle_info (request):
    current_info = db.get_cur_raffle_info()
    if not current_info:
        return False

    data = dict(current_info)
    data["raffle_guild_num"] = request.params.get("raffle_guild_num", data.get("raffle_guild_num", ""))
    data["raffle_time"] = request.params.get("raffle_time", data.get("raffle_time", ""))
    data["raffle_ticket_cost"] = request.params.get("raffle_ticket_cost", data.get("raffle_ticket_cost", ""))
    data["raffle_notes"] = request.params.get("raffle_notes", data.get("raffle_notes", ""))
    data["raffle_title"] = request.params.get("raffle_title", data.get("raffle_title", ""))
    data["raffle_status"] = request.params.get("raffle_status", data.get("raffle_status", "LIVE")) or "LIVE"

    cur = db.cursor()
    cur.execute(
        "UPDATE raffles SET raffle_guild=?, raffle_guild_num=?, raffle_time=?, raffle_ticket_cost=?, raffle_closed=?, raffle_notes=?, raffle_title=?, raffle_status=? WHERE raffle_id=?",
        (
            data["raffle_guild"],
            data["raffle_guild_num"],
            data["raffle_time"],
            data["raffle_ticket_cost"],
            data["raffle_closed"],
            data["raffle_notes"],
            data["raffle_title"],
            data["raffle_status"],
            data["raffle_id"],
        )
    )
    return True

@view_config(route_name="close_current_raffle", renderer="json", permission="akaviri")
def close_current_raffle (request):
    return {}

@view_config(route_name="open_new_raffle", renderer="json", permission="akaviri")
def open_new_raffle (request):
    cur_id = db.get_cur_raffle_id()

    db.close_raffle_by_id(cur_id)
    
    if db.create_new_raffle():
        return True

    return False

# For everyone!
@view_config(route_name="get_all_tickets", renderer="json")
@view_config(route_name="get_all_tickets_id", renderer="json")
def get_all_tickets (request):
    return make_all_tickets(request)

@view_config(route_name="get_extended_tickets", renderer="json")
def get_extended_tickets (request):
    return make_all_tickets(request, True)

def make_all_tickets (request, extended=False):
    raffle_id = request.matchdict.get("raffle")

if raffle_id:
    tickets = db.get_tickets_by_raffle_id(raffle_id)
else:
    tickets = db.get_tickets()

    if not tickets:
        return []

    data = [dict(x) for x in tickets]

    res = []

    build = []

    for i in data:
        if i["ticket_count"] != 0 or i["ticket_free"] != 0 or i["ticket_barter"] != 0:
            build.append(i)

    data = sorted(build, key=lambda x: x["ticket_user_name"].lower())

    for i in range(len(data)):
        d = data[i]

        try:
            barter_val = int(d["ticket_barter"])
        except:
            barter_val = 0

        total = d["ticket_count"] + d["ticket_free"] + barter_val

        if total == 0:
            continue

        if extended:
            new = [i+1, d["ticket_user_name"], total, d["ticket_count"], d["ticket_free"], barter_val]
        else:
            new = [i+1, d["ticket_user_name"], total]

        res.append(new)

    return res

@view_config(route_name="export_csv")
def export_csv (request):
    data = [dict(x) for x in db.get_tickets()]

    build = []

    for i in data:
        try:
            barter_val = int(i["ticket_barter"])
        except:
            barter_val = 0
        if i["ticket_count"] != 0 or i["ticket_free"] != 0 or barter_val != 0:
            i["ticket_user_name"] = i["ticket_user_name"].replace('"', "'")
            build.append(i)

    f = io.StringIO()
    writer = csv.writer(f, delimiter="\t", quotechar="'", quoting=csv.QUOTE_MINIMAL)
    for i in sorted(build, key=operator.itemgetter("ticket_user_name")):
        try:
            barter_val = int(i["ticket_barter"])
        except:
            barter_val = 0
        total = i["ticket_count"] + i["ticket_free"] + barter_val
        writer.writerow([i["ticket_user_name"], "note", total])

    f.seek(0)
    res = f.read()
    f.close()

    headers = request.response.headers
    headers['Content-Type'] = "text/csv"
    headers['Content-Disposition'] = "attachment; filename=raffle_export.txt"

    request.response.text = res

    return request.response

@view_config(route_name="set_all_tickets", renderer="json", permission="akaviri")
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

    for u in to_update:
        if db.set_user_tickets(user_name=u[0], ticket_count=u[1]):
            change_count = change_count + 1

    return change_count

@view_config(route_name="set_extended_tickets", renderer="json", permission="akaviri")
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

        u_name, u_count, u_free, u_barter = None, None, None, None

        if hasattr(row, "get"):
            u_name = row.get("1", None)
            u_count = row.get("3", None)
            u_free = row.get("4", None)
            u_barter = row.get("5", None)
        elif isinstance(row, list):
            u_name = row[1] if len(row) > 1 else None
            u_count = row[3] if len(row) > 3 else None
            u_free = row[4] if len(row) > 4 else None
            u_barter = row[5] if len(row) > 5 else None

        if u_name is None or u_count is None:
            continue

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

    for u in to_update:
        if db.set_user_tickets(user_name=u[0], ticket_count=u[1], ticket_free=u[2], ticket_barter=u[3]):
            change_count = change_count + 1

    return change_count

def make_ticket_list (request):
    raffle_id = request.matchdict.get("raffle")

if raffle_id:
    ticks = db.get_tickets_by_raffle_id(raffle_id)
else:
    ticks = db.get_tickets()

    if not ticks:
        return []

    data = [dict(x) for x in ticks]

    tno = 1 # starting ticket number

    res = []

    for user in data:
        cu = gdata.prefix + user["ticket_user_name"]

        count = user["ticket_count"]
        free = user["ticket_free"]
        barter = user["ticket_barter"]

        total = count + free + barter

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

@view_config(route_name="barter_import", renderer="json", permission="akaviri")
def barter_import (request):
    if "barter_import_string" not in request.params:
        return {}

    data = request.params["barter_import_string"]

    confirm_data = request.params["barter_confirm_string"]

    confirms = {}

    for line in confirm_data.split("|"):
        try:
            user, amount = line.split(",")
        except:
            continue
        else:
            confirms[user] = [amount, 0]

    lines = data.split("\n")

    names = []
    confirm = ""

    barter_data = {}

    for line in lines:
        if line.count("\t") != 1:
            continue

        user, amount = line.split("\t")

        user = user.replace("@", "")

        amount = int(amount)

        if user in barter_data:
            barter_data[user] = barter_data[user] + amount
        else:
            barter_data[user] = amount

    for user, amount in barter_data.items():
        u = db.get_user_tickets(user)

        if u:
            prev_tickets = u[3]
            free_tickets = u[5]
            bart_tickets = u[6]
        else:
            prev_tickets = 0
            free_tickets = 0
            bart_tickets = 0

        diff = amount - bart_tickets

        # FIXED: Preserve existing paid tickets (prev_tickets) and free tickets while updating barter
        db.set_user_tickets(user_name=user, ticket_count=prev_tickets, ticket_free=free_tickets, ticket_barter=amount)

        if diff != 0:
            if user in confirms:
                confirms[user][1] = diff
            else:
                confirms[user] = [0, diff]

    for k, v in confirms.items():
        confirm = confirm + "%s,%s,%s|" % (k, v[0], v[1])
        names.append("@%s" % k)

    return [confirm, ", ".join(names)]

@view_config(route_name="paid_import", renderer="json", permission="akaviri")
def paid_import (request):
    """Import paid tickets - similar to barter_import but updates ticket_count instead of ticket_barter"""
    if "paid_import_string" not in request.params:
        return {}

    data = request.params["paid_import_string"]

    confirm_data = request.params.get("paid_confirm_string", "")

    confirms = {}

    for line in confirm_data.split("|"):
        try:
            user, amount = line.split(",")
        except:
            continue
        else:
            confirms[user] = [amount, 0]

    lines = data.split("\n")

    names = []
    confirm = ""

    paid_data = {}

    for line in lines:
        if line.count("\t") != 1:
            continue

        user, amount = line.split("\t")

        user = user.replace("@", "")

        amount = int(amount)

        if user in paid_data:
            paid_data[user] = paid_data[user] + amount
        else:
            paid_data[user] = amount

    for user, amount in paid_data.items():
        u = db.get_user_tickets(user)

        if u:
            prev_tickets = u[3]
            free_tickets = u[5]
            bart_tickets = u[6]
        else:
            prev_tickets = 0
            free_tickets = 0
            bart_tickets = 0

        diff = amount - prev_tickets

        # FIXED: Preserve existing free and barter tickets while updating paid tickets
        db.set_user_tickets(user_name=user, ticket_count=amount, ticket_free=free_tickets, ticket_barter=bart_tickets)

        if diff != 0:
            if user in confirms:
                confirms[user][1] = diff
            else:
                confirms[user] = [0, diff]

    for k, v in confirms.items():
        # FIXED: Use paid ticket format (name,amount) instead of barter format (name,old,new)
        confirm = confirm + "%s,%s|" % (k, v[1])
        names.append("@%s" % k)

    return [confirm, ", ".join(names)]

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


@view_config(route_name="import_tickets", renderer="json", permission="akaviri")
def import_tickets (request):
    if "file" not in request.POST:
        return {}

    ginfo = db.get_guild_by_id()
    gid = ginfo[0]

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
    except:
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

    if key not in data:
        return {}

    data = data[key]

    if "$AccountWide" in data:
        data = data["$AccountWide"]
    else:
        return {}

    bank_data = normalize_lua_table_records(data.get("bank_data", {}))
    mail_data = normalize_lua_table_records(data.get("mail_data", {}))

    potential_tickets = []

    for line in bank_data:
        uid = line.get("id")
        user = str(line.get("user", "")).lstrip("@")
        timestamp = line.get("timestamp")
        amount = line.get("amount", 0)

        if not uid or not user or timestamp is None:
            continue

        try:
            amount = int(amount)
            timestamp = int(timestamp)
        except (TypeError, ValueError):
            continue

        time_str = time.strftime("%H:%M:%S %d/%m/%Y", time.localtime(timestamp))

        r = db.get_import_by_id(uid, gid)
        if r:
            continue

        if amount % t_cost != 0:
            continue

        potential_tickets.append((user, amount / t_cost, "GUILD BANK DEPOSIT", time_str, uid))

    for line in mail_data:
        uid = line.get("id")
        user = str(line.get("user", "")).lstrip("@")
        subject = line.get("subject", "")
        amount = line.get("amount", 0)

        if not uid or not user:
            continue

        try:
            amount = int(amount)
        except (TypeError, ValueError):
            continue

        r = db.get_import_by_id(uid, gid)
        if r:
            continue

        if amount % t_cost != 0:
            continue

        potential_tickets.append((user, amount / t_cost, subject, "MAILED IN", uid))

    return potential_tickets

@view_config(route_name="import_tickets2", renderer="json", permission="akaviri")
def import_tickets2 (request):
    import logging
    logger = logging.getLogger(__name__)
    logger.info("import_tickets2 called")
    logger.info("Request params: %s", dict(request.params))
    
    rows = []

    current_row = []

    cur_row = 0

    # rebuild rows
    for key, item in request.params.items():
        cr = "row%s" % cur_row
        if cr in key:
            current_row.append((key, item))
        else:
            rows.append(current_row)
            current_row = []
            current_row.append((key, item))
            cur_row = cur_row + 1

    rows.append(current_row)

    ginfo = db.get_guild_by_shortname(request.matchdict["guild"])

    guild = ginfo[1]
    guild_id = ginfo[0]

    # sanitize data, discard non-required pieces
    new_rows = []

    for row in rows:
        this_row = {}
        for k, v in row:
            k = k.split("_")[1]
            this_row[k] = v

        if this_row.get("confirmed", False):
            new_rows.append(this_row)
        else:
            db.record_import(this_row["uid"], int(time.time()), 1, guild_id)

    uids = []

    # final pass, convert data to a dictionary, collapsing multi-deposit tickets into one

    data = {}

    for row in new_rows:
        row["amount"] = int(row["amount"])

        db.record_import(row["uid"], int(time.time()), 0, guild_id)

        if data.get(row["name"], False):
            data[row["name"]] = data[row["name"]] + row["amount"]
        else:
            data[row["name"]] = row["amount"]

    # actually set tickets!


    confirms = ""

    names = []

    for user_name, tickets in data.items():
        names.append("@"+user_name)

        u = db.get_user_tickets(user_name)
        if u:
            prev_tickets = u[3]
            free_tickets = u[5]
            barter_tickets = u[6]
        else:
            prev_tickets = 0
            free_tickets = 0
            barter_tickets = 0

        #if not isinstance(free_tickets, int):
        #    free_tickets = 0
        #if not isinstance(barter_tickets, int):
        #    barter_tickets = 0

        # FIXED: Preserve existing free and barter tickets while adding new paid tickets
        db.set_user_tickets(user_name, prev_tickets+tickets, free_tickets, barter_tickets)

        confirms = confirms + "%s,%s|" % (user_name, tickets)

    result = [confirms, ", ".join(names)]
    logger.info("import_tickets2 returning: %s", result)
    return result

@view_config(route_name="clear_imports", renderer="json", permission="akaviri")
def clear_imports (request):
    return db.clear_imports()

# I see no reason why this should be available for others so making it admin
@view_config(route_name="get_user_tickets", renderer="json", permission="akaviri")
@view_config(route_name="get_user_tickets_id", renderer="json", permission="akaviri")
def get_user_tickets (request):
    return {}

@view_config(route_name="fix_dupes", renderer="json", permission="akaviri")
def fix_tickets (request):
    return db.fix_dupes()

@view_config(route_name="set_user_tickets", renderer="json", permission="akaviri")
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
@view_config(route_name="add_new_prize", renderer="json", permission="akaviri")
def add_new_prize (request):
    # not a post request!
    return db.add_new_prize()

# Delete a prize entry
@view_config(route_name="delete_prize", renderer="json", permission="akaviri")
def delete_prize (request):
    if request.matchdict and "prize_id" in request.matchdict:
        return db.delete_prize(request.matchdict["prize_id"])

    return False

@view_config(route_name="finalise_prize", renderer="json", permission="akaviri")
def finalise_prize (request):
    if request.matchdict and "prize_id" in request.matchdict:
        return db.finalise_prize(request.matchdict["prize_id"])

    return False

# Okay, I lied, maybe this might be needed
@view_config(route_name="get_prize", renderer="json")
@view_config(route_name="get_prize_id", renderer="json")
def get_prize (request):
    if "prize_id" in request.params:
        return dict(db.get_prize(request.params["prize_id"]))

    return {}

@view_config(route_name="set_prize", renderer="json", permission="akaviri")
def set_prize (request):
    if "prize_id" not in request.params:
        return False

    p_id = request.params["prize_id"]

    data = parse_keys(db.get_prize(p_id), request.params, ["prize_text", "prize_text2", "prize_winner"], objects.Prize)

    if data["prize_winner"].startswith("P"):
        data["prize_winner"] = -int(data["prize_winner"][1:])

    return db.set_prize(data)

# This is for rolling stuff
@view_config(route_name="roll_prize", renderer="json", permission="akaviri")
def roll_prize (request):
    if "prize_id" not in request.matchdict:
        return False

    p_id = request.matchdict["prize_id"]

    o = dict(db.get_prize(p_id))

    t = make_ticket_list(request)

    roll = random.randint(1, len(t))

    o["prize_winner"] = roll

    db.set_prize(o)

    return True

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
    del n["guild_roster"]
    return n

@view_config(route_name="get_timestamp", renderer="json")
@view_config(route_name="get_timestamp_id", renderer="json")
def get_timestamp (request):
    g = db.get_max_timestamp()

    if not g:
        return None

    return g

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

def bonus_tickets (event):
    request = event.request
    if guild_bonus_five (request):
        request.bonus_tickets = 5
    elif guild_bonus_two (request):
        request.bonus_tickets = 2
    else:
        request.bonus_tickets = 0

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

    ensure_raffle_schema()
    
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

    g_route('home', '/')
    config.add_route('health', '/health')

    # List of potential routes:
    # -- Roster
    g_route("get_guild_roster", "/{guild}/json/get/roster")
    g_route("set_guild_roster", "/{guild}/json/set/roster")
    g_route("get_guild_info",   "/{guild}/json/get/guild")

    g_route("get_guild_roster_id", "/{guild}/{raffle}/json/get/roster")
    g_route("get_guild_info_id",   "/{guild}/{raffle}/json/get/guild")
    # -- Raffles
    g_route("get_current_raffle_info", "/{guild}/json/get/raffle")
    g_route("set_current_raffle_info", "/{guild}/json/set/raffle")
    g_route("close_current_raffle", "/{guild}/json/set/close_raffle")
    g_route("open_new_raffle", "/{guild}/json/set/open_raffle")

    g_route("get_current_raffle_info_id", "/{guild}/{raffle}/json/get/raffle")
    # -- Tickets
    g_route("get_all_tickets", "/{guild}/json/get/tickets")
    g_route("set_all_tickets", "/{guild}/json/set/tickets")
    # -- Extended ticekts
    g_route("get_extended_tickets", "/{guild}/json/get/tickets_extended")
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
    g_route("delete_prize", "/{guild}/json/set/prize_delete/{prize_id}")
    g_route("get_prize", "/{guild}/json/get/prize/{prize_id}")
    g_route("set_prize", "/{guild}/json/set/prize")

    g_route("get_all_prizes_id", "/{guild}/{raffle}/json/get/prizes")
    g_route("get_prize_id", "/{guild}/{raffle}/json/get/prize/{prize_id}")
    # -- Prize manipulation
    g_route("roll_prize", "/{guild}/json/set/prize_roll/{prize_id}")
    g_route("finalise_prize", "/{guild}/json/set/prize_finalise/{prize_id}")

    config.add_subscriber(bonus_tickets, 'pyramid.events.ContextFound')

    # Re-enable auth module - all Python 2/3 issues resolved
    # Include auth module at root level and also with guild prefix
    config.include('auth')
    
    # Add guild-specific auth routes  
    config.add_route('guild_auth_login', '/{guild}/auth/login')
    config.add_view(login, route_name='guild_auth_login', 
                    renderer='mako_templates/login_simple.mako')
    config.add_route('guild_auth_logout', '/{guild}/auth/logout')  
    config.add_view(logout, route_name='guild_auth_logout')
    
    config.scan()
    
    return config.make_wsgi_app()

if __name__ == "__main__":
    serve(make_app(), host='0.0.0.0', port=80)
