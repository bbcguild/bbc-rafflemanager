# Ask which file to restore
$file = Read-Host "Enter backup file name (inside db_backups)"

$path = ".\db_backups\$file"

if (!(Test-Path $path)) {
    Write-Host "File not found!"
    exit
}

Write-Host "Restoring $file..."

# Backup current live DB first (server-side safety)
flyctl ssh console -a bbcguilds --command "cp /data/raffle.db /data/raffle_pre_restore.db"

# Remove current DB
flyctl ssh console -a bbcguilds --command "rm /data/raffle.db"

# Upload selected backup
flyctl sftp put $path /data/raffle.db -a bbcguilds

# Restart app machines
flyctl machine list -a bbcguilds
flyctl apps restart bbcguilds

Write-Host "Restore complete."