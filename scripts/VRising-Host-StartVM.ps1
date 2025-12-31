<#
===============================================================================
NAME:        VRising-Host-StartVM.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     1.1

SYNOPSIS:
    Starts the VRising Hyper-V VM automatically when the host user logs in
    and sends a Discord notification indicating the VM's status.

DESCRIPTION:
    This script is intended to be triggered by a user logon event on the
    Hyper-V host. It checks whether the VRising VM is already running and
    starts it if necessary. Regardless of state, it sends a Discord webhook
    notification for operational visibility.

PREREQUISITES:
    - Hyper-V role enabled
    - Discord webhook configured
    - VM name must match the Hyper-V VM intended for VRising

USAGE:
    Add this script to Task Scheduler:
        Trigger: At logon (for your user)
        Action:  powershell.exe -File "C:\Hyper V\Scripts\VRising-Host-StartVM.ps1"

NOTES:
    This script is intentionally lightweight and fast, designed for login-time
    execution without blocking the user session.
===============================================================================
#>

# =============================================================================
# CONFIGURATION
# =============================================================================

$VMName = "HO-VR-HV01"
$DiscordWebhookUrl = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# =============================================================================
# DISCORD NOTIFICATION
# =============================================================================

function Send-DiscordNotification {
    param ([string]$Message)

    try {
        $payload = @{ content = $Message } | ConvertTo-Json -Depth 2
        Invoke-RestMethod -Uri $DiscordWebhookUrl -Method Post -ContentType "application/json" -Body $payload
        Write-Host "Discord notification sent."
    }
    catch {
        Write-Host "Failed to send Discord notification: $_" -ForegroundColor Yellow
    }
}

# =============================================================================
# START VM WORKFLOW
# =============================================================================

try {
    $vm = Get-VM -Name $VMName -ErrorAction Stop

    if ($vm.State -ne 'Running') {
        Start-VM -Name $VMName -ErrorAction Stop
        Write-Host "VM '$VMName' started successfully." -ForegroundColor Green

        Send-DiscordNotification ":rocket: VRising VM **$VMName** is powering on. The vampire realm awakens."
    }
    else {
        Write-Host "VM '$VMName' is already running." -ForegroundColor Cyan

        Send-DiscordNotification ":white_check_mark: VRising VM **$VMName** was already online at host login."
    }
}
catch {
    Write-Host "ERROR: Failed to start VM '$VMName'. $_" -ForegroundColor Red

    Send-DiscordNotification ":x: VRising VM **$VMName** failed to start during host login. Error: $_"
}
