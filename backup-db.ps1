# backup-db.ps1 - Download a Fly.io raffle database backup to a local timestamped file
#
# Usage:
#   .\backup-db.ps1 <environment> [-OutputDir <path>] [-Force]
#
# Environments:
#   dev      - Development  (bbcguilds)
#   test     - Test         (bbcguilds)
#   staging  - Staging      (bbcguilds-staging)
#   prod     - Production   (bbcguilds)

param(
    [Parameter(Position = 0)]
    [string]$Environment = "prod",

    [string]$OutputDir = ".\backups",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Info  { param([string]$msg) Write-Host $msg -ForegroundColor Blue }
function Write-Ok    { param([string]$msg) Write-Host $msg -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Err   { param([string]$msg) Write-Host $msg -ForegroundColor Red }

function Show-Usage {
    Write-Host "Usage: .\backup-db.ps1 <environment> [-OutputDir <path>] [-Force]"
    Write-Host ""
    Write-Host "Environments:"
    Write-Host "  dev      - Development  (bbcguilds)"
    Write-Host "  test     - Test         (bbcguilds)"
    Write-Host "  staging  - Staging      (bbcguilds-staging)"
    Write-Host "  prod     - Production   (bbcguilds)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\backup-db.ps1 prod"
    Write-Host "  .\backup-db.ps1 staging"
    Write-Host "  .\backup-db.ps1 prod -OutputDir .\db-backups"
    exit 1
}

$AppName = switch ($Environment) {
    "dev"     { "bbcguilds" }
    "test"    { "bbcguilds" }
    "staging" { "bbcguilds-staging" }
    "prod"    { "bbcguilds" }
    default   {
        Write-Err "Error: Invalid environment '$Environment'"
        Write-Host ""
        Show-Usage
    }
}

$RemoteDbPath = "/data/raffle.db"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Info "BBC Guild Raffle Manager - Database Backup"
Write-Host "============================================"
Write-Info "Environment: $Environment"
Write-Info "App:         $AppName"

if (-not (Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Err "flyctl is not installed. See: https://fly.io/docs/flyctl/install/"
    exit 1
}

$null = flyctl auth whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Not logged into fly.io. Run: flyctl auth login"
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$resolvedOutputDir = (Resolve-Path $OutputDir).Path
$outputFile = Join-Path $resolvedOutputDir ("{0}-raffle-backup-{1}.db" -f $Environment, $timestamp)

if ((Test-Path $outputFile) -and -not $Force) {
    Write-Err "Backup file already exists: $outputFile"
    exit 1
}

Write-Host ""
Write-Info "Checking machine status..."
$machineStatus = flyctl machine list --app $AppName 2>$null | Out-String
if ($machineStatus -notmatch "started") {
    Write-Warn "No running machines found. Starting a machine..."
    flyctl machine start --app $AppName
    Write-Info "Waiting for machine to become ready..."
    Start-Sleep 15
}

Write-Host ""
Write-Info "Downloading $RemoteDbPath -> $outputFile ..."
flyctl ssh sftp get $RemoteDbPath $outputFile --app $AppName

if ($LASTEXITCODE -ne 0) {
    Write-Err "Backup download failed."
    exit 1
}

$localSize = (Get-Item $outputFile).Length
Write-Ok "Backup complete: $outputFile ($localSize bytes)"

Write-Host ""
Write-Info "Optional next step: copy that file to cloud storage or another machine."
