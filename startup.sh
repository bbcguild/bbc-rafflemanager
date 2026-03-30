#!/bin/bash
set -e

echo "=== STARTUP SCRIPT BEGIN ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Python version: $(python --version 2>&1 || echo 'Python not found')"

echo "=== ENVIRONMENT VARIABLES ==="
env | grep -E "(DATABASE_PATH|IMPORT_PATH|PYTHONPATH)" || echo "No relevant env vars found"

echo "=== DIRECTORY CONTENTS ==="
echo "Contents of /app:"
ls -la /app/ | head -10
echo "Contents of /data (if exists):"
ls -la /data/ 2>/dev/null || echo "/data does not exist"

echo "=== SETTING INITIAL PERMISSIONS ==="
# Ensure app user can access /data directory
chown -R app:app /data 2>/dev/null || echo "Could not change ownership of /data"

echo "=== RUNNING DATABASE INITIALIZATION AS APP USER ==="
# Use su without login shell to preserve environment
su app -c "cd /app && PYTHONPATH=/app python /app/init_db.py"

echo "=== POST-INITIALIZATION CHECK ==="
echo "Contents of /data after init:"
ls -la /data/ || echo "/data not found"

if [ -f "/data/raffle.db" ]; then
    echo "Database file exists, size: $(stat -c%s /data/raffle.db) bytes"
    echo "Checking database tables:"
    sqlite3 /data/raffle.db ".tables" || echo "Failed to read database tables"
    # Ensure proper ownership of database file
    chown app:app /data/raffle.db
else
    echo "ERROR: Database file not found at /data/raffle.db"
fi

echo "=== STARTING APPLICATION AS ROOT (required for port 80) ==="
# Start the application as root since we need to bind to port 80
exec gunicorn --config gunicorn_config.py wsgi:application
