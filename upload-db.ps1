# upload-db.ps1 - Upload local database to a Fly.io environment
#
# Usage:
#   .\upload-db.ps1 <environment> [-LocalDbPath <path>] [-Force]
#
# Environments:
#   dev      - Development  (bbcguilds)
#   test     - Test         (bbcguilds)
#   staging  - Staging      (bbcguilds-staging)
#   prod     - Production   (bbcguilds)
#
# Options:
#   -LocalDbPath  Path to the local .db file to upload (default: .\raffle.db)
#   -Force        Skip confirmation prompts (use when calling from other scripts)
#
# Examples:
#   .\upload-db.ps1 dev
#   .\upload-db.ps1 prod -LocalDbPath .\export.db
#   .\upload-db.ps1 staging -Force

param(
    [Parameter(Position = 0)]
    [string]$Environment,

    [string]$LocalDbPath = ".\raffle.db",

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Write-Info  { param([string]$msg) Write-Host $msg -ForegroundColor Blue }
function Write-Ok    { param([string]$msg) Write-Host $msg -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Err   { param([string]$msg) Write-Host $msg -ForegroundColor Red }

function Show-Usage {
    Write-Host "Usage: .\upload-db.ps1 <environment> [-LocalDbPath <path>] [-Force]"
    Write-Host ""
    Write-Host "Environments:"
    Write-Host "  dev      - Development  (bbcguilds)"
    Write-Host "  test     - Test         (bbcguilds)"
    Write-Host "  staging  - Staging      (bbcguilds-staging)"
    Write-Host "  prod     - Production   (bbcguilds)"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -LocalDbPath  Path to local database file (default: .\raffle.db)"
    Write-Host "  -Force        Skip confirmation prompts"
    exit 1
}

Write-Info "BBC Guild Raffle Manager - Database Upload"
Write-Host "============================================"

if (-not $Environment) {
    Write-Err "Error: Environment must be specified"
    Write-Host ""
    Show-Usage
}

$AppName = switch ($Environment) {
    'dev'     { 'bbcguilds' }
    'test'    { 'bbcguilds' }
    'staging' { 'bbcguilds-staging' }
    'prod'    { 'bbcguilds' }
    default   {
        Write-Err "Error: Invalid environment '$Environment'"
        Write-Host ""
        Show-Usage
    }
}

$RemoteDbPath = '/data/raffle.db'

Write-Info "Environment: $Environment"
Write-Info "App:         $AppName"
Write-Info "Source:      $LocalDbPath"

# --- Preflight checks ---

if (-not (Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Err "flyctl is not installed. See: https://fly.io/docs/flyctl/install/"
    exit 1
}

$null = flyctl auth whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Not logged into fly.io. Run: flyctl auth login"
    exit 1
}

if (-not (Test-Path $LocalDbPath)) {
    Write-Err "Local database not found: $LocalDbPath"
    exit 1
}

$localSize = (Get-Item $LocalDbPath).Length
Write-Ok "Local database found: $LocalDbPath ($localSize bytes)"

# --- Confirmation ---

if ($Environment -eq 'prod' -and -not $Force) {
    Write-Host ""
    Write-Err "WARNING: You are about to overwrite the PRODUCTION database!"
    Write-Host ""
    $confirm = Read-Host "Type 'YES' to confirm"
    if ($confirm -ne 'YES') {
        Write-Warn "Upload cancelled."
        exit 1
    }
} elseif (-not $Force) {
    Write-Host ""
    Write-Warn "This will replace the database on: $AppName"
    $confirm = Read-Host "Continue? (y/N)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Warn "Upload cancelled."
        exit 1
    }
}

# --- Ensure a machine is running ---

Write-Host ""
Write-Info "Checking machine status..."
$machineStatus = flyctl machine list --app $AppName 2>$null | Out-String
if ($machineStatus -notmatch 'started') {
    Write-Warn "No running machines found. Starting a machine..."
    flyctl machine start --app $AppName
    Write-Info "Waiting for machine to become ready..."
    Start-Sleep 15
}

# --- Back up the remote database ---

Write-Host ""
Write-Info "Backing up remote database..."
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
flyctl ssh console --app $AppName --pty=false -C "if [ -f $RemoteDbPath ]; then cp $RemoteDbPath ${RemoteDbPath}.backup.$timestamp && mv $RemoteDbPath ${RemoteDbPath}.previous.$timestamp && echo 'Backup created: ${RemoteDbPath}.backup.$timestamp'; else echo 'No existing database to back up'; fi"

if ($LASTEXITCODE -ne 0) {
    Write-Err "Failed while preparing the remote database path."
    exit 1
}

# --- Upload ---

Write-Host ""
Write-Info "Uploading $LocalDbPath -> $RemoteDbPath ..."
flyctl ssh sftp put $LocalDbPath $RemoteDbPath --app $AppName

if ($LASTEXITCODE -ne 0) {
    Write-Err "Upload failed (exit code $LASTEXITCODE)."
    Write-Host ""
    Write-Info "To upload manually:"
    Write-Host "  flyctl ssh sftp put `"$LocalDbPath`" `"$RemoteDbPath`" --app $AppName"
    exit 1
}

# Fix ownership and permissions
flyctl ssh console --app $AppName --pty=false -C "chown app:app $RemoteDbPath && chmod 644 $RemoteDbPath"

# --- Verify size ---

Write-Host ""
Write-Info "Verifying upload..."
$remoteSize = (flyctl ssh console --app $AppName --pty=false -C "stat -c%s $RemoteDbPath" 2>$null | Out-String).Trim()
if ($remoteSize -eq "$localSize") {
    Write-Ok "Verified: remote size matches local ($remoteSize bytes)"
} else {
    Write-Warn "Size check: local=$localSize remote=$remoteSize (verify manually if concerned)"
}

# --- Restart ---

Write-Host ""
Write-Info "Restarting application..."
$machineId = (flyctl machine list --app $AppName --json | ConvertFrom-Json | Select-Object -First 1 -ExpandProperty id)
if (-not $machineId) {
    Write-Warn "No machine ID found to restart; app may reopen the database on next request."
} else {
    flyctl machine restart $machineId --app $AppName
}
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Restart returned an error; app may restart automatically on next request."
}

Write-Host ""
Write-Ok "Database upload to $Environment complete."
Write-Info "App URL:      https://$AppName.fly.dev"
Write-Info "Health check: https://$AppName.fly.dev/health"
