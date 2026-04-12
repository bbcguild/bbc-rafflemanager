#!/usr/bin/env python3

from dbconf import DATABASE

import sqlite3
import time
import re
from get_request import get_request
from functools import wraps

import objects

__CONNECTION = None

def connection ():
    global __CONNECTION, __CURSOR
    if __CONNECTION is None:
        __CONNECTION = sqlite3.connect(DATABASE, check_same_thread=False, isolation_level=None)

        __CONNECTION.row_factory = sqlite3.Row

    return __CONNECTION

def cursor ():
    return connection().cursor()

def commit ():
    connection().commit()

# data fetch etc functions

def with_cursor (f):
    @_with_cursor(f)
    @wraps(f)
    def wrapper(*args, **kwargs):
        return f(*args, **kwargs)
    return wrapper

def _with_cursor (function):
    fc = function.__code__
    def subwrapper (f):
        @wraps(f)
        def wrapper (*args, **kwargs):
            fcv = list(fc.co_varnames)
            cur = cursor()

            if "cur" in fcv and "cur" not in kwargs:
                kwargs["cur"] = cur
                del fcv[fcv.index("cur")]

            if "guild_id" in fcv and ("guild_id" not in kwargs and ((len(args)+len(kwargs)) < fc.co_argcount)):
                req = get_request()
                if not req or "guild" not in req.matchdict:
                    raise Exception("Guild context not available")

                q = req.matchdict["guild"]
                kwargs["guild_id"] = get_guild_id_by_name(cur, q)

                # Now resolve the rest of the arguments
                # Note: guild_id resolution needs to be implemented
                del fcv[fcv.index("guild_id")]

                if "raf_id" in fcv and ("raf_id" not in kwargs and ((len(args)+len(kwargs)) < fc.co_argcount)):
                    if "raffle" in req.matchdict:

                        q = req.matchdict["raffle"]
                        l = get_raffle_id_by_number(cur, kwargs["guild_id"], q)
                        if l:
                            kwargs["raf_id"] = l
                        else:
                            kwargs["raf_id"] = None
                    else:
                        kwargs["raf_id"] = None

                    del fcv[fcv.index("raf_id")]


            kwargs = dict(zip(fcv, args), **kwargs)

            return f(**kwargs)
        return wrapper
    return subwrapper

def with_cursor_rowid (f):
    @_with_cursor(f)
    @wraps(f)
    def wrapper (*args, **kwargs):
        res = f(*args, **kwargs)
        if res is not None:
            return res

        return kwargs["cur"].lastrowid
    return wrapper

def with_cursor_row (row):
    def subwrapper (f):
        @_with_cursor(f)
        @wraps(f)
        def wrapper (*args, **kwargs):
            ret = f(*args, **kwargs)
            if not ret:
                return None
            else:
                return ret[row]
        return wrapper
    return subwrapper

def with_cursor_boolean (f):
    @_with_cursor(f)
    @wraps(f)
    def wrapper (*args, **kwargs):
        cur = kwargs["cur"] 

        ret = f(*args, **kwargs)
        if ret is True or ret is False:
            return ret

        if cur.rowcount == 0:
            return False
        else:
            return True
    return wrapper

@with_cursor
def get_auth_user_by_id (cur, user_id):
    cur.execute("SELECT * FROM auth_users WHERE auth_id=?", (user_id, ))

    res = cur.fetchone()

    if res:
        return res

@with_cursor
def get_auth_user_by_name (cur, user_name):
    cur.execute("SELECT * FROM auth_users WHERE lower(auth_name)=lower(?)", (user_name, ))

    res = cur.fetchone()

    if res:
        return res

@with_cursor
def get_auth_roles_for_user(cur, user_id):
    cur.execute(
        """
        SELECT aur.auth_role, aur.auth_guild, g.guild_shortname
        FROM auth_user_roles aur
        LEFT JOIN guilds g ON g.guild_id = aur.auth_guild
        WHERE aur.auth_user=?
        ORDER BY aur.auth_role, aur.auth_guild
        """,
        (user_id,)
    )
    return cur.fetchall()

@with_cursor
def get_all_auth_users(cur):
    cur.execute(
        """
        SELECT auth_id, auth_name, auth_must_change_password, auth_timezone, auth_datetime_format
        FROM auth_users
        ORDER BY lower(auth_name), auth_id
        """
    )
    return cur.fetchall()

