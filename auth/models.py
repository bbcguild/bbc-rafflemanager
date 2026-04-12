from cryptacular.bcrypt import BCRYPTPasswordManager

from pyramid.threadlocal import get_current_request
from pyramid.threadlocal import get_current_registry
from pyramid.util import DottedNameResolver

import db

class AuthUser (object):
    _password = ""
    id = None
    name = None
    roles = None
    must_change_password = False
    timezone = None
    datetime_format = "us_12"
 
    def _set_password (self, password):
        self._password = BCRYPTPasswordManager().encode(password, rounds=12)

    def _get_password (self):
        return self._password

    def in_group (self, group):
        request = get_current_request()
        guild_slug = None
        if request and getattr(request, "matchdict", None):
            guild_slug = request.matchdict.get("guild")

        if group == "owner":
            return self.has_global_role("owner")

        if group == "superadmin":
            return self.has_global_role("owner") or self.has_global_role("superadmin")

        if group == "admin_access":
            if self.has_global_role("owner") or self.has_global_role("superadmin"):
                return True
            if guild_slug:
                return self.has_guild_role("guild_admin", guild_slug)
            return self.has_any_role("guild_admin")

        return False

    password = property(_get_password, _set_password)

    @classmethod
    def check_password(cls, **kwargs):
        if 'id' in kwargs:
            user = cls.find_by_id(kwargs['id'])
        elif 'username' in kwargs:
            user = cls.find_by_name(kwargs['username'])
        else:
            return False

        if not user:
            return False
        if BCRYPTPasswordManager().check(user.password, kwargs['password']):
            return True
        else:
            return False

    @classmethod
    def find_by_id (cls, user_id):
        return cls.make_from_data(db.get_auth_user_by_id(user_id))

    @classmethod
    def find_by_name (cls, user_name):
        return cls.make_from_data(db.get_auth_user_by_name(user_name))

    @classmethod
    def make_from_data (cls, data):
        if not data:
            return None

        u = cls()
        u._password = data["auth_password"] # don't over-encode it
        u.name = data["auth_name"]
        u.id = data["auth_id"]
        u.must_change_password = bool(data["auth_must_change_password"]) if "auth_must_change_password" in data.keys() else False
        u.timezone = data["auth_timezone"] if "auth_timezone" in data.keys() else None
        u.datetime_format = data["auth_datetime_format"] if "auth_datetime_format" in data.keys() and data["auth_datetime_format"] else "us_12"
        role_rows = db.get_auth_roles_for_user(u.id) or []
        u.roles = [{
            "role": row["auth_role"],
            "guild_id": row["auth_guild"],
            "guild_shortname": row["guild_shortname"].lower() if row["guild_shortname"] else None,
        } for row in role_rows]
        return u

    def has_global_role(self, role_name):
        for role in self.roles or []:
            if role["role"] == role_name and role["guild_id"] is None:
                return True
        return False

    def has_guild_role(self, role_name, guild_slug):
        guild_slug = (guild_slug or "").strip().lower()
        if not guild_slug:
            return False
        for role in self.roles or []:
            if role["role"] == role_name and role["guild_shortname"] == guild_slug:
                return True
        return False

    def has_any_role(self, role_name):
        for role in self.roles or []:
            if role["role"] == role_name:
                return True
        return False

    def save (self):
        return db.save_auth_user_info(self)

    def check (self, password):
        return BCRYPTPasswordManager().check(self._password, password)

    def __repr__ (self):
        return "<AuthUser '%s' (%s)>" % (self.name, self.id)
