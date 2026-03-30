# BBC Guild Raffle Manager 🎲

A modern web application for managing guild member raffles with automatic database initialization, authentication, and cloud deployment capabilities.

## 🎯 What Does This Do?

The BBC Guild Raffle Manager helps guild administrators:
- **👥 Manage Members**: Import member data via TSV/LUA files
- **🎲 Create Raffles**: Set up raffles with customizable parameters  
- **�🔐 Secure Access**: Authentication system with admin accounts
- **☁️ Cloud Ready**: Deploy to Fly.io with persistent storage

## 🚀 Complete Beginner's Guide

### Step 1: Understanding Fly.io (For Complete Beginners)

**What is Fly.io?**
Fly.io is a cloud platform that runs your web applications on servers around the world, making them fast and accessible to users everywhere. Think of it like having your own website that automatically works globally without managing servers yourself.

**Key Concepts:**
1. **Global Network**: Your app runs on servers in many cities worldwide
2. **Docker Containers**: Your code runs in isolated, portable packages
3. **Automatic HTTPS**: Secure connections are handled for you
4. **Persistent Storage**: Your data stays safe even when the app restarts
5. **Auto-scaling**: Starts/stops automatically based on traffic

**How It Works:**
```
Your Code → Docker Container → Fly.io Servers → Global Internet
```

### Step 2: Get Ready to Deploy

#### Install Prerequisites
1. **Install Fly.io CLI** (this lets you control Fly.io from your computer):
   
   **Windows (PowerShell):**
   ```powershell
   iwr https://fly.io/install.ps1 -useb | iex
   ```
   
   **macOS/Linux:**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Create Account and Login:**
   ```bash
   flyctl auth signup  # Create new account
   # OR
   flyctl auth login   # Login to existing account
   ```

3. **Verify Everything Works:**
   ```bash
   flyctl version
   flyctl auth whoami
   ```

### Step 3: Choose Your Deployment Environment

This project is designed to be **SAFE** - you can't accidentally break production! You must explicitly choose which environment to deploy to:

- **`dev`** - For testing new features (bbcguild-raffle-dev)
- **`test`** - For testing with real-ish data (bbcguild-raffle-test)  
- **`staging`** - For final testing before production (bbcguild-raffle-staging)
- **`prod`** - Live production environment (bbcguild-raffle)

### Step 4: Deploy Your First Environment

Start with development to get familiar:

```bash
# Make sure you're in the project directory
cd /path/to/bbc-rafflemanager

# Deploy to development environment (safe to experiment)
./deploy.sh dev
```

**What happens:**
1. Script checks you have Fly.io CLI installed
2. Creates a new app called `bbcguild-raffle-dev`
3. Sets up a database volume for your data
4. Configures the environment for development
5. Deploys your application
6. Gives you a URL to access it

**Your dev environment will be available at:**
`https://bbcguild-raffle-dev.fly.dev`

### Step 5: First Login

1. Go to your app URL + `/auth/login`

### Step 6: Understanding Environments

| Environment | Purpose | App Name | URL | Resources |
|-------------|---------|----------|-----|-----------|
| **dev** | Development & testing | `bbcguild-raffle-dev` | `https://bbcguild-raffle-dev.fly.dev` | 512MB, auto-sleep |
| **test** | Testing with real data | `bbcguild-raffle-test` | `https://bbcguild-raffle-test.fly.dev` | 512MB, auto-sleep |
| **staging** | Final testing | `bbcguild-raffle-staging` | `https://bbcguild-raffle-staging.fly.dev` | 1GB, auto-sleep |
| **prod** | Live production | `bbcguild-raffle` | `https://bbcguild-raffle.fly.dev` | 1GB, always running |

## 🛡️ Safe Deployment Process

### Why This Is Safe

The deployment script has multiple safety features:

1. **No Accidental Deployments**: You MUST specify which environment
2. **Production Warnings**: Requires typing "YES" for production
3. **Existing App Alerts**: Warns if you're updating an existing app
4. **Environment Isolation**: Each environment is completely separate
5. **Force Mode Protection**: `--force` flag required to skip confirmations

### Deployment Commands

```bash
# Safe development deployment
./deploy.sh dev

# Test environment deployment  
./deploy.sh test

# Staging environment deployment
./deploy.sh staging

# Production deployment (requires "YES" confirmation)
./deploy.sh prod

# Force mode (skips confirmations - use with extreme caution!)
./deploy.sh prod --force
```

### What Each Environment Is For

**Development (`dev`):**
- Experimenting with new features
- Learning how the system works
- Testing configuration changes
- Breaking things without consequences

**Test (`test`):**
- Testing with real guild data
- Verifying imports work correctly
- Training new administrators
- User acceptance testing

**Staging (`staging`):**
- Final testing before production release
- Performance testing with production-like settings
- Integration testing