@with_cursor_boolean
def add_auth_role_to_user(cur, user_id, role_name, auth_guild_id=None):
    cur.execute(
        "INSERT OR IGNORE INTO auth_user_roles (auth_user, auth_role, auth_guild) VALUES (?, ?, ?)",
        (user_id, role_name, auth_guild_id)
    )

@with_cursor_boolean
def remove_auth_role_from_user(cur, user_id, role_name, auth_guild_id=None):
    if auth_guild_id is None:
        cur.execute(
            "DELETE FROM auth_user_roles WHERE auth_user=? AND auth_role=? AND auth_guild IS NULL",
            (user_id, role_name)
        )
    else:
        cur.execute(
            "DELETE FROM auth_user_roles WHERE auth_user=? AND auth_role=? AND auth_guild=?",
            (user_id, role_name, auth_guild_id)
        )

@with_cursor_boolean
def delete_auth_user(cur, user_id):
    cur.execute("DELETE FROM auth_user_roles WHERE auth_user=?", (user_id,))
    cur.execute("DELETE FROM auth_users WHERE auth_id=?", (user_id,))

@with_cursor_row("count(*)")
def count_auth_roles(cur, role_name, auth_guild_id=None):
    if auth_guild_id is None:
        cur.execute(
            "SELECT count(*) FROM auth_user_roles WHERE auth_role=? AND auth_guild IS NULL",
            (role_name,)
        )
    else:
        cur.execute(
            "SELECT count(*) FROM auth_user_roles WHERE auth_role=? AND auth_guild=?",
            (role_name, auth_guild_id)
        )
    return cur.fetchone()

# Unlike other methods which will just be dicts, this is dicks
@with_cursor_boolean
def save_auth_user_info (cur, user):
    cur = cursor()

    if not user.id:
        # it's an insert!
        cur.execute(
            "INSERT INTO auth_users (auth_name, auth_password, auth_must_change_password, auth_timezone, auth_datetime_format) VALUES (?, ?, ?, ?, ?)",
            (
                user.name,
                user.password,
                int(getattr(user, "must_change_password", False)),
                getattr(user, "timezone", None),
                getattr(user, "datetime_format", "us_12") or "us_12",
            )
        )
    else:
        cur.execute(
            "UPDATE auth_users SET auth_name=?, auth_password=?, auth_must_change_password=?, auth_timezone=?, auth_datetime_format=? WHERE auth_id=?",
            (
                user.name,
                user.password,
                int(getattr(user, "must_change_password", False)),
                getattr(user, "timezone", None),
                getattr(user, "datetime_format", "us_12") or "us_12",
                user.id,
            )
        )

@with_cursor_boolean
def update_auth_user_password(cur, user_id, password_hash, must_change_password):
    cur.execute(
        "UPDATE auth_users SET auth_password=?, auth_must_change_password=? WHERE auth_id=?",
        (password_hash, int(bool(must_change_password)), user_id)
    )

@with_cursor_boolean
def update_auth_user_preferences(cur, user_id, timezone_value, datetime_format):
    cur.execute(
        "UPDATE auth_users SET auth_timezone=?, auth_datetime_format=? WHERE auth_id=?",
        (timezone_value, datetime_format, user_id)
    )

############# ACTUAL METHODS ##############

## for the guild roster

@with_cursor_row("guild_roster")
def get_guild_roster (cur, guild_id):
    cur.execute("SELECT * FROM guilds WHERE guild_id=?", (guild_id, ))
    return cur.fetchone()

@with_cursor_boolean
def set_guild_roster (cur, guild_id, roster):
    cur.execute("UPDATE guilds SET guild_roster=? WHERE guild_id=?", (roster, guild_id))

@with_cursor_boolean
def set_guild_settings (cur, guild_id, guild_name=None, guild_shortname=None, guild_eso_id=None, guild_expected_mail_accounts=None, guild_import_blacklist=None, guild_timezone=None, guild_game_server=None, guild_logo_url=None, guild_favicon_url=None, guild_primary_color=None, guild_accent_color=None, guild_sister_guilds=None):
    cur.execute(
        "UPDATE guilds SET guild_name=?, guild_shortname=?, guild_eso_id=?, guild_expected_mail_accounts=?, guild_import_blacklist=?, guild_timezone=?, guild_game_server=?, guild_logo_url=?, guild_favicon_url=?, guild_primary_color=?, guild_accent_color=?, guild_sister_guilds=? WHERE guild_id=?",
        (guild_name, guild_shortname, guild_eso_id, guild_expected_mail_accounts, guild_import_blacklist, guild_timezone, guild_game_server, guild_logo_url, guild_favicon_url, guild_primary_color, guild_accent_color, guild_sister_guilds, guild_id)
    )

