#!/usr/bin/env python3

import os

# Determine database path based on environment
# Check for specific container markers rather than just directory existence
current_dir = os.getcwd()

# Production container environment: /app working directory with writable /data
if (current_dir == '/app' and 
    os.path.exists('/data') and 
    os.access('/data', os.W_OK) and
    os.path.exists('/app/schema.sql')):
    # Production container environment with persistent volume
    default_db_path = '/data/raffle.db'
else:
    # Local development or dev container environment
    script_dir = os.path.dirname(os.path.abspath(__file__))
    default_db_path = os.path.join(script_dir, 'raffle.db')

# Use environment variable for database path, fallback to appropriate default
DATABASE_PATH = os.getenv('DATABASE_PATH', default_db_path)
DATABASE = DATABASE_PATH
