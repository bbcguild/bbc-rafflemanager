# upload-db.ps1 - Upload local database to a Fly.io environment
#
# Usage:
#   .\upload-db.ps1 <environment> [-LocalDbPath <path>] [-Force]
#
# Environments:
#   dev      - Development  (bbcguild-raffle-dev)
#   test     - Test         (bbcguild-raffle-test)
#   staging  - Staging      (bbcguild-raffle-staging)
#   prod     - Production   (bbcguild-raffle)
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
    Write-Host "  dev      - Development  (bbcguild-raffle-dev)"
    Write-Host "  test     - Test         (bbcguild-raffle-test)"
    Write-Host "  staging  - Staging      (bbcguild-raffle-staging)"
    Write-Host "  prod     - Production   (bbcguild-raffle)"
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
    'staging' { 'bbcguilds' }
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
flyctl ssh console --app $AppName -C "cp $RemoteDbPath ${RemoteDbPath}.backup.$timestamp 2>/dev/null && echo 'Backup created: ${RemoteDbPath}.backup.$timestamp' || echo 'No existing database to back up'"

# --- Upload ---

Write-Host ""
Write-Info "Uploading $LocalDbPath -> $RemoteDbPath ..."
flyctl ssh sftp shell --app $AppName --command "put `"$LocalDbPath`" `"$RemoteDbPath`""

if ($LASTEXITCODE -ne 0) {
    Write-Err "Upload failed (exit code $LASTEXITCODE)."
    Write-Host ""
    Write-Info "To upload manually:"
    Write-Host "  flyctl ssh sftp shell --app $AppName"
    Write-Host "  sftp> put `"$LocalDbPath`" `"$RemoteDbPath`""
    exit 1
}

# Fix ownership and permissions
flyctl ssh console --app $AppName -C "chown app:app $RemoteDbPath && chmod 644 $RemoteDbPath"

# --- Verify size ---

Write-Host ""
Write-Info "Verifying upload..."
$remoteSize = (flyctl ssh console --app $AppName -C "stat -c%s $RemoteDbPath" 2>$null | Out-String).Trim()
if ($remoteSize -eq "$localSize") {
    Write-Ok "Verified: remote size matches local ($remoteSize bytes)"
} else {
    Write-Warn "Size check: local=$localSize remote=$remoteSize (verify manually if concerned)"
}

# --- Restart ---

Write-Host ""
Write-Info "Restarting application..."
flyctl machine restart --app $AppName
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Restart returned an error; app may restart automatically on next request."
}

Write-Host ""
Write-Ok "Database upload to $Environment complete."
Write-Info "App URL:      https://$AppName.fly.dev"
Write-Info "Health check: https://$AppName.fly.dev/health"
