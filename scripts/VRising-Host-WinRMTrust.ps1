<#
===============================================================================
NAME:        VRising-Host-WinRMTrust.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     1.2

SYNOPSIS:
    Configures and validates WinRM over HTTPS connectivity from the Hyper-V host
    to a target VM. Supports:
      - Prompting for VM IP
      - Updating TrustedHosts
      - Testing WinRM HTTPS connectivity
      - Optional PSRemoting test using stored credentials

DESCRIPTION:
    This script is used during initial setup and troubleshooting of secure
    WinRM communication between the Hyper-V host and the VRising VM. It ensures
    that:
      - The VM is reachable over WinRM HTTPS
      - TrustedHosts is configured correctly
      - Stored credentials can authenticate successfully

PREREQUISITES:
    - WinRM HTTPS listener configured on the VM
    - Host must trust the VM certificate (or use TrustedHosts)
    - Credential XML stored in KeyVault directory

USAGE:
    Run manually during setup or troubleshooting:
        powershell.exe -File "C:\Hyper V\Scripts\VRising-Host-WinRMTrust.ps1"

NOTES:
    This script is interactive by design and is not intended for automation.
===============================================================================
#>

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-Status {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] $Message" -ForegroundColor $Color
}

function Validate-IPv4 {
    param([string]$Ip)
    $pattern = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$'
    return $Ip -match $pattern
}

# =============================================================================
# STEP 1 — PROMPT FOR VM IP
# =============================================================================

Write-Status "Enter the static IPv4 address of the VM (e.g., 192.168.0.199):" Cyan
$VmIp = Read-Host "VM IPv4 Address"

if (-not (Validate-IPv4 $VmIp)) {
    Write-Status "ERROR: Invalid IPv4 address format. Exiting." Red
    exit 1
}

Write-Status "Using VM IP: $VmIp" Green

# =============================================================================
# STEP 2 — UPDATE TRUSTEDHOSTS (OPTIONAL)
# =============================================================================

function Update-TrustedHosts {
    param([string]$Ip)

    Write-Status "Current TrustedHosts value:" Cyan
    $current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    Write-Host "    $current"
    Write-Host ""

    $response = Read-Host "Add $Ip to TrustedHosts? (Y/N)"
    if ($response -notin @("Y","y","Yes","yes")) {
        Write-Status "Skipping TrustedHosts update." Yellow
        return
    }

    if ([string]::IsNullOrWhiteSpace($current)) {
        $newValue = $Ip
    }
    else {
        if ($current -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -eq $Ip }) {
            Write-Status "$Ip is already present in TrustedHosts." Green
            return
        }
        $newValue = "$current,$Ip"
    }

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $newValue -Force
    Write-Status "TrustedHosts updated: $newValue" Green
}

Update-TrustedHosts -Ip $VmIp

# =============================================================================
# STEP 3 — TEST WINRM HTTPS CONNECTIVITY
# =============================================================================

function Test-WinRMHttps {
    param([string]$Ip)

    Write-Status "Testing WinRM over HTTPS to $Ip..." Cyan

    try {
        $result = Test-WSMan -ComputerName $Ip -UseSSL -ErrorAction Stop
        Write-Status "WinRM HTTPS test succeeded." Green
        $result
        return $true
    }
    catch {
        Write-Status "ERROR: WinRM HTTPS test failed: $_" Red
        return $false
    }
}

$winrmOk = Test-WinRMHttps -Ip $VmIp

# =============================================================================
# STEP 4 — OPTIONAL PSREMOTING TEST
# =============================================================================

function Test-PSRemotingWithCredential {
    param(
        [string]$Ip,
        [string]$CredentialPath
    )

    if (-not (Test-Path $CredentialPath)) {
        Write-Status "Credential file not found at: $CredentialPath" Red
        return
    }

    Write-Status "Importing credential from: $CredentialPath" Cyan
    $Cred = Import-Clixml -Path $CredentialPath

    Write-Status "Testing PSRemoting to $Ip using stored credential..." Cyan
    try {
        $hostname = Invoke-Command -ComputerName $Ip -UseSSL -Credential $Cred -ScriptBlock { hostname } -ErrorAction Stop
        Write-Status "PSRemoting succeeded. Remote hostname: $hostname" Green
    }
    catch {
        Write-Status "ERROR: PSRemoting test failed: $_" Red
    }
}

if ($winrmOk) {
    Write-Host ""
    $doCredTest = Read-Host "Test PSRemoting using stored credential XML? (Y/N)"
    if ($doCredTest -in @("Y","y","Yes","yes")) {
        $defaultCredPath = "C:\Hyper V\KeyVault\HO-VR-HV01\PSRemoting.xml"
        Write-Status "Enter credential file path or press Enter for default:" Cyan
        Write-Host "Default: $defaultCredPath"
        $pathInput = Read-Host "Credential XML path"
        if ([string]::IsNullOrWhiteSpace($pathInput)) {
            $pathInput = $defaultCredPath
        }

        Test-PSRemotingWithCredential -Ip $VmIp -CredentialPath $pathInput
    }
    else {
        Write-Status "Skipping PSRemoting credential test." Yellow
    }
}
else {
    Write-Status "Skipping PSRemoting test because WinRM HTTPS is not working." Red
}

Write-Host ""
Write-Status "=== Host-side WinRM validation complete ===" Cyan
