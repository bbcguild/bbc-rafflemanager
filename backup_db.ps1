# Get timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Build filename
$output = ".\db_backups\raffle_$timestamp.db"

# Download latest DB from server
flyctl sftp get /data/raffle.db $output -a bbcguilds

Write-Host ""
Write-Host "Backup complete:"
Write-Host $output