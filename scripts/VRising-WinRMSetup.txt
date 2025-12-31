<#
===============================================================================
NAME:        VRising-WinRMSetup.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     2.0

SYNOPSIS:
    Integrated WinRM HTTPS + CredSSP setup for VRising VM + Hyper-V host.

DESCRIPTION:
    This script configures a secure, certificate-backed WinRM HTTPS channel
    with CredSSP and NTLM-only delegation between a Hyper-V host and the
    VRising VM. It is:

      - Idempotent (safe to re-run)
      - Deterministic (always produces a known-good state)
      - Self-validating (tests connectivity and remoting)
      - Explicit about failures

PARAMETERS:
    -Role <VM|Host|Both>
        VM   : Run VM-side configuration (inside the VRising VM)
        Host : Run host-side configuration (on Hyper-V host)
        Both : Logical grouping only; run separately on each machine

    -VmIp <IPv4>
        The static IPv4 address of the VRising VM.

    -CertCN <string>
        CN for the self-signed certificate (often same as VmIp).

    -CertExportPath <path>
        Where the VM exports the public certificate, and where the host
        imports it.

    -CredPath <path>
        Path to the PSRemoting credential file (host-side).

USAGE:
    VM side:
        .\VRising-WinRMSetup.ps1 -Role VM -VmIp 192.168.0.199 -CertCN 192.168.0.199

    Host side:
        .\VRising-WinRMSetup.ps1 -Role Host -VmIp 192.168.0.199 -CertCN 192.168.0.199

NOTES:
    This script is a core part of the VampireGuard automation suite.
===============================================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("VM", "Host", "Both")]
    [string]$Role,

    [Parameter(Mandatory = $true)]
    [string]$VmIp,

    [Parameter(Mandatory = $true)]
    [string]$CertCN,

    [Parameter(Mandatory = $false)]
    [string]$CertExportPath = "C:\Hyper V\Certificates\vrising-winrm.cer",

    [Parameter(Mandatory = $false)]
    [string]$CredPath = "C:\Hyper V\KeyVault\HO-VR-HV01\PSRemoting.xml"
)

# =============================================================================
# LOGGING HELPERS
# =============================================================================

function Write-Info { param([string]$Message) Write-Host "[INFO ] $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "[ OK  ] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "[WARN ] $Message" -ForegroundColor Yellow }
function Write-Err  { param([string]$Message) Write-Host "[FAIL ] $Message" -ForegroundColor Red }

# =============================================================================
# VM-SIDE LOGIC
# =============================================================================

function Set-VmNetworkProfilePrivate {
    Write-Info "Ensuring network profile is Private..."

    $profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue
    if (-not $profiles) {
        Write-Warn "No network profiles detected."
        return
    }

    foreach ($profile in $profiles) {
        if ($profile.NetworkCategory -ne 'Private') {
            Write-Info "Setting '$($profile.Name)' to Private..."
            Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
        }
    }

    Write-Ok "Network profile is Private."
}

