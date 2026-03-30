#!/bin/bash

# Sync Database from Production
# Downloads the latest raffle.db from Fly.io production server

set -e

echo "🔄 BBC Guild Raffle - Database Sync"
echo "==================================="

# Configuration
APP_NAME="bbcguild-raffle"
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
    exit 1
fi

echo "✅ flyctl ready and app '$APP_NAME' found"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup existing local database if it exists
if [ -f "$LOCAL_DB_PATH" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/raffle_local_backup_$TIMESTAMP.db"
    echo "💾 Backing up existing local database to: $BACKUP_FILE"
    cp "$LOCAL_DB_PATH" "$BACKUP_FILE"
fi

# Download database from production
echo "⬇️  Downloading database from production..."
if flyctl ssh sftp get "$REMOTE_DB_PATH" "$LOCAL_DB_PATH" --app "$APP_NAME"; then
    echo "✅ Database downloaded successfully!"
    
    # Show database info
    if command -v sqlite3 &> /dev/null; then
        echo ""
        echo "📊 Database Summary:"
        echo "==================="
        
        # Get basic stats
        USER_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "N/A")
        GUILD_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM guilds;" 2>/dev/null || echo "N/A")
        RAFFLE_COUNT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT COUNT(*) FROM prizes;" 2>/dev/null || echo "N/A")
        
        echo "👥 Users: $USER_COUNT"
        echo "🏰 Guilds: $GUILD_COUNT" 
        echo "🎲 Prizes: $RAFFLE_COUNT"
        
        # Get last import
        LAST_IMPORT=$(sqlite3 "$LOCAL_DB_PATH" "SELECT MAX(import_date) FROM imports;" 2>/dev/null || echo "N/A")
        echo "📅 Last Import: $LAST_IMPORT"
        
        echo ""
        echo "📁 Database file size: $(du -h "$LOCAL_DB_PATH" | cut -f1)"
    else
        echo "💡 Install sqlite3 to see database summary: apt-get install sqlite3"
    fi
    
    echo ""
    echo "🎉 Development database is now synced with production!"
    echo ""
    echo "💡 Usage tips:"
    echo "   • Your local database is now identical to production"
    echo "   • Previous local database backed up to: $BACKUP_DIR/"
    echo "   • Run this script anytime to refresh with latest production data"
    echo "   • Use 'python wsgi.py' to start development server with fresh data"
    
else
    echo "❌ Failed to download database from production"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   • Check if the app is running: flyctl status --app $APP_NAME"
    echo "   • Verify database path exists: flyctl ssh console --app $APP_NAME"
    echo "   • Try manual download: flyctl ssh sftp --app $APP_NAME"
    exit 1
fi

# Optional: Show recent activity
echo ""
echo "🔍 Want to see recent activity? Run:"
echo "   sqlite3 $LOCAL_DB_PATH"
echo "   sqlite> SELECT * FROM imports ORDER BY import_date DESC LIMIT 5;"
echo ""