@with_cursor
def set_guild_sister_guilds (cur, target_guild_id, guild_sister_guilds):
    cur.execute(
        "UPDATE guilds SET guild_sister_guilds=? WHERE guild_id=?",
        (guild_sister_guilds, target_guild_id)
    )

@with_cursor
def get_barter_bounty_items(cur, guild_id):
    cur.execute(
        """
        SELECT *
        FROM barter_bounty_items
        WHERE barter_bounty_guild=?
        ORDER BY barter_bounty_sort, barter_bounty_item_id
        """,
        (guild_id,)
    )
    return cur.fetchall()

@with_cursor_boolean
def replace_barter_bounty_items(cur, guild_id, items):
    cur.execute("DELETE FROM barter_bounty_items WHERE barter_bounty_guild=?", (guild_id,))
    for index, item in enumerate(items, start=1):
        cur.execute(
            """
            INSERT INTO barter_bounty_items
                (barter_bounty_guild, barter_bounty_item_name, barter_bounty_item_code,
                 barter_bounty_quantity, barter_bounty_value, barter_bounty_rate,
                 barter_bounty_sort, barter_bounty_active)
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                guild_id,
                item.get("item_name", ""),
                item.get("item_code", ""),
                item.get("quantity", 1),
                item.get("item_value", 0),
                item.get("barter_rate", 0),
                index,
                1 if item.get("active", 1) else 0,
            )
        )

@with_cursor
def get_raffle_bounty_items(cur, guild_id, raffle_id):
    cur.execute(
        """
        SELECT *
        FROM raffle_bounty_items
        WHERE raffle_bounty_raffle=?
        ORDER BY raffle_bounty_sort, raffle_bounty_item_id
        """,
        (raffle_id,)
    )
    return cur.fetchall()

@with_cursor_boolean
def replace_raffle_bounty_items(cur, guild_id, raffle_id, items):
    cur.execute("DELETE FROM raffle_bounty_items WHERE raffle_bounty_raffle=?", (raffle_id,))
    for index, item in enumerate(items, start=1):
        cur.execute(
            """
            INSERT INTO raffle_bounty_items
                (raffle_bounty_raffle, raffle_bounty_source_item, raffle_bounty_item_name, raffle_bounty_item_code,
                 raffle_bounty_quantity, raffle_bounty_value, raffle_bounty_rate, raffle_bounty_sort)
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                raffle_id,
                item.get("barter_bounty_item_id"),
                item.get("item_name", ""),
                item.get("item_code", ""),
                item.get("quantity", 1),
                item.get("item_value", 0),
                item.get("barter_rate", 0),
                index,
            )
        )

