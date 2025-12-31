<#
===============================================================================
NAME:        VRising-VM-Harden.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     2.0

SYNOPSIS:
    Hardens the VRising VM into a single-purpose, low-surface-area game server.

DESCRIPTION:
    This script performs comprehensive hardening of the VRising VM, including:
      - Firewall lockdown (game/query ports, RCON, WinRM)
      - WinRM HTTPS enforcement (removes HTTP listener)
      - RCON exposure restriction
      - Disabling unnecessary Windows services
      - Local account hardening
      - Defender and OS security configuration
      - Basic integrity/surface checks
      - Logging of all actions

    The script is safe to re-run and is designed to be idempotent.

PREREQUISITES:
    - Run inside the VRising VM as Administrator
    - VM must have a static IP
    - Host IP must be known and configured below

USAGE:
    Run manually or via automation:
        powershell.exe -File "C:\VRising\Ops\VRising-VM-Harden.ps1"

LOGGING:
    Log file written to:
        C:\VRising\Logs\VM-Hardening.log
===============================================================================
#>

# =============================================================================
# CONFIGURATION
# =============================================================================

$HostIP        = "192.168.0.214"   # Hyper-V host IP
$GamePortUDP   = 9876
$QueryPortUDP  = 9877
$RconPortTCP   = 25575
$WinRMPortTCP  = 5986

$AllowedAdminUsers = @(
    "DESKTOP-DJD6820\TheAllFather"   # Adjust for actual VM hostname\user
)

$HardeningLogPath = "C:\VRising\Logs\VM-Hardening.log"
if (-not (Test-Path (Split-Path $HardeningLogPath))) {
    New-Item -ItemType Directory -Path (Split-Path $HardeningLogPath) -Force | Out-Null
}

function Write-HardenLog {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$ts] $Message"
    Add-Content -Path $HardeningLogPath -Value $entry
    Write-Host $entry
}

Write-HardenLog "===== VM Hardening Script Started ====="

# =============================================================================
# 1. FIREWALL LOCKDOWN
# =============================================================================

Write-HardenLog "Configuring Windows Firewall rules..."

foreach ($profile in @("Domain", "Private", "Public")) {
    $current = (Get-NetFirewallProfile -Name $profile).DefaultInboundAction
    if ($current -ne "Block") {
        Set-NetFirewallProfile -Name $profile -DefaultInboundAction Block
        Write-HardenLog "Set firewall profile '$profile' inbound action to Block."
    } else {
        Write-HardenLog "Firewall profile '$profile' inbound already Block."
    }
}

$ruleNamesToClean = @(
    "VRising Game Port",
    "VRising Query Port",
    "VRising RCON from Host",
    "WinRM HTTPS from Host"
)

foreach ($name in $ruleNamesToClean) {
    $existing = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if ($existing) {
        $existing | Remove-NetFirewallRule
        Write-HardenLog "Removed existing firewall rule: $name"
    }
}

New-NetFirewallRule -DisplayName "VRising Game Port" `
    -Direction Inbound -Protocol UDP -LocalPort $GamePortUDP `
    -Action Allow -Profile Any | Out-Null
Write-HardenLog "Created firewall rule: VRising Game Port (UDP $GamePortUDP)."

New-NetFirewallRule -DisplayName "VRising Query Port" `
    -Direction Inbound -Protocol UDP -LocalPort $QueryPortUDP `
    -Action Allow -Profile Any | Out-Null
Write-HardenLog "Created firewall rule: VRising Query Port (UDP $QueryPortUDP)."

New-NetFirewallRule -DisplayName "VRising RCON from Host" `
    -Direction Inbound -Protocol TCP -LocalPort $RconPortTCP `
    -RemoteAddress $HostIP -Action Allow -Profile Any | Out-Null
Write-HardenLog "Created firewall rule: VRising RCON from Host (TCP $RconPortTCP from $HostIP)."

New-NetFirewallRule -DisplayName "WinRM HTTPS from Host" `
    -Direction Inbound -Protocol TCP -LocalPort $WinRMPortTCP `
    -RemoteAddress $HostIP -Action Allow -Profile Any | Out-Null
Write-HardenLog "Created firewall rule: WinRM HTTPS from Host (TCP $WinRMPortTCP from $HostIP)."

# =============================================================================
# 2. WINRM HARDENING
# =============================================================================

Write-HardenLog "Validating WinRM configuration..."

$httpListener = winrm enumerate winrm/config/Listener 2>$null | Select-String "Transport = HTTP"
if ($httpListener) {
    Write-HardenLog "Found WinRM HTTP listener. Attempting to remove..."
    try {
        winrm delete winrm/config/Listener?Address=*+Transport=HTTP | Out-Null
        Write-HardenLog "Removed WinRM HTTP listener."
    } catch {
        Write-HardenLog "Failed to remove WinRM HTTP listener: $_"
    }
} else {
    Write-HardenLog "No WinRM HTTP listener found."
}

