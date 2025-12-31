<#
===============================================================================
NAME:        VRising-Host-Backup.ps1
AUTHOR:      Kenneth Trowbridge
DATE:        2025-12-28
VERSION:     2.0

SYNOPSIS:
    Full Hyper-V VM backup workflow for the VRising server VM (HO-VR-HV01).
    Includes:
      - Pre-flight WinRM and RCON validation
      - In-game broadcast notifications
      - Graceful save + shutdown via RCON
      - Forced process termination fallback
      - VM shutdown and export
      - VM restart and Discord notifications
      - Dual-location logging

DESCRIPTION:
    This script is the backbone of the VampireGuard automation suite. It ensures
    consistent, safe, and observable backups of the VRising server VM by using:
      - Raw TCP RCON for in-game control
      - WinRM HTTPS for remote process management
      - Hyper-V PowerShell for VM lifecycle operations
      - Discord webhooks for operational visibility

    The workflow is fully deterministic and designed for scheduled execution.

PREREQUISITES:
    - WinRM HTTPS configured between host and VM
    - RCON enabled in VRising server config
    - VM static IP assigned
    - Credential XML stored in KeyVault directory
    - Discord webhook configured

USAGE:
    Run manually or via Task Scheduler:
        powershell.exe -File "C:\Hyper V\Scripts\VRising-Host-Backup.ps1"

LOGGING:
    Logs are written to:
      - C:\Hyper V\Logs\VRising
      - D:\VMBackups\Logs\VRising

===============================================================================
#>

# =============================================================================
# CONFIGURATION
# =============================================================================

$VMName        = "HO-VR-HV01"
$BackupDir     = "D:\VMBackups\VRising"
$VM            = Get-VM -Name $VMName

$LogDirectory1 = "C:\Hyper V\Logs\VRising"
$LogDirectory2 = "D:\VMBackups\Logs\VRising"
$Timestamp     = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile1      = Join-Path $LogDirectory1 "BackupLog_$Timestamp.log"
$LogFile2      = Join-Path $LogDirectory2 "BackupLog_$Timestamp.log"

# Discord webhook
$DiscordWebhookUrl = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# PowerShell remoting credentials
$CredentialFilePath = "C:\Hyper V\KeyVault\HO-VR-HV01\PSRemoting.xml"
$Credential         = Import-Clixml -Path $CredentialFilePath

# VRising VM IP
$VM_IP = "192.168.0.199"

# VRising RCON Configuration
$RconHost     = $VM_IP
$RconPort     = 25575
$RconPassword = "YOUR_RCON_PASSWORD_HERE"

# =============================================================================
# LOGGING HELPERS
# =============================================================================

foreach ($dir in @($LogDirectory1, $LogDirectory2)) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

function Write-Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"

    Add-Content -Path $LogFile1 -Value $entry
    Add-Content -Path $LogFile2 -Value $entry
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
# RCON MODULE (RAW TCP)
# =============================================================================

$Global:RconEnableDiagnostics = $true

function Write-RconDiag {
    param([string]$Message)
    if ($Global:RconEnableDiagnostics) {
        Write-Log "RCON DIAG: $Message"
    }
}

function Invoke-RconRaw {
    param(
        [string]$Command,
        [int]$Identifier       = 1,
        [int]$ConnectTimeoutMs = 3000,
        [int]$ReadTimeoutMs    = 1000
    )

    $client = $null
    $stream = $null

    try {
        Write-Log "RCON: Connecting to $RconHost`:$RconPort ..."
        $client = New-Object System.Net.Sockets.TcpClient

        $connectTask = $client.ConnectAsync($RconHost, $RconPort)
        if (-not $connectTask.Wait($ConnectTimeoutMs)) {
            Write-Log "RCON ERROR: Connect timeout after ${ConnectTimeoutMs}ms."
            return $false
        }

        if (-not $client.Connected) {
            Write-Log "RCON ERROR: TcpClient not connected after ConnectAsync()."
            return $false
        }

        Write-RconDiag "TCP connected to $RconHost`:$RconPort"

        $stream = $client.GetStream()
        $stream.ReadTimeout  = $ReadTimeoutMs
        $stream.WriteTimeout = $ReadTimeoutMs

        # AUTH payload
        $authPayload = @{
            Identifier = 1
            Message    = "auth $RconPassword"
        } | ConvertTo-Json -Compress

        $authBytes = [System.Text.Encoding]::UTF8.GetBytes($authPayload + "`n")
        Write-Log     "RCON: Sending auth payload..."
        Write-RconDiag "Auth JSON: $authPayload"
        $stream.Write($authBytes, 0, $authBytes.Length)
        $stream.Flush()

        Start-Sleep -Milliseconds 150

        # COMMAND payload
        $cmdPayload = @{
            Identifier = $Identifier
            Message    = $Command
        } | ConvertTo-Json -Compress

        $cmdBytes = [System.Text.Encoding]::UTF8.GetBytes($cmdPayload + "`n")
        Write-Log     "RCON: Sending command: $Command"
        Write-RconDiag "Command JSON: $cmdPayload"
        $stream.Write($cmdBytes, 0, $cmdBytes.Length)
        $stream.Flush()

        # Optional response
        $buffer = New-Object byte[] 4096
        if ($stream.DataAvailable) {
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
            if ($bytesRead -gt 0) {
                $resp = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)
                Write-RconDiag "Received response: $resp"
            }
        }

        Write-Log "RCON: Command sent successfully."
        return $true
    }
    catch {
        $err = $_.Exception
        Write-Log ("RCON ERROR: {0}" -f $err.Message)
        if ($err.InnerException) {
            Write-Log ("RCON ERROR (Inner): {0}" -f $err.InnerException.Message)
        }
        return $false
    }
    finally {
        if ($stream) { $stream.Dispose() }
        if ($client) { $client.Close(); $client.Dispose() }
    }
}

