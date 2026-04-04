import base64
import hmac
import time

from wtforms import StringField  # TextField was renamed to StringField
from wtforms import validators
# from wtforms.ext.sqlalchemy.orm import model_form  # This extension is no longer available in modern WTForms

from pyramid.httpexceptions import HTTPFound
from pyramid.i18n import TranslationString as _
from pyramid.response import Response
from pyramid.security import Allow
from pyramid.security import Authenticated
from pyramid.security import Everyone
from pyramid.security import forget
from pyramid.settings import asbool
from pyramid.url import current_route_url
from pyramid.url import route_url

from auth.lib.libapex import apex_settings, apex_remember, get_module
from auth.lib.flash import flash
from auth.lib.form import ExtendedForm
from auth.models import AuthUser
from auth.forms import LoginForm

ADMIN_HOST = "raffle-admin.bbcguild.com"
PUBLIC_HOSTS = {"raffles.bbcguild.com", "raffle.bbcguild.com", "tickets.bbcguild.com"}

def _request_host(request):
    return (request.host or "").split(":", 1)[0].strip().lower()

def _redirect_to_host(request, target_host, path=None, query_string=None):
    scheme = request.scheme or "https"
    path = path if path is not None else request.path
    query_string = request.query_string if query_string is None else query_string
    location = "%s://%s%s" % (scheme, target_host, path)
    if query_string:
        location += "?" + query_string
    return HTTPFound(location=location)

def login(request):
    """ login(request): User login.
    Function called from route_url('apex_login', request)
    """
    title = _('Login')

    host = _request_host(request)
    if host in PUBLIC_HOSTS:
        return _redirect_to_host(request, ADMIN_HOST, path=request.path, query_string=request.query_string)
    
    # Get came_from with fallback
    try:
        default_route = apex_settings('came_from_route', 'home')
        came_from = request.GET.get('came_from', route_url(default_route, request))
    except:
        # Fallback to a simple redirect if route resolution fails
        came_from = request.GET.get('came_from', '/bbc2/')

    if 'local' not in apex_settings('provider_exclude', []):
        form = LoginForm(request.POST, \
                   captcha={'ip_address': request.environ['REMOTE_ADDR']})
    else:
        form = None
    
    if request.method == 'POST' and form and form.validate():
        username = form.data.get('username')
        password = form.data.get('password')
        
        user = AuthUser.find_by_name(username)
        
        if user and user.check(password):
            headers = apex_remember(request, user.id)
            return HTTPFound(location=came_from, headers=headers)
        else:
            flash(_('Invalid username or password'), 'error')
    elif request.method == 'POST':
        flash(_('Please fill in all required fields'), 'error')

    return {'title': title, 'form': form, 'action': 'login'}

def logout(request):
    """ logout(request):
    no return value, called with route_url('apex_logout', request)
    """
    headers = forget(request)
    return HTTPFound(location=route_url(apex_settings('came_from_route'), \
                     request), headers=headers)

def forbidden(request):
    """ forbidden(request)
    No return value

    Called when user hits a resource that requires a permission and the
    user doesn't have the required permission. Will prompt for login.

    request.environ['repoze.bfg.message'] contains our forbidden error in case
    of a csrf problem. Proper solution is probably an error page that
    can be customized.

    bfg.routes.route and repoze.bfg.message are scheduled to be deprecated,
    however, corresponding objects are not present in the request to be able
    to determine why the Forbidden exception was called.

    **THIS WILL BREAK EVENTUALLY**
    """
    if request.matched_route:
        flash(_('Not logged in, please log in'), 'error')
        try:
            login_url = route_url('apex_login', request)
            current_url = current_route_url(request)
            return HTTPFound(location='%s?came_from=%s' % (login_url, current_url))
        except:
            # Fallback if route resolution fails
            return HTTPFound(location='/bbc2/auth/login')
    else:
        return Response('Access denied - please log in')