**Production (`prod`):**
- Live system used by guild members
- Real raffles and data
- Maximum stability and performance
- Requires explicit confirmation to deploy

## 📊 Understanding Your Deployment

### Architecture Overview
```
Internet → Fly.io Edge → Your App Container → SQLite Database (on Volume)
```

### What Gets Created
When you deploy, Fly.io automatically creates:
- **App Container**: Your Python application running in Docker
- **Persistent Volume**: Storage for your database that survives restarts
- **HTTPS Certificate**: Automatic SSL encryption
- **Health Checks**: Automatic monitoring at `/health` endpoint
- **Auto-scaling**: Starts/stops based on traffic

### Key Files in Your Project
- **`fly.toml`**: Configuration for Fly.io deployment
- **`Dockerfile.production`**: Instructions for building your app container
- **`startup.sh`**: Script that runs when your app starts
- **`deploy.sh`**: Safe deployment script with environment protection
- **`upload-db.sh`**: Script for safely uploading your database

## 🗄️ Database Management

### Automatic Initialization
The application **automatically sets up** your database:
- ✅ **Preserves Existing Data**: Uses your existing `raffle.db` if it exists
- ✅ **Auto-Creates Schema**: Creates new database with proper structure if needed  
- ✅ **Template Fallback**: Uses `raffle_template.db` as backup
- ✅ **Environment Aware**: Works the same in development and production

### First-Time Setup
1. Deploy your app (database auto-initializes)
2. Visit `https://your-app.fly.dev/auth/login`

### Database Locations
- **Development**: `./raffle.db` (in your project folder)
- **Production**: `/data/raffle.db` (on persistent volume)

### Creating Additional Admin Users
```bash
# Interactive user creation
python create_admin.py

# Automated user creation  
python create_admin.py --username myadmin --password newpassword

# Reset admin password if you forget it
python create_admin.py --username admin --password admin123 --force
```

## 📤 Uploading Your Existing Database

If you have an existing `raffle.db` with your guild data:

### Safe Upload Process
```bash
# Upload your local database to production (with automatic backup)
bash upload-db.sh
```

**What this does:**
1. **Creates backup** of current production database
2. **Validates** your local database
3. **Shows statistics** about your data
4. **Uploads** the new database safely
5. **Verifies** everything worked
6. **Restarts** the application

### Manual Upload (if script fails)
```bash
# Download current database as backup
flyctl ssh sftp --app bbcguild-raffle get /data/raffle.db ./backup-$(date +%Y%m%d).db

# Upload your database
flyctl ssh sftp --app bbcguild-raffle put ./raffle.db /data/raffle.db

# Restart the app
flyctl restart --app bbcguild-raffle
```

## 📊 Monitoring Your Application

### Essential Commands

```bash
# Check if your app is running
flyctl status --app bbcguild-raffle

# Watch logs in real-time
flyctl logs --app bbcguild-raffle -f

# Get recent logs
flyctl logs --app bbcguild-raffle -n 100

# Check your app's health
curl https://bbcguild-raffle.fly.dev/health
```

### Health Check Response
A healthy app returns:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-26T18:30:00Z",
  "database": "connected"
}
```

### App Management
```bash
# SSH into your app (like remote desktop for servers)
flyctl ssh console --app bbcguild-raffle

# Check storage usage
flyctl volumes list --app bbcguild-raffle

# Scale memory if needed
flyctl scale memory 2048 --app bbcguild-raffle

# Restart your app
flyctl restart --app bbcguild-raffle
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. App Won't Start
```bash
# Check what's wrong
flyctl logs --app bbcguild-raffle

# Try restarting
flyctl restart --app bbcguild-raffle
```

#### 2. Can't Login
```bash
# Reset admin password
flyctl ssh console --app bbcguild-raffle
cd /app
python create_admin.py --username admin --password admin123 --force
```

#### 3. Database Problems
```bash
# Check if database exists
flyctl ssh console --app bbcguild-raffle
ls -la /data/raffle.db

# Check database health
sqlite3 /data/raffle.db "PRAGMA integrity_check;"
```

#### 4. Out of Storage
```bash
# Check storage usage
flyctl ssh console --app bbcguild-raffle
df -h /data

# Create larger volume if needed
flyctl volumes create raffle_data_new --size 5 --app bbcguild-raffle
```

#### 5. Performance Issues
```bash
# Check memory usage
flyctl status --app bbcguild-raffle

# Increase memory
flyctl scale memory 2048 --app bbcguild-raffle
```

### Emergency Procedures

#### Rollback to Previous Version
```bash
# See recent deployments
flyctl releases --app bbcguild-raffle

# Rollback to previous version
flyctl releases rollback --app bbcguild-raffle
```

#### Restore Database from Backup
```bash
# Upload backup database
flyctl ssh sftp --app bbcguild-raffle put ./db-backups/backup-file.db /data/raffle.db

# Restart app
flyctl restart --app bbcguild-raffle
```

