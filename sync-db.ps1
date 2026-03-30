# Sync Database from Production
# Downloads the latest raffle.db from Fly.io production server
# PowerShell version for Windows

param(
    [string]$AppName = "bbcguild-raffle",
    [switch]$Help
)

if ($Help) {
    Write-Host @"
BBC Guild Raffle - Database Sync

USAGE:
    .\sync-db.ps1 [-AppName <name>] [-Help]

EXAMPLES:
    .\sync-db.ps1                    # Sync from default app
    .\sync-db.ps1 -AppName my-app    # Sync from specific app
    .\sync-db.ps1 -Help              # Show this help

DESCRIPTION:
    Downloads the production raffle.db from Fly.io to your local development
    environment. Automatically backs up your existing local database first.
"@
    exit 0
}

Write-Host "🔄 BBC Guild Raffle - Database Sync" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Configuration
$REMOTE_DB_PATH = "/data/raffle.db"
$LOCAL_DB_PATH = ".\raffle.db"
$BACKUP_DIR = ".\db-backups"

# Check if flyctl is installed
if (!(Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ flyctl is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   iwr https://fly.io/install.ps1 -useb | iex" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in
try {
    $null = flyctl auth whoami 2>$null
} catch {
    Write-Host "❌ You're not logged into fly.io. Please run:" -ForegroundColor Red
    Write-Host "   flyctl auth login" -ForegroundColor Yellow
    exit 1
}

# Check if app exists
$apps = flyctl apps list --json | ConvertFrom-Json
if (-not ($apps | Where-Object { $_.Name -eq $AppName })) {
    Write-Host "❌ App '$AppName' not found. Available apps:" -ForegroundColor Red
    flyctl apps list
    exit 1
}

Write-Host "✅ flyctl ready and app '$AppName' found" -ForegroundColor Green

# Create backup directory if it doesn't exist
if (!(Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# Backup existing local database if it exists
if (Test-Path $LOCAL_DB_PATH) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$BACKUP_DIR\raffle_local_backup_$timestamp.db"
    Write-Host "💾 Backing up existing local database to: $backupFile" -ForegroundColor Yellow
    Copy-Item $LOCAL_DB_PATH $backupFile
}

# Download database from production
Write-Host "⬇️  Downloading database from production..." -ForegroundColor Blue

try {
    flyctl ssh sftp get $REMOTE_DB_PATH $LOCAL_DB_PATH --app $AppName
    Write-Host "✅ Database downloaded successfully!" -ForegroundColor Green
    
    # Show database info if sqlite3 is available
    if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "📊 Database Summary:" -ForegroundColor Cyan
        Write-Host "===================" -ForegroundColor Cyan
        
        try {
            $userCount = sqlite3 $LOCAL_DB_PATH "SELECT COUNT(*) FROM users;"
            $guildCount = sqlite3 $LOCAL_DB_PATH "SELECT COUNT(*) FROM guilds;"
            $raffleCount = sqlite3 $LOCAL_DB_PATH "SELECT COUNT(*) FROM prizes;"
            $lastImport = sqlite3 $LOCAL_DB_PATH "SELECT MAX(import_date) FROM imports;"
            
            Write-Host "👥 Users: $userCount"
            Write-Host "🏰 Guilds: $guildCount"
            Write-Host "🎲 Prizes: $raffleCount"
            Write-Host "📅 Last Import: $lastImport"
        } catch {
            Write-Host "⚠️  Could not read database stats (database may be empty or corrupted)" -ForegroundColor Yellow
        }
        
        $fileSize = [math]::Round((Get-Item $LOCAL_DB_PATH).Length / 1KB, 2)
        Write-Host ""
        Write-Host "📁 Database file size: $fileSize KB"
    } else {
        Write-Host "💡 Install sqlite3 to see database summary" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🎉 Development database is now synced with production!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Usage tips:" -ForegroundColor Cyan
    Write-Host "   • Your local database is now identical to production"
    Write-Host "   • Previous local database backed up to: $BACKUP_DIR\"
    Write-Host "   • Run this script anytime to refresh with latest production data"
    Write-Host "   • Use 'python wsgi.py' to start development server with fresh data"

} catch {
    Write-Host "❌ Failed to download database from production" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   • Check if the app is running: flyctl status --app $AppName"
    Write-Host "   • Verify database path exists: flyctl ssh console --app $AppName"
    Write-Host "   • Try manual download: flyctl ssh sftp --app $AppName"
    exit 1
}

# Optional: Show recent activity command
Write-Host ""
Write-Host "🔍 Want to see recent activity? Run:" -ForegroundColor Cyan
Write-Host "   sqlite3 $LOCAL_DB_PATH" -ForegroundColor Gray
Write-Host "   sqlite> SELECT * FROM imports ORDER BY import_date DESC LIMIT 5;" -ForegroundColor Gray
Write-Host ""