@with_cursor_boolean
def record_barter_entry(cur, guild_id, user_name, source_type, source_uid, source_timestamp, item_name, item_code, quantity, item_value, rate, ticket_count, import_uid=None):
    raffle_id = gcri()
    if not raffle_id:
        return False

    user = get_user_by_name(user_name)
    if not user:
        user_id = add_user(user_name)
    else:
        user_id = user["user_id"]

    cur.execute(
        """
        INSERT OR IGNORE INTO barter_entries
            (barter_entry_raffle, barter_entry_guild, barter_entry_user, barter_entry_source_type,
             barter_entry_source_uid, barter_entry_source_timestamp, barter_entry_item_name,
             barter_entry_item_code, barter_entry_quantity, barter_entry_item_value,
             barter_entry_rate, barter_entry_ticket_count, barter_entry_import_uid)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            raffle_id,
            guild_id,
            user_id,
            source_type,
            source_uid,
            source_timestamp,
            item_name,
            item_code,
            quantity,
            item_value,
            rate,
            ticket_count,
            import_uid,
        )
    )
    return True

@with_cursor
def get_barter_entries(cur, guild_id, raffle_id=None):
    target_raffle_id = raffle_id or gcri()
    if not target_raffle_id:
        return []

    cur.execute(
        """
        SELECT be.*, u.user_name
        FROM barter_entries be
        LEFT JOIN users u ON u.user_id = be.barter_entry_user
        WHERE be.barter_entry_raffle=? AND be.barter_entry_guild=?
        ORDER BY be.barter_entry_item_name, be.barter_entry_id
        """,
        (target_raffle_id, guild_id)
    )
    return cur.fetchall()

@with_cursor
def get_barter_summary(cur, guild_id, raffle_id=None):
    target_raffle_id = raffle_id or gcri()
    if not target_raffle_id:
        return []

    cur.execute(
        """
        SELECT
            barter_entry_item_name,
            barter_entry_item_code,
            SUM(barter_entry_quantity) AS total_bartered,
            SUM(barter_entry_item_value) AS total_row_value,
            SUM(barter_entry_ticket_count) AS total_tickets
        FROM barter_entries
        WHERE barter_entry_raffle=? AND barter_entry_guild=?
        GROUP BY lower(barter_entry_item_code), barter_entry_item_name
        ORDER BY lower(barter_entry_item_name)
        """,
        (target_raffle_id, guild_id)
    )
    return cur.fetchall()

## other guild info

@with_cursor
def get_guild_by_id (cur, guild_id):
    cur.execute("SELECT * FROM guilds WHERE guild_id=?", (guild_id, ))
    return cur.fetchone()

@with_cursor
def get_guild_by_name (cur, guild_name):
    cur.execute("SELECT * FROM guilds WHERE guild_name=?", (guild_name, ))
    return cur.fetchone()

@with_cursor
def get_guild_by_shortname (cur, guild_name):
    cur.execute("SELECT * FROM guilds WHERE guild_shortname LIKE ?", (guild_name, ))
    return cur.fetchone()

@with_cursor
def get_guild_ticket_cost (cur, guild_id):
    cur_id = gcri()
    if not cur_id:
        return None

    cur.execute("SELECT * FROM raffles WHERE raffle_id=?", (cur_id, ))

    res = cur.fetchone()
    if not res:
        return None

    return res["raffle_ticket_cost"]

# DON'T WRAP THIS EVER UNLESS YOU WANT RECUUUUUUUUUUURRRRSION
def get_guild_id_by_name (cur, guild_name):
    cur.execute("SELECT guild_id FROM guilds WHERE guild_shortname LIKE ?", (guild_name.lower(), ))
    res = cur.fetchone()
    if res:
        return res["guild_id"]
    
    return None

def get_raffle_id_by_number (cur, guild_id, raffle_number):
    cur.execute("SELECT raffle_id FROM raffles WHERE raffle_guild=? AND raffle_guild_num=?", (guild_id, raffle_number))
    res = cur.fetchall()

    # Return the first matching raffle ID if found
    if res:
        return res[0]["raffle_id"]

    return None

# Database utility functions

@with_cursor_row("raf_id")
def get_cur_raffle_id (cur, guild_id, raf_id=None):
    if raf_id is not None:
        return {"raf_id": raf_id}

    cur.execute("SELECT MAX(raffle_id) AS raf_id FROM raffles WHERE raffle_guild=? AND raffle_closed=0", (guild_id, ))
    return cur.fetchone()

@with_cursor_boolean
def close_raffle_by_id (cur, raffle_id):
    cur.execute("UPDATE raffles SET raffle_closed=1 WHERE raffle_id=?", (raffle_id, ))

@with_cursor_boolean
def create_new_raffle (cur, guild_id, raffle_info=None):
    raffle_info = raffle_info or {}

    cur.execute(
        """
        INSERT INTO raffles
            (raffle_guild, raffle_guild_num, raffle_opened_at, raffle_time, raffle_ticket_cost, raffle_closed,
             raffle_notes, raffle_title, raffle_status, raffle_barter_enabled,
             raffle_gold_mail_enabled, raffle_gold_bank_enabled, raffle_barter_mail_enabled, raffle_barter_bank_enabled,
             raffle_notes_admin, raffle_notes_public_2)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            guild_id,
            raffle_info.get("raffle_guild_num", 0),
            raffle_info.get("raffle_opened_at", int(time.time())),
            raffle_info.get("raffle_time", "Time here"),
            raffle_info.get("raffle_ticket_cost", "Ticket cost"),
            raffle_info.get("raffle_closed", 0),
            raffle_info.get("raffle_notes", ""),
            raffle_info.get("raffle_title", ""),
            raffle_info.get("raffle_status", "LIVE"),
            raffle_info.get("raffle_barter_enabled", 0),
            raffle_info.get("raffle_gold_mail_enabled", 1),
            raffle_info.get("raffle_gold_bank_enabled", 1),
            raffle_info.get("raffle_barter_mail_enabled", 0),
            raffle_info.get("raffle_barter_bank_enabled", 0),
            raffle_info.get("raffle_notes_admin", ""),
            raffle_info.get("raffle_notes_public_2", "")
        )
    )