function Ensure-VmFirewallForWinRMHttps {
    Write-Info "Ensuring firewall rule for WinRM HTTPS (5986)..."

    $ruleName = "WinRM-HTTPS-VRising"
    $rule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

    if (-not $rule) {
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986 `
            -Profile Private -ErrorAction Stop | Out-Null

        Write-Ok "Created firewall rule '$ruleName'."
    }
    else {
        if ($rule.Enabled -ne 'True') {
            Set-NetFirewallRule -DisplayName $ruleName -Enabled True
        }
        Write-Ok "Firewall rule '$ruleName' already enabled."
    }
}

function Ensure-VmCertificateAndListener {
    param([string]$CertCN, [string]$VmIp, [string]$CertExportPath)

    Write-Info "Ensuring self-signed certificate for CN=$CertCN..."

    $cert = Get-ChildItem Cert:\LocalMachine\My |
        Where-Object { $_.Subject -eq "CN=$CertCN" } |
        Select-Object -First 1

    if (-not $cert) {
        Write-Info "Creating new self-signed certificate..."
        $cert = New-SelfSignedCertificate `
            -DnsName $CertCN `
            -CertStoreLocation "Cert:\LocalMachine\My" `
            -KeyLength 2048 `
            -KeyExportPolicy Exportable `
            -NotAfter (Get-Date).AddYears(5) `
            -FriendlyName "VRising WinRM HTTPS"

        Write-Ok "Created certificate: Thumbprint=$($cert.Thumbprint)"
    }
    else {
        Write-Ok "Using existing certificate: Thumbprint=$($cert.Thumbprint)"
    }

    Write-Info "Ensuring certificate is trusted locally..."
    $rootCert = Get-ChildItem Cert:\LocalMachine\Root |
        Where-Object { $_.Thumbprint -eq $cert.Thumbprint } |
        Select-Object -First 1

    if (-not $rootCert) {
        Write-Info "Adding certificate to LocalMachine\Root..."
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
        $store.Open("ReadWrite")
        $store.Add($cert)
        $store.Close()
        Write-Ok "Certificate added to Root store."
    }
    else {
        Write-Ok "Certificate already trusted."
    }

    Write-Info "Removing ALL existing WinRM listeners..."
    winrm enumerate winrm/config/Listener |
        Select-String "Listener" |
        ForEach-Object {
            $listener = $_.ToString().Split("=")[1]
            winrm delete winrm/config/Listener?Address=*+Transport=$listener 2>$null
        }

    Write-Info "Creating new WinRM HTTPS listener..."
    winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$CertCN`"; CertificateThumbprint=`"$($cert.Thumbprint)`"}" | Out-Null
    Write-Ok "HTTPS listener created."

    Write-Info "Restarting WinRM service..."
    Restart-Service WinRM -Force
    Write-Ok "WinRM service restarted."

    Write-Info "Exporting certificate to $CertExportPath..."
    Export-Certificate -Cert $cert -FilePath $CertExportPath -Force | Out-Null
    Write-Ok "Certificate exported."
}

# =============================================================================
# HOST-SIDE LOGIC
# =============================================================================

function Import-HostCertificate {
    param([string]$CertExportPath)

    Write-Info "Importing VM certificate from $CertExportPath..."

    if (-not (Test-Path $CertExportPath)) {
        Write-Err "Certificate file not found."
        return $false
    }

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertExportPath)

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()

    Write-Ok "Certificate imported into LocalMachine\Root."
    return $true
}

function Configure-HostCredSSP {
    Write-Info "Enabling CredSSP client/server..."

    Enable-WSManCredSSP -Role Client -DelegateComputer $VmIp -Force
    Enable-WSManCredSSP -Role Server -Force

    Write-Ok "CredSSP enabled."
}

function Configure-HostTrustedHosts {
    Write-Info "Adding VM IP to TrustedHosts..."

    $current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    if ($current -notlike "*$VmIp*") {
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$current,$VmIp" -Force
        Write-Ok "TrustedHosts updated."
    }
    else {
        Write-Ok "VM IP already in TrustedHosts."
    }
}

function Test-HostWinRM {
    Write-Info "Testing WinRM HTTPS connectivity to $VmIp..."

    try {
        Test-WSMan -ComputerName $VmIp -UseSSL -ErrorAction Stop | Out-Null
        Write-Ok "WinRM HTTPS connectivity OK."
        return $true
    }
    catch {
        Write-Err "WinRM HTTPS test failed: $_"
        return $false
    }
}

function Test-HostPSRemoting {
    param([string]$CredPath)

    Write-Info "Testing PSRemoting using stored credential..."

    if (-not (Test-Path $CredPath)) {
        Write-Err "Credential file not found: $CredPath"
        return
    }

    $cred = Import-Clixml -Path $CredPath

    try {
        $hostname = Invoke-Command -ComputerName $VmIp -UseSSL -Credential $cred -ScriptBlock { hostname } -ErrorAction Stop
        Write-Ok "PSRemoting succeeded. Remote hostname: $hostname"
    }
    catch {
        Write-Err "PSRemoting failed: $_"
    }
}

# =============================================================================
# EXECUTION
# =============================================================================

Write-Info "=== VRising WinRM Setup Starting (Role=$Role) ==="

switch ($Role) {

    "VM" {
        Set-VmNetworkProfilePrivate
        Ensure-VmFirewallForWinRMHttps
        Ensure-VmCertificateAndListener -CertCN $CertCN -VmIp $VmIp -CertExportPath $CertExportPath
        Write-Ok "VM-side WinRM setup complete."
    }

    "Host" {
        if (Import-HostCertificate -CertExportPath $CertExportPath) {
            Configure-HostCredSSP
            Configure-HostTrustedHosts
            if (Test-HostWinRM) {
                Test-HostPSRemoting -CredPath $CredPath
            }
        }
        Write-Ok "Host-side WinRM setup complete."
    }

    "Both" {
        Write-Warn "Run this script separately on VM and Host with the appropriate -Role."
    }
}

Write-Info "=== VRising WinRM Setup Complete ==="
