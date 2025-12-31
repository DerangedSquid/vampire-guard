<#
===============================================================================
NAME:        VRising-VM-Setup.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     2.0

SYNOPSIS:
    Fully automated bootstrap for the VRising Dedicated Server inside the VM.

DESCRIPTION:
    This script performs a complete, deterministic setup of the VRising server:
      - Cleans any previous installation
      - Recreates directory structure
      - Downloads and installs SteamCMD
      - Installs VRising Dedicated Server
      - Performs a first-run to generate required files
      - Copies template configuration files
      - Applies automatic configuration (server name, ports, save name)
      - Validates configuration
      - Optionally installs VRising as a Windows service via NSSM

    This script is safe to re-run and is designed for idempotent behavior.

PREREQUISITES:
    - Run inside the VRising VM as Administrator
    - Internet access for SteamCMD download
    - NSSM installed at C:\nssm\nssm.exe (optional)

USAGE:
    powershell.exe -File "C:\VRising\Ops\VRising-VM-Setup.ps1"

NOTES:
    This script prepares the VM for hardening and automation. It should be run
    before executing VRising-VM-Harden.ps1.
===============================================================================
#>

# =============================================================================
# CONFIGURATION
# =============================================================================

$basePath      = "C:\VRising"
$steamcmdPath  = "$basePath\SteamCMD"
$serverRoot    = "$basePath\Server"
$dataRoot      = "$basePath\Data"
$worldName     = "world1"
$dataPath      = "$dataRoot\$worldName"
$localLowPath  = Join-Path $env:USERPROFILE "AppData\LocalLow\Stunlock Studios\VRisingServer"

# Customization
$serverName    = "HO-VR-HV01 VRising Server"
$serverPort    = 9876
$queryPort     = 9877

Write-Host "=== VRising Automated Setup Starting ===" -ForegroundColor Cyan

# =============================================================================
# PHASE 1 — CLEAN ENVIRONMENT
# =============================================================================

Write-Host "=== Cleaning old environment ===" -ForegroundColor Cyan

Get-Process VRisingServer -ErrorAction SilentlyContinue | Stop-Process -Force

$pathsToRemove = @(
    $steamcmdPath,
    $serverRoot,
    $dataRoot,
    $localLowPath
)

foreach ($p in $pathsToRemove) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Environment cleaned." -ForegroundColor Green

# =============================================================================
# PHASE 2 — RECREATE DIRECTORY STRUCTURE
# =============================================================================

Write-Host "=== Creating directory structure ===" -ForegroundColor Cyan

New-Item -ItemType Directory -Path $steamcmdPath -Force | Out-Null
New-Item -ItemType Directory -Path $serverRoot -Force | Out-Null
New-Item -ItemType Directory -Path $dataPath -Force | Out-Null

Write-Host "Directory structure created." -ForegroundColor Green

# =============================================================================
# PHASE 3 — DOWNLOAD STEAMCMD
# =============================================================================

Write-Host "=== Downloading SteamCMD ===" -ForegroundColor Cyan

$steamcmdZip = "$steamcmdPath\steamcmd.zip"
Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $steamcmdZip
Expand-Archive -Path $steamcmdZip -DestinationPath $steamcmdPath -Force
Remove-Item $steamcmdZip -Force

Write-Host "SteamCMD downloaded and extracted." -ForegroundColor Green

# =============================================================================
# PHASE 4 — INSTALL VRISING SERVER
# =============================================================================

Write-Host "=== Installing VRising Dedicated Server ===" -ForegroundColor Cyan

$steamInstallTarget = Join-Path $serverRoot "vrisingdedicatedserver"

cd $steamcmdPath
.\steamcmd.exe +force_install_dir "C:\\VRising\\Server\\vrisingdedicatedserver" +login anonymous +app_update 1829350 validate +quit

Write-Host "VRising server installed." -ForegroundColor Green

# =============================================================================
# PHASE 5 — DETECT VRISINGSERVER.EXE
# =============================================================================