@with_cursor
def get_prizes_by_raffle_id(cur, raffle_id):
    ensure_prize_columns(cur)
    cur.execute("SELECT * FROM prizes WHERE prize_raffle=? ORDER BY prize_sort, prize_id", (raffle_id,))
    return cur.fetchall()

@with_cursor_boolean
def clone_prizes_to_raffle(cur, guild_id, source_raffle_id, target_raffle_id):
    ensure_prize_columns(cur)
    cur.execute("SELECT * FROM prizes WHERE prize_raffle=? ORDER BY prize_sort, prize_id", (source_raffle_id,))
    prizes = cur.fetchall()
    if not prizes:
        return True

    for index, prize in enumerate(prizes, start=1):
        cur.execute(
            """
            INSERT INTO prizes
                (prize_raffle, prize_text, prize_text2, prize_winner, prize_finalised, prize_value, prize_style, prize_sort)
            VALUES
                (?, ?, ?, 0, 0, ?, ?, ?)
            """,
            (
                target_raffle_id,
                prize["prize_text"] or "",
                prize["prize_text2"] or "",
                prize["prize_value"],
                prize["prize_style"] if "prize_style" in prize.keys() else "standard",
                index,
            )
        )

gcri = get_cur_raffle_id

@with_cursor
def get_last_update_info (cur, guild_id):
    cur_id = gcri()
    if not cur_id:
        return None

    cur.execute(
        """
        SELECT
            t.ticket_timestamp AS timestamp,
            au.auth_name AS updated_by
        FROM tickets t
        LEFT JOIN auth_users au ON au.auth_id = t.ticket_updated_by_auth
        WHERE t.ticket_raffle=? AND t.ticket_timestamp IS NOT NULL AND t.ticket_timestamp > 0
        ORDER BY t.ticket_timestamp DESC, t.ticket_id DESC
        LIMIT 1
        """,
        (cur_id,)
    )
    return cur.fetchone()

@with_cursor
def get_cur_raffle_info (cur, guild_id):
    cur_id = gcri()
    if not cur_id:
        return None

    cur.execute("SELECT * FROM raffles WHERE raffle_id=?", (cur_id, ))
    return cur.fetchone()



@with_cursor
def get_raffle_info_by_id(cur, guild_id, raf_id=None):
    if not raf_id:
        return None

    cur.execute("SELECT * FROM raffles WHERE raffle_id=? AND raffle_guild=?", (raf_id, guild_id))
    return cur.fetchone()

@with_cursor
def get_tickets_by_raffle_id(cur, guild_id, raf_id=None):
    if not raf_id:
        return []

    cur.execute("SELECT tickets.*, user_name AS ticket_user_name FROM tickets LEFT JOIN users ON ticket_user=user_id WHERE ticket_raffle=?", (raf_id, ))
    res = cur.fetchall()

    if not res:
        return []

    return res

@with_cursor
def resolve_raffle_lookup_code(cur, guild_id, raffle_code):
    code = str(raffle_code or "").strip()
    if not code:
        return None

    cur.execute("SELECT raffle_guild_num FROM raffles WHERE raffle_guild=? AND raffle_guild_num=?", (guild_id, code))
    res = cur.fetchone()
    if res:
        return res["raffle_guild_num"]

    if re.search(r"[A-Za-z]", code):
        return None

    cur.execute("SELECT raffle_guild_num FROM raffles WHERE raffle_guild=? AND raffle_guild_num LIKE ? ORDER BY raffle_id DESC", (guild_id, code + "%"))
    matches = cur.fetchall()

    if len(matches) == 1:
        return matches[0]["raffle_guild_num"]

    return None

