try:
    from pyramid_mailer.interfaces import IMailer
except ImportError:
    # pyramid_mailer is optional
    IMailer = None

from pyramid.interfaces import IAuthenticationPolicy, IAuthorizationPolicy, ISessionFactory
# UnencryptedCookieSessionFactoryConfig has been removed in modern Pyramid
# We'll use SignedCookieSessionFactory instead
from pyramid.settings import asbool
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.exceptions import Forbidden

from auth import exceptions
from auth.interfaces import ApexImplementation, IApex
from auth.lib.libapex import groupfinder, RootFactory
from auth.views import login, logout, forbidden

def includeme(config):
    settings = config.registry.settings
    
    # Set default apex settings if not configured
    if 'apex.came_from_route' not in settings:
        settings['apex.came_from_route'] = 'home'
    if 'apex.provider_exclude' not in settings:
        settings['apex.provider_exclude'] = []
    settings = config.registry.settings

    config.registry.registerUtility(ApexImplementation, IApex)

    if not config.registry.queryUtility(ISessionFactory):
        if "apex.session_secret" not in settings:
            raise exceptions.ApexSessionSecret()
        
        # Use SignedCookieSessionFactory instead of the deprecated UnencryptedCookieSessionFactoryConfig
        from pyramid.session import SignedCookieSessionFactory
        session_factory = SignedCookieSessionFactory(settings.get('apex.session_secret'))
        config.set_session_factory(session_factory)

    if not config.registry.queryUtility(IAuthenticationPolicy):
        if "apex.auth_secret" not in settings:
            raise exceptions.ApexAuthSecret()
        authn_policy = AuthTktAuthenticationPolicy( \
                       settings.get('apex.auth_secret'), \
                       callback=groupfinder, \
                       cookie_name='auth_tkt', \
                       wild_domain=False)
        config.set_authentication_policy(authn_policy)

    if not config.registry.queryUtility(IAuthorizationPolicy):
        authz_policy = ACLAuthorizationPolicy()
        config.set_authorization_policy(authz_policy)

    cache = RootFactory.__acl__ 
    config.set_root_factory(RootFactory)

    if not config.registry.queryUtility(IMailer):
        config.include('pyramid_mailer')

    # Don't override the mako directories - use the existing ones from pconf.py
    # The login template is already in mako_templates/login_simple.mako
    
    config.add_subscriber('auth.lib.subscribers.csrf_validation', \
                          'pyramid.events.NewRequest')
    config.add_subscriber('auth.lib.subscribers.add_renderer_globals', \
                          'pyramid.events.BeforeRender')
    config.add_subscriber('auth.lib.subscribers.add_user_context', \
                          'pyramid.events.ContextFound')

    config.add_static_view('auth/static', 'auth:static')

    config.add_view(forbidden, context=Forbidden)

    # Use simple login template
    config.add_route('apex_login', '/login')
    config.add_view(login, route_name='apex_login', \
                    renderer='mako_templates/login_simple.mako')
    
    config.add_route('apex_logout', '/logout')
    config.add_view(logout, route_name='apex_logout', \
                    renderer='json')