Write-Host "=== Detecting VRisingServer.exe ===" -ForegroundColor Cyan

$exe = Get-ChildItem -Path $serverRoot -Recurse -Filter "VRisingServer.exe" | Select-Object -First 1

if (-not $exe) {
    Write-Host "ERROR: VRisingServer.exe not found." -ForegroundColor Red
    exit 1
}

$serverPath = $exe.Directory.FullName
Write-Host "VRising server detected at: $serverPath" -ForegroundColor Green

# =============================================================================
# PHASE 6 — FIRST RUN (GENERATE LIST FILES)
# =============================================================================

Write-Host "=== Running server once to initialize ===" -ForegroundColor Cyan

Start-Process -FilePath "$serverPath\VRisingServer.exe" -WorkingDirectory $serverPath -Wait

Write-Host "Initial run complete." -ForegroundColor Green

# =============================================================================
# PHASE 7 — COPY TEMPLATE CONFIGS
# =============================================================================

Write-Host "=== Copying template configs ===" -ForegroundColor Cyan

$templateSettings = Join-Path $serverPath "VRisingServer_Data\StreamingAssets\Settings"
$worldSettingsPath = Join-Path $dataPath "Settings"

New-Item -ItemType Directory -Path $worldSettingsPath -Force | Out-Null

Copy-Item "$templateSettings\ServerHostSettings.json" $worldSettingsPath -Force
Copy-Item "$templateSettings\ServerGameSettings.json" $worldSettingsPath -Force

Write-Host "Template configs copied." -ForegroundColor Green

# =============================================================================
# PHASE 8 — APPLY AUTOMATIC CONFIGURATION
# =============================================================================

Write-Host "=== Applying automatic configuration ===" -ForegroundColor Cyan

$hostFile = Join-Path $worldSettingsPath "ServerHostSettings.json"
$gameFile = Join-Path $worldSettingsPath "ServerGameSettings.json"

$hostJson = Get-Content $hostFile | ConvertFrom-Json
$gameJson = Get-Content $gameFile | ConvertFrom-Json

$hostJson.Name     = $serverName
$hostJson.Port     = $serverPort
$hostJson.QueryPort = $queryPort
$hostJson.SaveName = $worldName

$hostJson | ConvertTo-Json -Depth 10 | Set-Content $hostFile
$gameJson | ConvertTo-Json -Depth 10 | Set-Content $gameFile

Write-Host "Automatic configuration applied." -ForegroundColor Green

# =============================================================================
# PHASE 9 — VALIDATION
# =============================================================================

Write-Host "=== Validating configuration ===" -ForegroundColor Cyan

if (-not (Test-Path $hostFile)) { Write-Host "ERROR: Host config missing." -ForegroundColor Red; exit 1 }
if (-not (Test-Path $gameFile)) { Write-Host "ERROR: Game config missing." -ForegroundColor Red; exit 1 }

Write-Host "Config files validated." -ForegroundColor Green

# =============================================================================
# PHASE 10 — INSTALL AS WINDOWS SERVICE (NSSM)
# =============================================================================

Write-Host "=== Installing VRising as a Windows Service ===" -ForegroundColor Cyan

$nssmPath = "C:\nssm\nssm.exe"

if (-not (Test-Path $nssmPath)) {
    Write-Host "NSSM not found at $nssmPath" -ForegroundColor Yellow
    Write-Host "Download NSSM and place nssm.exe at C:\nssm\nssm.exe" -ForegroundColor Yellow
} else {
    & $nssmPath install VRisingServer "$serverPath\VRisingServer.exe" "-persistentDataPath `"$dataPath`""
    & $nssmPath set VRisingServer Start SERVICE_AUTO_START
    Write-Host "Service installed: VRisingServer" -ForegroundColor Green
}

# =============================================================================
# DONE
# =============================================================================

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host "Launch manually with:" -ForegroundColor Yellow
Write-Host "  cd `"$serverPath`""
Write-Host "  .\VRisingServer.exe -persistentDataPath `"$dataPath`""
Write-Host ""