@with_cursor_boolean
def set_cur_raffle_info (cur, guild_id, raffle_info):
    cur_id = gcri()
    if not cur_id:
        return False

    r = raffle_info

    cur.execute(
        """
        UPDATE raffles
           SET raffle_guild=?,
               raffle_guild_num=?,
               raffle_opened_at=?,
               raffle_time=?,
               raffle_ticket_cost=?,
               raffle_closed=?,
               raffle_notes=?,
               raffle_title=?,
               raffle_status=?,
               raffle_barter_enabled=?,
               raffle_gold_mail_enabled=?,
               raffle_gold_bank_enabled=?,
               raffle_barter_mail_enabled=?,
               raffle_barter_bank_enabled=?,
               raffle_notes_admin=?,
               raffle_notes_public_2=?
         WHERE raffle_id=?
        """,
        (
            r["raffle_guild"],
            r["raffle_guild_num"],
            r.get("raffle_opened_at", int(time.time())),
            r["raffle_time"],
            r["raffle_ticket_cost"],
            r["raffle_closed"],
            r["raffle_notes"],
            r.get("raffle_title", ""),
            r.get("raffle_status", "LIVE"),
            r.get("raffle_barter_enabled", 0),
            r.get("raffle_gold_mail_enabled", 1),
            r.get("raffle_gold_bank_enabled", 1),
            r.get("raffle_barter_mail_enabled", 0),
            r.get("raffle_barter_bank_enabled", 0),
            r.get("raffle_notes_admin", ""),
            r.get("raffle_notes_public_2", ""),
            cur_id
        )
    )

@with_cursor_boolean
def close_current_raffle (cur, guild_id):
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("UPDATE raffles SET raffle_closed=1 WHERE raffle_id=?", (cur_id, ))