$winrmSvc = Get-Service -Name WinRM -ErrorAction SilentlyContinue
if ($winrmSvc) {
    if ($winrmSvc.StartType -ne "Automatic") {
        Set-Service -Name WinRM -StartupType Automatic
        Write-HardenLog "Set WinRM service startup type to Automatic."
    }
    if ($winrmSvc.Status -ne "Running") {
        Start-Service -Name WinRM
        Write-HardenLog "Started WinRM service."
    }
} else {
    Write-HardenLog "WinRM service not found (unexpected)."
}

# =============================================================================
# 3. RCON HARDENING
# =============================================================================

Write-HardenLog "RCON is restricted via firewall to host IP $HostIP on TCP $RconPortTCP."

# =============================================================================
# 4. DISABLE UNNECESSARY SERVICES
# =============================================================================

Write-HardenLog "Disabling unnecessary services..."

$servicesToDisable = @(
    "Spooler",
    "Fax",
    "RemoteRegistry",
    "WerSvc",
    "DiagTrack",
    "XblGameSave",
    "bthserv",
    "SSDPSRV",
    "upnphost"
)

foreach ($svcName in $servicesToDisable) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc) {
        try {
            if ($svc.Status -ne "Stopped") {
                Stop-Service -Name $svcName -Force -ErrorAction SilentlyContinue
                Write-HardenLog "Stopped service: $svcName"
            }
            if ($svc.StartType -ne "Disabled") {
                Set-Service -Name $svcName -StartupType Disabled
                Write-HardenLog "Disabled service: $svcName"
            }
        } catch {
            Write-HardenLog "Failed to modify service '$svcName': $_"
        }
    } else {
        Write-HardenLog "Service not found: $svcName"
    }
}

# =============================================================================
# 5. ACCOUNT HARDENING
# =============================================================================

Write-HardenLog "Hardening local accounts..."

try {
    $admin = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
    if ($admin -and -not $admin.Disabled) {
        Disable-LocalUser -Name "Administrator"
        Write-HardenLog "Disabled built-in Administrator account."
    } else {
        Write-HardenLog "Built-in Administrator already disabled."
    }
} catch {
    Write-HardenLog "Error processing built-in Administrator: $_"
}

try {
    $adminsGroup = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue
    foreach ($member in $adminsGroup) {
        if ($member.ObjectClass -eq "User") {
            $fullName = "$($env:COMPUTERNAME)\$($member.Name)"
            $domainUser = $member.Name

            $isAllowed = $AllowedAdminUsers -contains $domainUser -or
                         $AllowedAdminUsers -contains $fullName

            if (-not $isAllowed) {
                Write-HardenLog "Admin account not in allowlist: $domainUser (logged only)."
            }
        }
    }
} catch {
    Write-HardenLog "Error enumerating Administrators group: $_"
}

# =============================================================================
# 6. DEFENDER / OS HARDENING
# =============================================================================

Write-HardenLog "Applying basic Defender / OS hardening..."

try {
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    Write-HardenLog "Enabled Defender real-time protection."
} catch {
    Write-HardenLog "Failed to modify Defender real-time protection: $_"
}

try {
    Set-MpPreference -MAPSReporting Advanced -ErrorAction SilentlyContinue
    Write-HardenLog "Enabled Defender MAPS (cloud protection)."
} catch {
    Write-HardenLog "Failed to modify Defender MAPS settings: $_"
}

$VRisingDataPath = "C:\VRising\Data"
if (Test-Path $VRisingDataPath) {
    Write-HardenLog "VRising data directory exists at $VRisingDataPath. Consider enabling Controlled Folder Access."
} else {
    Write-HardenLog "VRising data directory not found at $VRisingDataPath."
}

try {
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Write-HardenLog "Ensured SMBv1 is disabled."
} catch {
    Write-HardenLog "Failed to modify SMBv1 feature: $_"
}

# =============================================================================
# 7. INTEGRITY / SURFACE CHECK
# =============================================================================

Write-HardenLog "Running basic integrity/surface checks..."

try {
    $tcpPorts = (Get-NetTCPConnection -State Listen).LocalPort | Sort-Object -Unique
    Write-HardenLog ("Current listening TCP ports: " + ($tcpPorts -join ", "))
} catch {
    Write-HardenLog "Failed to enumerate TCP ports: $_"
}

try {
    $udpPorts = (Get-NetUDPEndpoint).LocalPort | Sort-Object -Unique
    Write-HardenLog ("Current listening UDP ports: " + ($udpPorts -join ", "))
} catch {
    Write-HardenLog "Failed to enumerate UDP ports: $_"
}

Write-HardenLog "===== VM Hardening Script Completed ====="
