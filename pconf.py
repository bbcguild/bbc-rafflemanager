#!/usr/bin/env python3

settings = {
        # Base Pyramid
"reload_all": True, 
        # Enable debug authorization to see what's happening
"pyramid.debug_authorization": True,
        # Apex (keeping for compatibility)
"apex.session_secret": "2b95fd3785e088cdd706c570c549d9ea", 
"apex.auth_secret": "a9869a8742fef3653436a7d1bb8a5298", 
"apex.came_from_route": "home", 
"apex.no_csrf": "apex:apex_callback,json",
        # SQLAlchemy - using the correct database
"sqlalchemy.url": "sqlite:///raffle.db",
        # Mako - use relative path from project root
"mako.directories": "mako_templates",
}
