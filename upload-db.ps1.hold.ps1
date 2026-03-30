# Upload Database to Production
# Uploads your local raffle.db to the Fly.io production server

param(
    [string]$AppName = "bbcguild-raffle-test",  # Your app name from fly.toml
    [string]$LocalDbPath = ".\raffle.db",
    [string]$RemoteDbPath = "/data/raffle.db",
    [string]$BackupDir = ".\db-backups"
)

Write-Host "⬆️  BBC Guild Raffle - Database Upload to Production" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Check if flyctl is installed
if (!(Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ flyctl is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   https://fly.io/docs/hands-on/install-flyctl/" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in
try {
    flyctl auth whoami | Out-Null
} catch {
    Write-Host "❌ You're not logged into fly.io. Please run:" -ForegroundColor Red
    Write-Host "   flyctl auth login" -ForegroundColor Yellow
    exit 1
}

# Check if app exists
$appExists = flyctl apps list | Select-String $AppName
if (!$appExists) {
    Write-Host "❌ App '$AppName' not found. Available apps:" -ForegroundColor Red
    flyctl apps list
    Write-Host ""
    Write-Host "Please update the AppName parameter or use: .\upload-db.ps1 -AppName your-app-name" -ForegroundColor Yellow
    exit 1
}

# Check if local database exists
if (!(Test-Path $LocalDbPath)) {
    Write-Host "❌ Local database not found at: $LocalDbPath" -ForegroundColor Red
    Write-Host "   Please ensure you have a raffle.db file in the current directory." -ForegroundColor Yellow
    exit 1
}

# Get local database info
$localSize = (Get-Item $LocalDbPath).Length
Write-Host "📁 Local database: $LocalDbPath" -ForegroundColor Green
Write-Host "📏 Local size: $localSize bytes" -ForegroundColor Green

# Create backup directory
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

# Create backup of existing production database
Write-Host ""
Write-Host "📦 Creating backup of production database..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = Join-Path $BackupDir "production-backup-$timestamp.db"

Write-Host "⬇️  Downloading current production database for backup..." -ForegroundColor Blue
try {
    flyctl ssh sftp --app $AppName get $RemoteDbPath $backupFile 2>$null
    $backupSize = (Get-Item $backupFile).Length
    Write-Host "✅ Production backup saved: $backupFile ($backupSize bytes)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not backup production database (may not exist yet)" -ForegroundColor Yellow
}

# Show database statistics if sqlite3 is available
Write-Host ""
Write-Host "📊 Local database details:" -ForegroundColor Cyan

if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
    try {
        $userCount = sqlite3 $LocalDbPath "SELECT COUNT(*) FROM users;" 2>$null
        $guildCount = sqlite3 $LocalDbPath "SELECT COUNT(*) FROM guilds;" 2>$null  
        $raffleCount = sqlite3 $LocalDbPath "SELECT COUNT(*) FROM raffles;" 2>$null
        $authCount = sqlite3 $LocalDbPath "SELECT COUNT(*) FROM auth_users;" 2>$null
        $lastImport = sqlite3 $LocalDbPath "SELECT MAX(import_date) FROM imports;" 2>$null
        
        Write-Host "   👥 Users: $userCount" -ForegroundColor White
        Write-Host "   🏰 Guilds: $guildCount" -ForegroundColor White
        Write-Host "   🎲 Raffles: $raffleCount" -ForegroundColor White  
        Write-Host "   🔐 Admin Users: $authCount" -ForegroundColor White
        Write-Host "   📅 Last Import: $lastImport" -ForegroundColor White
    } catch {
        Write-Host "   (Could not read database statistics)" -ForegroundColor Gray
    }
} else {
    Write-Host "   (Install sqlite3 for detailed database info)" -ForegroundColor Gray
}

# Confirm upload
Write-Host ""
Write-Host "⚠️  WARNING: This will replace the production database!" -ForegroundColor Red
$confirmation = Read-Host "Are you sure you want to upload this database to production? [y/N]"
if ($confirmation -ne "y" -and $confirmation -ne "Y") {
    Write-Host "❌ Upload cancelled." -ForegroundColor Red
    exit 1
}

# Stop the application
Write-Host ""
Write-Host "⏹️  Stopping application machines..." -ForegroundColor Yellow
try {
    flyctl machine stop --app $AppName
} catch {
    Write-Host "⚠️  Could not stop machines (may already be stopped)" -ForegroundColor Yellow
}

# Upload the database  
Write-Host "⬆️  Uploading database to production..." -ForegroundColor Blue
Write-Host "   This will use an interactive SFTP session..." -ForegroundColor Blue
Write-Host "   Commands that will be executed:" -ForegroundColor Gray
Write-Host "     put $LocalDbPath $RemoteDbPath" -ForegroundColor Gray
Write-Host "     quit" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  If the upload hangs, press Ctrl+C and we'll try an alternative method" -ForegroundColor Yellow

try {
    # Create a temp script file for SFTP commands
    $sftpScript = "sftp_commands.tmp" 
    "put `"$LocalDbPath`" `"$RemoteDbPath`"" | Out-File -FilePath $sftpScript -Encoding ASCII
    "quit" | Out-File -FilePath $sftpScript -Append -Encoding ASCII
    
    # Run SFTP with the script
    flyctl ssh sftp shell --app $AppName < $sftpScript
    
    # Clean up
    Remove-Item $sftpScript -Force
    
    Write-Host "✅ Database upload completed!" -ForegroundColor Green
    
    # Verify the upload
    Write-Host "🔍 Verifying upload..." -ForegroundColor Blue
    try {
        $remoteSize = flyctl ssh console --app $AppName -C "stat -c%s $RemoteDbPath" 2>$null
        Write-Host "📏 Remote size: $remoteSize bytes" -ForegroundColor Green
        
        if ($localSize -eq $remoteSize) {
            Write-Host "✅ Upload verified - sizes match!" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Size mismatch - please verify manually" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Could not verify upload size" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Database upload failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Manual upload instructions:" -ForegroundColor Yellow
    Write-Host "1. Run: flyctl ssh sftp shell --app $AppName" -ForegroundColor White
    Write-Host "2. At the sftp> prompt, type: put `"$LocalDbPath`" `"$RemoteDbPath`"" -ForegroundColor White
    Write-Host "3. Type: quit" -ForegroundColor White
    exit 1
}

# Restart the application  
Write-Host ""
Write-Host "🚀 Starting application..." -ForegroundColor Green
try {
    flyctl machine start --app $AppName
} catch {
    Write-Host "⚠️  Could not start machines - may start automatically" -ForegroundColor Yellow
}

# Wait for startup
Write-Host "⏳ Waiting for application to start..." -ForegroundColor Blue
Start-Sleep 10

# Check application status
Write-Host "🏥 Checking application health..." -ForegroundColor Blue
try {
    flyctl status --app $AppName
    Write-Host ""
    Write-Host "🎉 Database upload completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Visit your application URL to verify it's working" -ForegroundColor White
    Write-Host "   2. Test login with your existing admin credentials" -ForegroundColor White
    Write-Host "   3. Verify your data is present and correct" -ForegroundColor White
    Write-Host ""
    Write-Host "📁 Backup of previous production database:" -ForegroundColor Cyan
    Write-Host "   $backupFile" -ForegroundColor White
} catch {
    Write-Host "❌ Application health check failed. Check logs:" -ForegroundColor Red
    Write-Host "   flyctl logs --app $AppName" -ForegroundColor Yellow
}
