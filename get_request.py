#!/usr/bin/env python3
"""
Simple stub for get_request functionality.
This is used to get current request context in database operations.
"""

from pyramid.threadlocal import get_current_request

def get_request():
    """Get the current pyramid request."""
    return get_current_request()
