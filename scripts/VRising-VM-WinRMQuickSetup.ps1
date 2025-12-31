<#
===============================================================================
NAME:        VRising-VM-WinRMQuickSetup.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     1.1

SYNOPSIS:
    Quick, interactive WinRM-over-HTTPS setup for the VRising VM.

DESCRIPTION:
    This script configures WinRM HTTPS on the VRising VM using a self-signed
    certificate. It:
      - Prompts for the VM's static IPv4 address
      - Creates or reuses a self-signed certificate
      - Removes all existing WinRM listeners
      - Creates a fresh HTTPS listener bound to the certificate
      - Enables WinRM firewall rules
      - Displays the resulting listener configuration

    This is a simplified alternative to the full integrated WinRM setup script
    (VRising-WinRMSetup.ps1). It is intended for quick testing, validation, or
    lightweight environments.

PREREQUISITES:
    - Run inside the VRising VM
    - Run as Administrator
    - VM must have a static IPv4 address

USAGE:
    powershell.exe -File "C:\VRising\Ops\VRising-VM-WinRMQuickSetup.ps1"

NOTES:
    This script is interactive and not intended for automation. For full
    production configuration, use VRising-WinRMSetup.ps1 instead.
===============================================================================
#>

# =============================================================================
# LOGGING HELPERS
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
# PROMPT FOR IP ADDRESS
# =============================================================================

Write-Status "Enter the static IPv4 address for this VM (e.g., 192.168.0.199):" Cyan
$IpAddress = Read-Host "IPv4 Address"

if (-not (Validate-IPv4 $IpAddress)) {
    Write-Status "ERROR: Invalid IPv4 address format. Exiting." Red
    exit 1
}

Write-Status "Using IP address: $IpAddress" Green

# =============================================================================
# ENSURE WINRM SERVICE
# =============================================================================

function Ensure-WinRMService {
    Write-Status "Checking WinRM service state..."

    $svc = Get-Service -Name WinRM -ErrorAction SilentlyContinue
    if (-not $svc) {
        Write-Status "ERROR: WinRM service not found. Cannot continue." Red
        exit 1
    }

    if ($svc.Status -ne 'Running') {
        Write-Status "Starting WinRM service..." Yellow
        Start-Service -Name WinRM
    }

    Write-Status "WinRM service is running." Green
}

Ensure-WinRMService

# =============================================================================
# CERTIFICATE CREATION / REUSE
# =============================================================================

function Get-OrCreateCertificate {
    param([string]$DnsName)

    Write-Status "Searching for existing certificate for CN=$DnsName..."

    $existing = Get-ChildItem Cert:\LocalMachine\My |
        Where-Object {
            $_.Subject -eq "CN=$DnsName" -and
            $_.HasPrivateKey -and
            $_.NotAfter -gt (Get-Date)
        } |
        Sort-Object NotBefore -Descending |
        Select-Object -First 1

    if ($existing) {
        Write-Status "Found existing certificate: $($existing.Thumbprint)" Green
        return $existing
    }

    Write-Status "No valid certificate found. Creating new self-signed certificate..." Yellow

    $newCert = New-SelfSignedCertificate `
        -DnsName $DnsName `
        -CertStoreLocation "Cert:\LocalMachine\My"

    Write-Status "New certificate created: $($newCert.Thumbprint)" Green
    return $newCert
}

$cert = Get-OrCreateCertificate -DnsName $IpAddress
$thumbprint = $cert.Thumbprint

# =============================================================================
# REMOVE EXISTING LISTENERS
# =============================================================================

function Remove-WinRMListeners {
    Write-Status "Removing existing WinRM listeners..." Yellow
    winrm delete winrm/config/Listener?Address=* 2>$null | Out-Null
    Write-Status "Existing listeners removed." Green
}

Remove-WinRMListeners

# =============================================================================
# CREATE HTTPS LISTENER
# =============================================================================

function Create-HttpsListener {
    param(
        [string]$Ip,
        [string]$Thumbprint
    )

    Write-Status "Creating WinRM HTTPS listener for $Ip..." Yellow

    $listenerArgs = "@{Hostname=`"$Ip`";CertificateThumbprint=`"$Thumbprint`"}"
    $cmd = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS $listenerArgs"

    $result = & cmd /c $cmd 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Status "ERROR creating HTTPS listener: $result" Red
        exit 1
    }

    Write-Status "HTTPS listener created successfully." Green
}

Create-HttpsListener -Ip $IpAddress -Thumbprint $thumbprint

# =============================================================================
# ENABLE FIREWALL RULES
# =============================================================================

function Enable-WinRMFirewall {
    Write-Status "Enabling Windows Remote Management firewall rules..." Yellow

    try {
        Get-NetFirewallRule |
            Where-Object { $_.DisplayGroup -eq "Windows Remote Management" } |
            Enable-NetFirewallRule

        Write-Status "WinRM firewall rules enabled." Green
    }
    catch {
        Write-Status "ERROR enabling firewall rules: $_" Red
    }
}

Enable-WinRMFirewall

# =============================================================================
# DISPLAY RESULT
# =============================================================================

Write-Status "Current WinRM listeners:" Cyan
winrm enumerate winrm/config/Listener

Write-Host ""
Write-Status "WinRM over HTTPS is now configured for $IpAddress:5986" Green
Write-Status "From the Hyper-V host, test with:" Cyan
Write-Host ""
Write-Host "    Test-WSMan -ComputerName $IpAddress -UseSSL"
Write-Host ""
Write-Status "If needed, add to TrustedHosts on the host:" Cyan
Write-Host ""
Write-Host "    Set-Item WSMan:\localhost\Client\TrustedHosts -Value `"$IpAddress`" -Force"
Write-Host ""
Write-Status "=== Configuration Complete ===" Cyan
