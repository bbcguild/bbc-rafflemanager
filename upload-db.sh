#!/bin/bash

# Upload Database to Production
# Uploads your local raffle.db to the Fly.io production server

set -e

echo "⬆️  BBC Guild Raffle - Database Upload to Production"
echo "=================================================="

# Configuration - Your app name from fly.toml
APP_NAME="bbcguild-raffle-test"
REMOTE_DB_PATH="/data/raffle.db"
LOCAL_DB_PATH="./raffle.db"
BACKUP_DIR="./db-backups"

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl is not installed. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ You're not logged into fly.io. Please run:"
    echo "   flyctl auth login"
    exit 1
fi

# Check if app exists
if ! flyctl apps list | grep -q "$APP_NAME"; then
    echo "❌ App '$APP_NAME' not found. Available apps:"
    flyctl apps list
    echo ""
    echo "Please update APP_NAME in this script to match your app name."
    exit 1
fi

# Check if local database exists
if [ ! -f "$LOCAL_DB_PATH" ]; then
    echo "❌ Local database not found at: $LOCAL_DB_PATH"
    echo "   Please ensure you have a raffle.db file in the current directory."
    exit 1
fi

# Get local database info
LOCAL_SIZE=$(stat -c%s "$LOCAL_DB_PATH" 2>/dev/null || stat -f%z "$LOCAL_DB_PATH" 2>/dev/null || echo "unknown")
echo "📁 Local database: $LOCAL_DB_PATH"
echo "📏 Local size: $LOCAL_SIZE bytes"

# Create backup of existing production database
echo ""
echo "📦 Creating backup of production database..."
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/production-backup-$(date +%Y%m%d-%H%M%S).db"

echo "⬇️  Downloading current production database for backup..."
if flyctl ssh sftp --app "$APP_NAME" get "$REMOTE_DB_PATH" "$BACKUP_FILE" 2>/dev/null; then
    BACKUP_SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE" 2>/dev/null || echo "unknown")
    echo "✅ Production backup saved: $BACKUP_FILE ($BACKUP_SIZE bytes)"
else
    echo "⚠️  Could not backup production database (may not exist yet)"
fi

# Confirm upload
echo ""
echo "⚠️  WARNING: This will replace the production database!"
echo "📊 Local database details:"

# Get basic stats about local database
if command -v sqlite3 &> /dev/null; then
    echo "   Checking local database contents..."
    
    USER_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "N/A")
    GUILD_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM guilds;" 2>/dev/null || echo "N/A")
    RAFFLE_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM raffles;" 2>/dev/null || echo "N/A")
    AUTH_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM auth_users;" 2>/dev/null || echo "N/A")
    
    echo "   👥 Users: $USER_COUNT"
    echo "   🏰 Guilds: $GUILD_COUNT" 
    echo "   🎲 Raffles: $RAFFLE_COUNT"
    echo "   🔐 Admin Users: $AUTH_COUNT"
    
    # Get last import
    LAST_IMPORT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT MAX(import_date) FROM imports;" 2>/dev/null || echo "N/A")
    echo "   📅 Last Import: $LAST_IMPORT"
else
    echo "   (Install sqlite3 for detailed database info)"
fi

echo ""
read -p "Are you sure you want to upload this database to production? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Upload cancelled."
    exit 1
fi

# Stop the application to prevent database corruption during upload
echo ""
echo "⏹️  Stopping application machines..."
flyctl machine stop --app "$APP_NAME" || echo "⚠️  Could not stop machines (may already be stopped)"

# Upload the database
echo "⬆️  Uploading database to production..."
if flyctl ssh sftp --app "$APP_NAME" put "$LOCAL_DB_PATH" "$REMOTE_DB_PATH"; then
    echo "✅ Database uploaded successfully!"
    
    # Verify the upload
    echo "🔍 Verifying upload..."
    REMOTE_SIZE=$(flyctl ssh console --app "$APP_NAME" -C "stat -c%s $REMOTE_DB_PATH" 2>/dev/null || echo "unknown")
    echo "📏 Remote size: $REMOTE_SIZE bytes"
    
    if [ "$LOCAL_SIZE" = "$REMOTE_SIZE" ]; then
        echo "✅ Upload verified - sizes match!"
    else
        echo "⚠️  Size mismatch - please verify manually"
    fi
else
    echo "❌ Database upload failed!"
    exit 1
fi

# Restart the application
echo ""
echo "🚀 Starting application..."
flyctl machine start --app "$APP_NAME" || echo "⚠️  Could not start machines - may start automatically"

# Wait a moment for startup
echo "⏳ Waiting for application to start..."
sleep 10

# Check application status
echo "🏥 Checking application health..."
if flyctl status --app "$APP_NAME"; then
    echo ""
    echo "🎉 Database upload completed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Visit your application URL to verify it's working"
    echo "   2. Test login with your existing admin credentials"
    echo "   3. Verify your data is present and correct"
    echo ""
    echo "📁 Backup of previous production database:"
    echo "   $BACKUP_FILE"
else
    echo "❌ Application health check failed. Check logs:"
    echo "   flyctl logs --app $APP_NAME"
fi