## 💰 Cost and Resource Management

### Typical Costs
- **Development/Test**: ~$2-4/month (auto-sleeps when not used)
- **Production**: ~$6-9/month (always running)

### Resource Optimization
- **Start Small**: Begin with default settings
- **Monitor Usage**: Check `flyctl status` regularly
- **Scale Up When Needed**: Increase resources if performance suffers
- **Use Auto-stop**: Let non-production environments sleep when idle

### Resource Settings by Environment
| Environment | Memory | CPU | Volume | Auto-sleep |
|-------------|--------|-----|--------|------------|
| dev/test | 512MB | 1 shared | 1GB | Yes |
| staging | 1GB | 1 shared | 2GB | Yes |
| production | 1GB | 1 shared | 2GB | No |

## 🔧 Advanced Topics

### Technology Stack
- **Backend**: Python 3.11 with Pyramid web framework
- **Database**: SQLite with persistent storage
- **Frontend**: Server-rendered HTML with Mako templates
- **Deployment**: Docker containers on Fly.io
- **Web Server**: Gunicorn (production) / Waitress (development)

### Project Structure
```
bbc-rafflemanager/
├── auth/                   # User authentication
├── mako_templates/         # HTML templates
├── static/                # CSS, JavaScript, images
├── tasks.py               # Main application logic
├── wsgi.py                # Production server entry point
├── init_db.py             # Database setup
├── deploy.sh              # Safe deployment script
├── upload-db.sh           # Database upload utility
└── fly.toml               # Fly.io configuration
```

### Database Schema
Core tables:
- `guilds` - Guild information
- `users` - Guild member data  
- `auth_users` - Admin accounts
- `raffles` - Raffle definitions
- `tickets` - Raffle entries
- `prizes` - Prize definitions and winners
- `imports` - Data import history

### Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_PATH` | `/data/raffle.db` | Database file location |
| `IMPORT_PATH` | `/data/import` | File upload storage |
| `LOG_LEVEL` | `INFO` | Logging verbosity |
| `PYRAMID_DEBUG` | `0` | Debug mode (0=off, 1=on) |

### Local Development Setup

```bash
# Option 1: Direct Python (requires Python 3.11+)
pip install -r requirements.txt
python wsgi.py

# Option 2: Docker Compose
docker-compose up --build

# Option 3: VS Code Dev Container (recommended for developers)
# 1. Open folder in VS Code
# 2. Install "Dev Containers" extension  
# 3. Command Palette: "Dev Containers: Reopen in Container"
```

### Data Import
The application supports:
- **TSV files**: Tab-separated member data
- **LUA files**: RaffleManager.lua addon exports

Upload via web interface at `/roster` or admin panel.

### Security Features
- User authentication with BCrypt password hashing
- Non-root container execution
- SQL injection prevention
- File upload restrictions
- HTTPS enforcement
- Environment isolation

## 📋 Quick Reference

### Deployment Commands
```bash
./deploy.sh dev      # Development environment
./deploy.sh test     # Test environment  
./deploy.sh staging  # Staging environment
./deploy.sh prod     # Production (requires confirmation)
```

### Monitoring Commands
```bash
flyctl status --app <app-name>           # Check app status
flyctl logs --app <app-name> -f          # Live logs
flyctl ssh console --app <app-name>      # SSH access
flyctl volumes list --app <app-name>     # Storage status
```

### Database Commands
```bash
bash upload-db.sh                        # Upload local database
python create_admin.py                   # Create admin user
python init_db.py                        # Reset database
```

### Environment URLs
- **Dev**: `https://bbcguild-raffle-dev.fly.dev`
- **Test**: `https://bbcguild-raffle-test.fly.dev`
- **Staging**: `https://bbcguild-raffle-staging.fly.dev`
- **Production**: `https://bbcguild-raffle.fly.dev`

## 🎯 Quick Start Checklist

- [ ] Install Fly.io CLI and create account
- [ ] Choose deployment environment (start with `dev`)
- [ ] Run `./deploy.sh dev` for safe first deployment
- [ ] Login with admin/admin123 and change password
- [ ] Test the application with sample data
- [ ] Deploy to other environments as needed
- [ ] Upload your real database to production
- [ ] Set up monitoring and backups

## 🆘 Getting Help

- **Fly.io Documentation**: https://fly.io/docs/
- **Community Forum**: https://community.fly.io/
- **Status Page**: https://status.fly.io/

## 📄 License

This project is proprietary software for BBC Guild operations.

---

**🎮 For Guild Members**: Access your raffle system at the URL provided by your administrators.

**🔧 For New Administrators**: Start with the "Complete Beginner's Guide" above - it will walk you through everything step by step.

**💻 For Developers**: The advanced sections cover the technical architecture and local development setup.

Your BBC Guild Raffle Manager runs on a global, scalable platform with complete environment isolation! 🚀
