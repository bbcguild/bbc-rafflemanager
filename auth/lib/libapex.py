try:
    import json
except ImportError:
    import simplejson as json

try:
    # Python 2
    import urlparse
except ImportError:
    # Python 3
    import urllib.parse as urlparse

from pyramid.httpexceptions import HTTPFound
from pyramid.i18n import TranslationString as _
from pyramid.security import Allow
from pyramid.security import Everyone
from pyramid.security import Authenticated
from pyramid.security import remember
from pyramid.settings import asbool
from pyramid.threadlocal import get_current_registry
from pyramid.url import route_url
from pyramid.util import DottedNameResolver

from auth.models import AuthUser

def groupfinder(userid, request):
    """ Returns ACL formatted list of groups for the userid in the 
    current request
    """
    auth = AuthUser.find_by_id(userid)
    if auth:
        return ['group:akaviri']

class RootFactory(object):
    """ Defines the default ACLs, groups populated from SQLAlchemy.
    """
    def __init__(self, request):
        if request.matchdict:
            self.__dict__.update(request.matchdict)

    @property
    def __acl__(self):
        defaultlist = [ (Allow, Everyone, 'view'),
                (Allow, Authenticated, 'authenticated'),]
        defaultlist.append( (Allow, 'group:akaviri', 'akaviri') )
        return defaultlist

def apex_email(request, recipients, subject, body, sender=None):
    """ Sends email message
    """
    raise Exception("Don't call this")

def apex_settings(key=None, default=None):
    """ Gets an apex setting if the key is set.
        If no key it set, returns all the apex settings.
        
        Some settings have issue with a Nonetype value error,
        you can set the default to fix this issue.        
    """
    settings = get_current_registry().settings

    if key:
        return settings.get('apex.%s' % key, default)
    else:
        apex_settings = []
        for k, v in settings.items():
            if k.startswith('apex.'):
                apex_settings.append({k.split('.')[1]: v})

        return apex_settings

def create_user(**kwargs):
    """
::

    from apex.lib.libapex import create_user

    create_user(username='test', password='my_password', active='Y', group='group')

    Returns: AuthUser object

    Maybe don't call this.
    """
    user = AuthUser()

    if 'group' in kwargs:
        try:
            group = AuthGroup.find_by_name(kwargs['group'])

            user.groups.append(group)
        except NoResultFound:
            pass

        del kwargs['group']

    for key, value in kwargs.items():
        setattr(user, key, value)
    
    user.save()
    return user

def get_module(package):
    """ Returns a module based on the string passed
    """
    resolver = DottedNameResolver(package.split('.', 1)[0])
    return resolver.resolve(package)

def apex_remember(request, user_id):
    if asbool(apex_settings('log_logins')):
        if apex_settings('log_login_header'):
            ip_addr=request.environ.get(apex_settings('log_login_header'), \
                    u'invalid value - apex.log_login_header')
        else:
             ip_addr=request.environ['REMOTE_ADDR']
    return remember(request, user_id)