function Send-VRisingRconCommand {
    param(
        [string]$Command,
        [int]$Identifier  = 1,
        [int]$MaxAttempts = 3
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        Write-Log "RCON: Attempt $attempt of $MaxAttempts for command: $Command"
        $success = Invoke-RconRaw -Command $Command -Identifier $Identifier

        if ($success) {
            Write-Log "RCON: Command succeeded on attempt $attempt."
            return $true
        }

        Write-Log "RCON: Command failed on attempt $attempt. Retrying..."
        Start-Sleep -Milliseconds 300
    }

    Write-Log "RCON: Command failed after $MaxAttempts attempts: $Command"
    return $false
}

function Send-VRisingNotification {
    param([string]$Message)

    $cmd = "broadcast $Message"
    if (Send-VRisingRconCommand -Command $cmd -Identifier 2) {
        Write-Log "In-game notification sent: $Message"
    }
    else {
        Write-Log "FAILED to send in-game notification: $Message"
    }
}

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================

function Wait-ForWinRM {
    param(
        [string]$Ip,
        [int]$TimeoutSeconds = 60
    )

    $start = Get-Date
    while ((Get-Date) -lt $start.AddSeconds($TimeoutSeconds)) {
        if (Test-WSMan -ComputerName $Ip -UseSSL -ErrorAction SilentlyContinue) {
            return $true
        }
        Start-Sleep -Seconds 2
    }
    return $false
}

function Wait-ForRCON {
    param([int]$TimeoutSeconds = 30)

    $start = Get-Date
    while ((Get-Date) -lt $start.AddSeconds($TimeoutSeconds)) {
        if (Send-VRisingRconCommand -Command "help" -Identifier 99 -MaxAttempts 1) {
            return $true
        }
        Start-Sleep -Seconds 2
    }
    return $false
}

# =============================================================================
# BACKUP WORKFLOW
# =============================================================================

Write-Log "=== VampireGuard Backup Sequence Initiated for VM $VMName ==="

# --- WinRM Pre-flight ---
Write-Log "Pre-flight: Checking WinRM on $VM_IP ..."
if (-not (Wait-ForWinRM -Ip $VM_IP -TimeoutSeconds 60)) {
    Write-Log "ERROR: WinRM unreachable. Aborting backup."
    Send-DiscordNotification ":x: Backup aborted — VM unreachable via WinRM."
    exit
}
Write-Log "Pre-flight: WinRM OK."

# --- RCON Pre-flight ---
Write-Log "Pre-flight: Checking RCON on $RconHost`:$RconPort ..."
if (-not (Wait-ForRCON -TimeoutSeconds 30)) {
    Write-Log "ERROR: RCON unreachable. Aborting backup."
    Send-DiscordNotification ":x: Backup aborted — VRising RCON unreachable."
    exit
}
Write-Log "Pre-flight: RCON OK."

# --- Notifications ---
Send-VRisingNotification "Backup begins in 5 minutes. Find shelter."
Send-DiscordNotification ":warning: VRising backup begins in **5 minutes**."
Start-Sleep -Seconds 18   # testing scale

Send-VRisingNotification "Backup begins in 2 minutes."
Send-DiscordNotification ":hourglass_flowing_sand: VRising backup begins in **2 minutes**."
Start-Sleep -Seconds 12   # testing scale

Send-VRisingNotification "Server shutting down for backup now."
Send-DiscordNotification ":stop_sign: VRising server shutting down for backup."

# --- Graceful Shutdown ---
Write-Log "Issuing graceful shutdown via RCON..."
Send-VRisingRconCommand -Command "save"     -Identifier 3 | Out-Null
Send-VRisingRconCommand -Command "shutdown" -Identifier 4 | Out-Null
Start-Sleep -Seconds 10

# --- Fallback Kill ---
Write-Log "Ensuring VRisingServer.exe is stopped inside VM..."
try {
    Invoke-Command -ComputerName $VM_IP -Credential $Credential -UseSSL -ScriptBlock {
        $p = Get-Process "VRisingServer" -ErrorAction SilentlyContinue
        if ($p) { Stop-Process -Id $p.Id -Force }
    }
    Write-Log "VRising server process confirmed stopped."
}
catch {
    Write-Log "WARNING: Failed to confirm/stop VRisingServer via WinRM: $_"
}

# --- Shutdown VM ---
Write-Log "Shutting down VM $VMName..."
Stop-VM -Name $VMName -Force -Confirm:$false
Start-Sleep -Seconds 10

# --- Export VM ---
Write-Log "Exporting VM..."
$BackupFilePath = Join-Path $BackupDir "$VMName`_Backup_$Timestamp"

if (-not (Test-Path $BackupDir)) {
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
}

Export-VM -Name $VMName -Path $BackupFilePath
Write-Log "Backup complete: $BackupFilePath"
Send-DiscordNotification ":floppy_disk: Full VM backup completed for **$VMName**."

# --- Restart VM ---
try {
    Start-VM -Name $VMName
    Start-Sleep -Seconds 15
    Write-Log "VM $VMName restarted successfully."
    Send-DiscordNotification ":white_check_mark: VRising VM **$VMName** is back online!"
}
catch {
    Write-Log "ERROR restarting VM: $_"
    Send-DiscordNotification ":x: VRising VM **$VMName** failed to restart. Error: $_"
}

Write-Log "=== VampireGuard Backup Sequence Complete for VM $VMName ==="
