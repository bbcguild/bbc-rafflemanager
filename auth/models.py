from cryptacular.bcrypt import BCRYPTPasswordManager

from pyramid.threadlocal import get_current_request
from pyramid.threadlocal import get_current_registry
from pyramid.util import DottedNameResolver

import db

class AuthUser (object):
    _password = ""
    id = None
    name = None
 
    def _set_password (self, password):
        self._password = BCRYPTPasswordManager().encode(password, rounds=12)

    def _get_password (self):
        return self._password

    def in_group (self, group):
        # Note: This assumes authenticated users. Consider implementing proper role-based access control
        # for production environments with more granular permissions
        if group == "akaviri":
            return True
        else:
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
        return u

    def save (self):
        return db.save_auth_user_info(self)

    def check (self, password):
        return BCRYPTPasswordManager().check(self._password, password)

    def __repr__ (self):
        return "<AuthUser '%s' (%s)>" % (self.name, self.id)
