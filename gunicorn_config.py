# Gunicorn configuration file for production
import multiprocessing
import os

# Server socket
bind = "0.0.0.0:80"
backlog = 2048

# Worker processes - limit for 1GB RAM
workers = min(multiprocessing.cpu_count() * 2 + 1, 4)
worker_class = "sync"
worker_connections = 1000
timeout = 60  # Increased for file uploads
keepalive = 2

# Restart workers after this many requests, to help prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = "-"
errorlog = "-"
loglevel = os.getenv("LOG_LEVEL", "info").lower()
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = 'raffle_app'

# Server mechanics
daemon = False
pidfile = '/tmp/gunicorn.pid'

# Production optimizations
preload_app = True
max_worker_connections = 1000
user = None
group = None
tmp_upload_dir = None

# SSL (if needed)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"
