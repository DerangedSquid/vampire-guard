<#
===============================================================================
NAME:        VRising-VM-StartServer.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     1.2

SYNOPSIS:
    Starts the VRising dedicated server inside the VM, logs events, and sends
    Discord notifications for operational visibility.

DESCRIPTION:
    This script:
      - Validates VRising installation paths
      - Ensures the server is not already running
      - Starts VRisingServer.exe with the correct persistent data path
      - Logs all actions to C:\VRising\Logs
      - Sends Discord notifications for success/failure states

    Intended to be run inside the VRising VM, either manually or via a scheduled
    task at startup.

PREREQUISITES:
    - VRising installed at C:\VRising\Server\vrisingdedicatedserver
    - Data directory at C:\VRising\Data\world1
    - Discord webhook configured

USAGE:
    powershell.exe -File "C:\VRising\Ops\VRising-VM-StartServer.ps1"

NOTES:
    This script is part of the VampireGuard automation suite and is designed
    to be idempotent — safe to run repeatedly.
===============================================================================
#>

# =============================================================================
# CONFIGURATION
# =============================================================================

$ServerPath = "C:\VRising\Server\vrisingdedicatedserver"
$DataPath   = "C:\VRising\Data\world1"
$Executable = Join-Path $ServerPath "VRisingServer.exe"

$DiscordWebhookUrl = "YOUR_WEBHOOK_URL_HERE"

$LogDir = "C:\VRising\Logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}
$LogFile = Join-Path $LogDir ("StartLog_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".log")

# =============================================================================
# LOGGING
# =============================================================================

function Write-Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"

    Add-Content -Path $LogFile -Value $entry
    Write-Host $entry
}

function Send-DiscordNotification {
    param([string]$Message)

    try {
        $payload = @{ content = $Message } | ConvertTo-Json
        Invoke-RestMethod -Uri $DiscordWebhookUrl -Method Post -ContentType "application/json" -Body $payload
        Write-Log "Discord notification sent: $Message"
    }
    catch {
        Write-Log "Failed to send Discord notification: $_"
    }
}

# =============================================================================
# STARTUP SEQUENCE
# =============================================================================

Write-Log "=== VampireGuard Startup Sequence Initiated ==="

# --- Validate executable ---
if (-not (Test-Path $Executable)) {
    Write-Log "ERROR: VRisingServer.exe not found at $Executable"
    Send-DiscordNotification ":x: VRising server failed to start — executable missing!"
    exit 1
}

# --- Validate persistent data path ---
if (-not (Test-Path $DataPath)) {
    Write-Log "ERROR: Persistent data path missing: $DataPath"
    Send-DiscordNotification ":x: VRising server failed to start — data path missing!"
    exit 1
}

Write-Log "Environment validation passed."

# --- Detect if server is already running ---
$running = Get-Process "VRisingServer" -ErrorAction SilentlyContinue

if ($running) {
    Write-Log "VRising server is already running."
    Send-DiscordNotification ":white_check_mark: VRising server is already online inside the VM."
    exit 0
}

# =============================================================================
# START VRISING SERVER
# =============================================================================

Write-Log "Launching VRising server..."

try {
    Start-Process -FilePath $Executable `
        -ArgumentList "-persistentDataPath `"$DataPath`"" `
        -WorkingDirectory $ServerPath `
        -NoNewWindow

    Write-Log "VRising server launched successfully."
    Send-DiscordNotification ":rocket: VRising server is starting up inside the VM. The vampire realm awakens."
}
catch {
    Write-Log "ERROR: Failed to launch VRising server: $_"
    Send-DiscordNotification ":x: VRising server failed to launch inside the VM. Error: $_"
    exit 1
}

Write-Log "=== VampireGuard Startup Sequence Complete ==="