@with_cursor_boolean
def open_new_raffle (cur, guild_id, raffle_info=None):
    raffle_info = raffle_info or {}

    cur.execute(
        """
        INSERT INTO raffles
            (raffle_guild, raffle_guild_num, raffle_opened_at, raffle_time, raffle_ticket_cost, raffle_closed,
             raffle_notes, raffle_title, raffle_status, raffle_barter_enabled,
             raffle_gold_mail_enabled, raffle_gold_bank_enabled, raffle_barter_mail_enabled, raffle_barter_bank_enabled,
             raffle_notes_admin, raffle_notes_public_2)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            guild_id,
            raffle_info.get("raffle_guild_num", 0),
            raffle_info.get("raffle_opened_at", int(time.time())),
            raffle_info.get("raffle_time", "Fill this in!"),
            raffle_info.get("raffle_ticket_cost", "1000g"),
            raffle_info.get("raffle_closed", 0),
            raffle_info.get("raffle_notes", ""),
            raffle_info.get("raffle_title", ""),
            raffle_info.get("raffle_status", "LIVE"),
            raffle_info.get("raffle_barter_enabled", 0),
            raffle_info.get("raffle_gold_mail_enabled", 1),
            raffle_info.get("raffle_gold_bank_enabled", 1),
            raffle_info.get("raffle_barter_mail_enabled", 0),
            raffle_info.get("raffle_barter_bank_enabled", 0),
            raffle_info.get("raffle_notes_admin", ""),
            raffle_info.get("raffle_notes_public_2", "")
        )
    )

# users
@with_cursor
def get_user_by_id (cur, user_id):
    cur.execute("SELECT * FROM users WHERE user_id=?", (user_id, ))
    return cur.fetchone()

@with_cursor
def get_user_by_name (cur, user_name):
    cur.execute("SELECT * FROM users WHERE user_name=?", (user_name, ))
    return cur.fetchone()

@with_cursor_rowid
def add_user (cur, user_name):
    cur.execute("INSERT INTO users VALUES (null, ?)", (user_name, ))

# ticket schmicket lemony snicket

@with_cursor
def get_tickets (cur, guild_id):
    # using current raffle
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("SELECT tickets.*, user_name AS ticket_user_name FROM tickets LEFT JOIN users ON ticket_user=user_id WHERE ticket_raffle=?", (cur_id, ))

    res = cur.fetchall()

    if not res:
        return []

    return res

@with_cursor
def get_user_tickets (cur, guild_id, user_name):
    cur_id = gcri()
    if not cur_id:
        return False

    u = get_user_by_name(user_name)
    if not u:
        return False

    u = u["user_id"]

    cur.execute("SELECT * FROM tickets WHERE ticket_raffle=? AND ticket_user=?", (cur_id, u))
    return cur.fetchone()

@with_cursor
def get_import_by_id (cur, uid, guild=0):
    if guild == 0:
        cur.execute("SELECT * FROM imports WHERE import_uid=?", (uid, ))
    else:
        cur.execute("SELECT * FROM imports WHERE import_uid=? AND (import_guild=? OR import_guild is null)", (uid, guild, ))

    res = cur.fetchall()

    return res

@with_cursor_boolean
def record_import (cur, uid, timestamp, skipped=0, guild=0):
    cur.execute("INSERT INTO imports VALUES (NULL, ?, ?, ?, ?)", (uid, timestamp, skipped, guild))

@with_cursor_boolean
def clear_imports (cur):
    cur.execute("DELETE FROM imports")

@with_cursor_boolean
def set_user_tickets (cur, guild_id, user_name, ticket_count, ticket_free=0, ticket_barter=0, updated_by_auth=None):
    cur_id = gcri()
    if not cur_id:
        return False

    u = get_user_by_name(user_name)
    if not u:
        u = add_user(user_name)
    else:
        u = u["user_id"]

    ts = int(time.time())

    pot_raf = cur.execute("SELECT * FROM tickets WHERE ticket_raffle=? AND ticket_user=?", (cur_id, u))
    res = pot_raf.fetchone()
    if not res:
        cur.execute(
            "INSERT INTO tickets VALUES (null, ?, ?, ?, ?, ?, ?, ?)",
            (cur_id, u, ticket_count, ts, updated_by_auth, ticket_free, ticket_barter)
        )
    else:
        cur.execute(
            "UPDATE tickets SET ticket_count=?, ticket_timestamp=?, ticket_updated_by_auth=?, ticket_free=?, ticket_barter=? WHERE ticket_raffle=? AND ticket_user=?",
            (ticket_count, ts, updated_by_auth, ticket_free, ticket_barter, cur_id, u)
        )

@with_cursor_boolean
def fix_dupes (cur):
    cur.execute("SELECT user_name,count(user_name) AS user_count FROM users GROUP BY user_name")
    res = cur.fetchall()

    names = []

    for u, count in res:
        if count == 1:
            continue

        names.append(u)

    if not names:
        return False

    ids = []

    for name in names:
        cur.execute("SELECT user_id FROM users WHERE user_name=?", (name, ))
        res = cur.fetchall()[1:]
        for r in res:
            ids.append(r["user_id"])

    for u_id in ids:
        cur.execute("DELETE FROM tickets WHERE ticket_user=?", (u_id, ))
        cur.execute("DELETE FROM users WHERE user_id=?", (u_id, ))

    return True

@with_cursor
def get_all_prizes (cur, guild_id):
    ensure_prize_columns(cur)
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("SELECT * FROM prizes WHERE prize_raffle=? ORDER BY prize_sort, prize_id", (cur_id, ))

    return cur.fetchall()

@with_cursor_boolean
def add_new_prize (cur, guild_id):
    ensure_prize_columns(cur)
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("SELECT COALESCE(MAX(prize_sort), 0) AS max_sort FROM prizes WHERE prize_raffle=?", (cur_id,))
    next_sort = (cur.fetchone()["max_sort"] or 0) + 1

    cur.execute(
        """
        INSERT INTO prizes
            (prize_raffle, prize_text, prize_text2, prize_winner, prize_finalised, prize_value, prize_style, prize_sort)
        VALUES
            (?, '', '?', 0, 0, NULL, 'standard', ?)
        """,
        (cur_id, next_sort)
    )

@with_cursor_boolean
def clone_last_prize(cur, guild_id):
    ensure_prize_columns(cur)
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("SELECT * FROM prizes WHERE prize_raffle=? ORDER BY prize_sort DESC, prize_id DESC LIMIT 1", (cur_id,))
    source = cur.fetchone()
    if not source:
        return False

    cur.execute("SELECT COALESCE(MAX(prize_sort), 0) AS max_sort FROM prizes WHERE prize_raffle=?", (cur_id,))
    next_sort = (cur.fetchone()["max_sort"] or 0) + 1

    cur.execute(
        """
        INSERT INTO prizes
            (prize_raffle, prize_text, prize_text2, prize_winner, prize_finalised, prize_value, prize_style, prize_sort)
        VALUES
            (?, ?, ?, 0, 0, ?, ?, ?)
        """,
        (
            cur_id,
            source["prize_text"] or "",
            "",
            source["prize_value"],
            source["prize_style"] if "prize_style" in source.keys() else "standard",
            next_sort,
        )
    )

@with_cursor_boolean
def clone_prize_below(cur, guild_id, prize_id):
    ensure_prize_columns(cur)
    cur_id = gcri()
    if not cur_id:
        return False

    cur.execute("SELECT * FROM prizes WHERE prize_id=? AND prize_raffle=?", (prize_id, cur_id))
    source = cur.fetchone()
    if not source:
        return False

    source_sort = source["prize_sort"] or 0
    cur.execute("UPDATE prizes SET prize_sort = prize_sort + 1 WHERE prize_raffle=? AND prize_sort > ?", (cur_id, source_sort))
    cur.execute(
        """
        INSERT INTO prizes
            (prize_raffle, prize_text, prize_text2, prize_winner, prize_finalised, prize_value, prize_style, prize_sort)
        VALUES
            (?, ?, ?, 0, 0, ?, ?, ?)
        """,
        (
            cur_id,
            source["prize_text"] or "",
            "",
            source["prize_value"],
            source["prize_style"] if "prize_style" in source.keys() else "standard",
            source_sort + 1,
        )
    )

@with_cursor_boolean
def delete_prize (cur, prize_id):
    ensure_prize_columns(cur)
    # no going-backsies!
    cur.execute("DELETE FROM prizes WHERE prize_id=?", (prize_id, ))

@with_cursor_boolean
def finalise_prize (cur, prize_id):
    ensure_prize_columns(cur)
    # no going-backsies!
    cur.execute("SELECT * FROM prizes WHERE prize_id=?", (prize_id, ))
    res = cur.fetchone()
    if not res:
        return False

    # can't finalise if no winner
    try:
        if res["prize_winner"] == 0:
            return False
    except:
        raise Exception(res
)

    cur.execute("UPDATE prizes SET prize_finalised=1 WHERE prize_id=?", (prize_id, ))

@with_cursor_boolean
def unfinalise_prize (cur, prize_id):
    ensure_prize_columns(cur)
    cur.execute("SELECT * FROM prizes WHERE prize_id=?", (prize_id, ))
    res = cur.fetchone()
    if not res:
        return False

    cur.execute("UPDATE prizes SET prize_finalised=0 WHERE prize_id=?", (prize_id, ))

@with_cursor
def get_prize (cur, prize_id):
    ensure_prize_columns(cur)
    cur.execute("SELECT * FROM prizes WHERE prize_id=?", (prize_id, ))

    return cur.fetchone()

@with_cursor_boolean
def set_prize (cur, guild_id, prize_info):
    ensure_prize_columns(cur)
    p = prize_info

    # it will ALWAYS have a prize id, if not FAIL
    # it might NOT have a prize_id
    #if p["prize_id"] is None:
        #i = add_new_prize(guild_id)
        #if not i:
            #return False
    #
        #p["prize_id"] = i

    if p["prize_id"] is None:
        return False
    
    cur.execute(
        """
        UPDATE prizes
           SET prize_raffle=?,
               prize_text=?,
               prize_text2=?,
               prize_winner=?,
               prize_finalised=?,
               prize_value=?,
               prize_style=?
         WHERE prize_id=?
        """,
        (
            p["prize_raffle"],
            p["prize_text"],
            p["prize_text2"],
            p["prize_winner"],
            p["prize_finalised"],
            p.get("prize_value"),
            p.get("prize_style", "standard"),
            p["prize_id"]
        )
    )

def ensure_prize_columns(cur):
    cur.execute("PRAGMA table_info(prizes)")
    existing_columns = {row[1] for row in cur.fetchall()}

    if "prize_value" not in existing_columns:
        cur.execute("ALTER TABLE prizes ADD COLUMN prize_value INTEGER")

    if "prize_style" not in existing_columns:
        cur.execute("ALTER TABLE prizes ADD COLUMN prize_style TEXT DEFAULT 'standard'")

    if "prize_sort" not in existing_columns:
        cur.execute("ALTER TABLE prizes ADD COLUMN prize_sort INTEGER DEFAULT 0")

    cur.execute("SELECT prize_id, prize_raffle FROM prizes WHERE COALESCE(prize_sort, 0)=0 ORDER BY prize_raffle, prize_id")
    rows = cur.fetchall()
    if rows:
        next_sort_by_raffle = {}
        for row in rows:
            raffle_id = row["prize_raffle"]
            if raffle_id not in next_sort_by_raffle:
                cur.execute("SELECT COALESCE(MAX(prize_sort), 0) AS max_sort FROM prizes WHERE prize_raffle=?", (raffle_id,))
                next_sort_by_raffle[raffle_id] = cur.fetchone()["max_sort"] or 0
            next_sort_by_raffle[raffle_id] += 1
            cur.execute("UPDATE prizes SET prize_sort=? WHERE prize_id=?", (next_sort_by_raffle[raffle_id], row["prize_id"]))
