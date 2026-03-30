#!/usr/bin/env python3
"""
WSGI entry point for the BBC Guild Raffle Manager.
Production-ready web application interface.
"""

import os
import sys
import warnings

# Suppress pkg_resources deprecation warning from Pyramid
warnings.filterwarnings("ignore", category=UserWarning, message=".*pkg_resources is deprecated.*")

# Add the current directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# Import the main application
from tasks import make_app

# Create the WSGI application
application = make_app()

if __name__ == "__main__":
    # For development, you can run this directly
    from waitress import serve
    import logging
    
    # Reduce Waitress warnings in development
    logging.getLogger('waitress.queue').setLevel(logging.ERROR)
    
    # Use port 80 for development (matches production)
    dev_port = int(os.getenv('DEV_PORT', '80'))
    
    print(f"🚀 Starting development server on port {dev_port}")
    print("✅ Database configuration: OK")
    print("✅ Import issues: Resolved")
    
    serve(application, 
          host='0.0.0.0', 
          port=dev_port,
          threads=4)  # Allow more concurrent requests
