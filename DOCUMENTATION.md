# BBC Guild Raffle Manager 🎲

A modern Python web application for managing guild member raffles with automatic database initialization, authentication, and cloud deployment capabilities.

## 📖 About

The BBC Guild Raffle Manager helps guild administrators:

- **👥 Manage Members**: Import member data via TSV/LUA files
- **🎲 Create Raffles**: Set up raffles with customizable parameters  
- **🏆 Generate Winners**: Automatically select random winners
- **📊 Track History**: View past raffles and results
- **🔐 Secure Access**: Authentication system with admin accounts
- **☁️ Cloud Ready**: Deploy to Fly.io with persistent storage

## 🚀 Quick Start

### Prerequisites
- [Fly.io account](https://fly.io/docs/hands-on/sign-up/) (for production)
- [Flyctl CLI](https://fly.io/docs/hands-on/install-flyctl/) (for production)
- Python 3.11+ (for local development)
- Git

### Option 1: Deploy to Production (Fly.io)
```bash
# Clone the repository
git clone <your-repo-url>
cd bbc-rafflemanager

# Install flyctl and authenticate
curl -L https://fly.io/install.sh | sh
flyctl auth login

# Deploy using automated script
./deploy.sh
```

Your application will be live at `https://<your-app-name>.fly.dev`

### Option 2: Local Development
```bash
# Option A: VS Code Dev Container (Recommended)
# 1. Open this folder in VS Code
# 2. Install "Dev Containers" extension
# 3. Command Palette (Ctrl+Shift+P): "Dev Containers: Reopen in Container"
# 4. Container will auto-install dependencies
# 5. Run: python wsgi.py

# Option B: Direct Python execution
pip install -r requirements.txt
python wsgi.py

# Option C: Using Docker Compose
docker-compose up --build
```

Access the development server at `http://localhost:8080`

## 🏗️ Architecture

### Technology Stack
- **Backend**: Python 3.11 with Pyramid web framework
- **Database**: SQLite with persistent storage
- **Frontend**: Server-rendered HTML with Mako templates
- **Deployment**: Docker containers on Fly.io
- **Web Server**: Gunicorn WSGI server (production) / Waitress (development)

### Database Schema
The application uses SQLite with the following core tables:
- `guilds` - Guild information and configuration
- `users` - Guild member data  
- `auth_users` - Authentication accounts
- `raffles` - Raffle definitions and settings
- `tickets` - Raffle entries and participants
- `prizes` - Prize definitions and winners
- `imports` - Member data import history

### Project Structure
```
bbc-rafflemanager/
├── auth/                   # Authentication module
│   ├── models.py          # User authentication models
│   ├── views.py           # Login/logout views
│   └── forms.py           # Authentication forms
├── mako_templates/         # HTML templates
│   ├── index.mako         # Main application interface
│   ├── roster.mako        # Member management
│   ├── select.mako        # Raffle selection
│   └── admin_index.mako   # Administrative interface
├── static/                # Static assets
│   ├── css/               # Stylesheets
│   └── js/                # JavaScript files
├── .devcontainer/         # VS Code dev container config
├── tasks.py               # Main application and routing
├── wsgi.py                # Production WSGI entry point
├── init_db.py             # Database initialization
├── create_admin.py        # Admin user creation utility
└── fly.toml               # Fly.io deployment configuration
```

## 🗄️ Database Management

### Automatic Initialization
The application **automatically initializes** the database when it starts:

- **✅ Preserves Existing Data**: If you have a `raffle.db` file, it will be used as-is
- **✅ Auto-Creates Schema**: If no database exists, a new one is created with the proper schema  
- **✅ Template Fallback**: Uses `raffle_template.db` if schema files aren't available
- **✅ Environment Aware**: Works in both development and production environments

### Database Locations
- **Local Development**: `./raffle.db` (in project root)
- **Production/Containers**: `/data/raffle.db` (persistent volume)
- **Override**: Set `DATABASE_PATH` environment variable

### Manual Database Operations
```bash
# Create/reset database manually (if needed)
python init_db.py

# Create additional admin users
python create_admin.py

# Access SQLite console
sqlite3 raffle.db

# Create template database (developers only)
python create_template_db.py
```

## 🔐 Admin User Management

### Default Admin User
When a fresh database is created, a default admin user is automatically created:
- **Username**: `admin`
- **Password**: `admin123`
- **⚠️ SECURITY**: Change this password immediately after first login!

### First-Time Setup
1. Start the application (database auto-initializes)
2. Navigate to `/auth/login` 
3. Log in with: `admin` / `admin123`
4. **Immediately change your password!**

### Creating Additional Admin Users
```bash
# Interactive user creation
python create_admin.py

# Automated user creation  
python create_admin.py --username myadmin --password newpassword

# Force overwrite existing user
python create_admin.py --username admin --password newpassword --force
```

### Troubleshooting Authentication
```bash
# Reset admin password
python create_admin.py --username admin --password admin123 --force

# Check existing users
sqlite3 raffle.db "SELECT auth_id, auth_name FROM auth_users;"
```

## 🚀 Production Database Management

### Uploading Your Existing Database to Fly.io

If you have an existing `raffle.db` with your data that you want to use in production:

#### Option 1: PowerShell (Windows)
```powershell
# Upload your local database to production
.\upload-db.ps1

# Or with custom app name
.\upload-db.ps1 -AppName your-app-name
```

#### Option 2: Bash (Linux/Mac/WSL)
```bash
# Make script executable and run
chmod +x upload-db.sh
./upload-db.sh
```

#### Manual Upload Process
If the automated scripts fail due to flyctl changes:

```bash
# 1. Backup existing database
flyctl ssh console --app your-app-name
mv /data/raffle.db /data/raffle.db.backup
exit

# 2. Upload via SFTP
flyctl ssh sftp shell --app your-app-name
# At sftp> prompt:
put "./raffle.db" "/data/raffle.db"
quit

# 3. Restart application
flyctl machine restart --app your-app-name
```

#### What the Upload Process Does:
1. **Backs up** existing production database (if any)
2. **Stops** the application temporarily
3. **Uploads** your local `raffle.db` to `/data/raffle.db`
4. **Verifies** the upload was successful
5. **Restarts** the application
6. **Shows** database statistics and health status

### Downloading from Production
```bash
# Download current production database
./sync-db.sh
```

### ⚠️ Important Notes
- The upload process **replaces** the entire production database
- A backup is automatically created before upload
- The application is temporarily stopped during upload
- Verify your data after upload

## ⚙️ Configuration

### Environment Variables
Key configuration options:

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_PATH` | `/data/raffle.db` | SQLite database location |
| `IMPORT_PATH` | `/data/import` | TSV import file storage |
| `LOG_LEVEL` | `INFO` | Application logging level |
| `PYRAMID_DEBUG` | `0` | Debug mode (0=off, 1=on) |
| `PYTHONPATH` | `/app` | Python module search path |

### Fly.io Configuration
The `fly.toml` file contains:
- **Resource Allocation**: 1GB RAM, 1 CPU core
- **Persistent Storage**: 2GB volume mounted at `/data`
- **Health Checks**: HTTP endpoint monitoring at `/health`
- **Auto-scaling**: Minimum 1 machine running
- **Port Configuration**: Internal port 80, HTTPS forced

### Local Development Configuration
- **Port**: 8080 (configurable via `PORT` environment variable)
- **Database**: `./raffle.db` in project directory
- **Debug Mode**: Enabled by default
- **Auto-reload**: Enabled in development

## 🔧 Development

### VS Code Dev Container (Recommended)
The project includes a complete dev container configuration:

- **Python 3.11** with all dependencies pre-installed
- **SQLite** for database operations
- **Extensions**: Python, Ruff, Black formatter
- **Port forwarding**: Automatic setup for external DNS access
- **Git integration**: Safe directory configuration

### Local Setup Without Container
```bash
# Install dependencies
pip install -r requirements.txt

# Run application
python wsgi.py

# Or use Waitress directly
waitress-serve --port=8080 wsgi:application
```

### Database Development
```bash
# Initialize fresh database with test data
LOAD_TEST_DATA=true python init_db.py

# Reset database to clean state
rm raffle.db && python init_db.py
```

### Import Data
The application supports importing member data from:
- **TSV files**: Tab-separated values with specific format
- **LUA files**: RaffleManager.lua addon exports

Upload via the web interface at `/roster` or the main admin interface.

## 🚀 Deployment

### Fly.io Production Deployment
```bash
# Initial deployment
./deploy.sh

# Update existing deployment
flyctl deploy

# View logs
flyctl logs --app your-app-name

# SSH into production
flyctl ssh console --app your-app-name
```

### Health Monitoring
```bash
# Check application status
flyctl status --app your-app-name

# Health check endpoint
curl https://your-app.fly.dev/health
```

Returns:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-21T18:30:00Z",
  "database": "connected"
}
```

### Resource Management
- **Estimated Monthly Cost**: $6-9 USD
- **RAM**: 1GB (sufficient for typical usage)
- **Storage**: 2GB persistent volume
- **CPU**: Shared core (scales automatically)

## 🔐 Security Features

- **User Authentication**: Session-based login system with BCrypt password hashing
- **Non-root Execution**: Container runs as unprivileged user
- **Input Validation**: SQL injection prevention
- **File Upload Safety**: Restricted file types and locations
- **Environment Isolation**: Containerized deployment
- **HTTPS Enforcement**: All traffic encrypted in production

## 🚨 Troubleshooting

### Common Issues

**Database Connection Errors**:
```bash
# Check database file permissions
flyctl ssh console --app your-app-name
ls -la /data/raffle.db
```

**Import Failures**:
- Verify TSV file format matches expected columns
- Check file encoding (UTF-8 required)
- Ensure proper column headers

**Authentication Issues**:
```bash
# Reset admin password
python create_admin.py --username admin --password admin123 --force

# Check auth_users table
sqlite3 raffle.db "SELECT auth_id, auth_name FROM auth_users;"
```

**Port/Network Issues in Development**:
- Default port is 8080, change with `PORT` environment variable
- For external DNS access, use dev container with port 80 mapping

### Recovery Procedures

**Database Recovery**:
```bash
# SSH into container
flyctl ssh console --app your-app-name

# Reinitialize database (⚠️ destroys data!)
rm /data/raffle.db
python /app/init_db.py
```

**Volume Issues**:
```bash
# Recreate persistent volume (⚠️ destroys data!)
flyctl volumes destroy raffle_data --app your-app-name
flyctl volumes create raffle_data --size 2 --app your-app-name
flyctl deploy
```

**Application Not Starting**:
```bash
# Check logs for errors
flyctl logs --app your-app-name

# Restart machines
flyctl machine restart --app your-app-name

# Check machine status
flyctl machine list --app your-app-name
```

### Database Backup & Maintenance
```bash
# Create backup
flyctl ssh console --app your-app-name
cp /data/raffle.db /data/raffle.db.backup-$(date +%Y%m%d)

# Optimize database
sqlite3 /data/raffle.db "VACUUM; ANALYZE;"

# Download backup locally
flyctl ssh sftp shell --app your-app-name
get /data/raffle.db.backup-20250721 ./local-backup.db
```

## 📁 File Management

### Important Files
- `raffle.db` - Main database (excluded from git)
- `raffle_template.db` - Schema template for initialization
- `fly.toml` - Fly.io deployment configuration
- `requirements.txt` - Python dependencies
- `wsgi.py` - Production WSGI entry point
- `tasks.py` - Main application logic and routing

### Scripts and Utilities
- `deploy.sh` / `deploy.ps1` - Automated deployment scripts
- `upload-db.sh` / `upload-db.ps1` - Database upload utilities
- `sync-db.sh` - Download production database
- `create_admin.py` - Admin user creation utility
- `init_db.py` - Database initialization

## 📄 License

This project is proprietary software for BBC Guild operations.

---

**🎮 For BBC Guild Members**: Access your raffle system at the URL provided by your guild administrators.

**🔧 For Administrators**: This documentation covers everything needed to deploy, manage, and troubleshoot the system.

**💻 For Developers**: The codebase uses modern Python practices with comprehensive error handling and automated deployment.
