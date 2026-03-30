# Simple Database Upload to Fly.io
# Uses SSH console with direct file operations

param(
    [string]$AppName = "bbcguild-raffle-test",
    [string]$LocalDbPath = ".\raffle.db"
)

Write-Host "📤 Simple Database Upload to Fly.io" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Check if local database exists
if (!(Test-Path $LocalDbPath)) {
    Write-Host "❌ Local database not found at: $LocalDbPath" -ForegroundColor Red
    exit 1
}

$localSize = (Get-Item $LocalDbPath).Length
Write-Host "📁 Local database: $LocalDbPath ($localSize bytes)" -ForegroundColor Green

# Backup existing production database
Write-Host ""
Write-Host "📦 Downloading production database for backup..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = "production-backup-$timestamp.db"

Write-Host "🔧 Manual upload process required:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Due to flyctl SFTP changes, please follow these steps:" -ForegroundColor White
Write-Host ""
Write-Host "1️⃣ First, backup the existing database:" -ForegroundColor Cyan
Write-Host "   flyctl ssh console --app $AppName" -ForegroundColor White
Write-Host "   cp /data/raffle.db /data/raffle.db.backup" -ForegroundColor White
Write-Host "   exit" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣ Open an SFTP session:" -ForegroundColor Cyan  
Write-Host "   flyctl ssh sftp shell --app $AppName" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣ At the sftp> prompt, upload your database:" -ForegroundColor Cyan
Write-Host "   If file exists, first rename it:" -ForegroundColor Yellow
Write-Host "   rename /data/raffle.db /data/raffle.db.backup" -ForegroundColor White
Write-Host "   Then upload your file:" -ForegroundColor Yellow
Write-Host "   put `"$LocalDbPath`" `"/data/raffle.db`"" -ForegroundColor White
Write-Host "   quit" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣ Restart your application:" -ForegroundColor Cyan
Write-Host "   flyctl machine restart --app $AppName" -ForegroundColor White
Write-Host ""
Write-Host "5️⃣ Verify the upload worked:" -ForegroundColor Cyan
Write-Host "   Visit your application URL and test login" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Would you like me to open the SFTP session for you? [y/N]"
if ($continue -eq "y" -or $continue -eq "Y") {
    Write-Host ""
    Write-Host "🚀 Opening SFTP session..." -ForegroundColor Green
    Write-Host "If you get 'file exists', type these commands:" -ForegroundColor Yellow
    Write-Host "1. rename /data/raffle.db /data/raffle.db.backup" -ForegroundColor White
    Write-Host "2. put `"$LocalDbPath`" `"/data/raffle.db`"" -ForegroundColor White
    Write-Host "3. quit" -ForegroundColor White
    Write-Host ""
    
    flyctl ssh sftp shell --app $AppName
    
    Write-Host ""
    Write-Host "✅ SFTP session completed" -ForegroundColor Green
    Write-Host "Don't forget to restart your app:" -ForegroundColor Yellow
    Write-Host "flyctl machine restart --app $AppName" -ForegroundColor White
} else {
    Write-Host "👋 Run the commands above when you're ready to upload!" -ForegroundColor Green
}
