# VRising-Host-Backup.ps1 — Full VM Backup Script Reference

This script performs a full Hyper-V virtual machine backup for a VRising server VM, using in-game notifications, graceful shutdown via RCON, fallback process termination via WinRM, and Hyper-V VM export. It is designed as a host-side backup orchestration script for a single VM.

---

## 1. Purpose

`VRising-Host-Backup.ps1` performs the following for a VRising VM:

- Notifies players in-game of an impending backup using RCON broadcast messages.
- Verifies reachability of the VM via WinRM and RCON before proceeding.
- Initiates a graceful in-game shutdown (`save` and `shutdown` via RCON).
- Uses PowerShell remoting to ensure the `VRisingServer` process is stopped.
- Shuts down the Hyper-V VM.
- Exports the VM to a backup directory.
- Restarts the VM and confirms it is back online.
- Sends Discord notifications throughout the lifecycle for operator visibility.

It is intended to be run on the Hyper-V host that manages the VRising VM.

---

## 2. Configuration and parameters

The script defines configuration values at the top:

- **VM name:**
  - Variable: `<VMName>`
  - Example in script: `"HO-VR-HV01"`

- **Backup directory:**
  - Variable: `<BackupDir>`
  - Example in script: `"D:\VMBackups\VRising"`

- **Log directories:**
  - Variables: `<LogDirectory1>`, `<LogDirectory2>`
  - Examples:
    - `"C:\Hyper V\Logs\VRising"`
    - `"D:\VMBackups\Logs\VRising"`

- **Timestamped log files:**
  - `BackupLog_<yyyy-MM-dd_HH-mm-ss>.log` created in both log directories.

- **Discord webhook URL:**
  - Variable: `<DiscordWebhookUrl>`
  - Placeholder: `"https://discord.com/api/webhooks/<id>/<token>"`

- **PowerShell remoting credential file:**
  - Variable: `<CredentialFilePath>`
  - Example in script: `"C:\Hyper V\KeyVault\HO-VR-HV01\PSRemoting.xml"`

- **VM IP address:**
  - Variable: `<VM_IP>`
  - Example in script: `"192.168.0.199"`

- **VRising RCON configuration:**
  - `<RconHost>`: same as `<VM_IP>`
  - `<RconPort>`: `25575`
  - `<RconPassword>`: placeholder string, e.g. `"YourRconPasswordHere"`

All of these are hard-coded in the script but can be adapted to your environment.

---

## 3. Logging and notifications

### 3.1 Log directory creation

Before running the backup workflow, the script ensures the two log directories exist:

- If a directory does not exist, it is created with `New-Item -ItemType Directory -Force`.

This guarantees that log output always has a valid target path.

### 3.2 Write-Log helper

The `Write-Log` function:

- Takes a single string parameter: the log message.
- Prefixes the message with a timestamp: `[yyyy-MM-dd HH:mm:ss]`.
- Writes the line to:
  - The primary log file in `<LogDirectory1>`.
  - The secondary log file in `<LogDirectory2>`.
- Echoes the message to the console via `Write-Host`.

This centralizes logging, ensuring consistent output to both disk and console.

### 3.3 Discord notifications

The `Send-DiscordNotification` function:

- Accepts a message string.
- Wraps it into a JSON payload: `{ content = "<Message>" }`.
- Sends it to `<DiscordWebhookUrl>` via `Invoke-RestMethod -Method Post`.
- Logs success or failure via `Write-Log`.

This provides out-of-band visibility to operators in Discord during the backup lifecycle.

---

## 4. RCON module (raw TCP + JSON)

The script includes a raw TCP-based RCON implementation designed for VRising’s JSON RCON protocol.

### 4.1 Diagnostic flag

- Global flag: `$Global:RconEnableDiagnostics = $true`
- Controlled via `Write-RconDiag`, which logs diagnostic messages only when this flag is true.

### 4.2 Invoke-RconRaw

`Invoke-RconRaw` is the core function that:

- Accepts:
  - `Command` (string)
  - `Identifier` (int, default 1)
  - `ConnectTimeoutMs` (default 3000)
  - `ReadTimeoutMs` (default 1000)
- Creates a `System.Net.Sockets.TcpClient` and connects to `<RconHost>:<RconPort>` with a timeout.
- On success:
  - Retrieves the network stream.
  - Sets read/write timeouts.
  - Builds an **auth payload**:
    - JSON: `{ Identifier = 1; Message = "auth <RconPassword>" }`
  - Sends the auth payload as UTF-8 JSON with a newline terminator.
  - Sleeps briefly (`150 ms`).
  - Builds a **command payload**:
    - JSON: `{ Identifier = <Identifier>; Message = <Command> }`
  - Sends the command payload similarly.
  - Optionally reads any immediate response (best-effort, if `DataAvailable`).
- Logs:
  - Connection attempts and status.
  - Errors and inner exceptions on failure.
- Cleans up the stream and client in a `finally` block.

It returns `$true` on successful command delivery, `$false` on any failure.

### 4.3 Send-VRisingRconCommand

This function provides retry logic:

- Parameters:
  - `Command` (string)
  - `Identifier` (int, default 1)
  - `MaxAttempts` (int, default 3)
- For each attempt:
  - Logs attempt number.
  - Calls `Invoke-RconRaw`.
  - On success:
    - Logs success and returns `$true`.
  - On failure:
    - Logs failure and sleeps briefly (300 ms) before retrying.
- If all attempts fail:
  - Logs a final failure message and returns `$false`.

### 4.4 Send-VRisingNotification

This function is specialized for broadcast messages:

- Accepts a message string.
- Constructs the command: `broadcast <Message>`.
- Sends via `Send-VRisingRconCommand` with identifier `2`.
- Logs success or failure to deliver the in-game notification.

---

## 5. Pre-flight checks (WinRM and RCON)

Before any disruptive action, the script performs connectivity pre-flight checks.

### 5.1 Wait-ForWinRM

- Parameters:
  - `Ip` (string)
  - `TimeoutSeconds` (default 60)
- Loops until:
  - `Test-WSMan -ComputerName <Ip> -UseSSL` succeeds, or
  - The timeout period elapses.
- Checks every 2 seconds.
- Returns `$true` on success, `$false` on timeout.

This ensures the host can communicate with the VM over WinRM before proceeding.

### 5.2 Wait-ForRCON

- Parameter:
  - `TimeoutSeconds` (default 30)
- Loops until:
  - `Send-VRisingRconCommand -Command "help" -Identifier 99 -MaxAttempts 1` succeeds, or
  - The timeout period elapses.
- Checks every 2 seconds.
- Returns `$true` on success, `$false` on timeout.

This verifies that the VRising server’s RCON endpoint is reachable and responsive.

---

## 6. Backup workflow

The main body of the script orchestrates the full backup sequence.

### 6.1 Sequence start

- Logs:
  - `=== VampireGuard Backup Sequence Initiated for VM <VMName> ===`

This is the top-level marker for the run.

### 6.2 Pre-flight: WinRM check

- Logs that it is performing a WinRM check against `<VM_IP>`.
- Calls `Wait-ForWinRM` with 60-second timeout.
- On failure:
  - Logs an error: VM unreachable via WinRM.
  - Sends a Discord notification: backup aborted.
  - Logs an aborted-sequence message.
  - Exits the script.
- On success:
  - Logs that WinRM check passed.

### 6.3 Pre-flight: RCON check

- Logs that it is performing an RCON check against `<RconHost>:<RconPort>`.
- Calls `Wait-ForRCON` with 30-second timeout.
- On failure:
  - Logs an error: RCON unreachable.
  - Sends a Discord notification: backup aborted due to RCON failure.
  - Logs an aborted-sequence message.
  - Exits the script.
- On success:
  - Logs that RCON check passed.

### 6.4 In-game notifications (5-minute and 2-minute warnings)

The script sends staged warnings to players:

1. **5-minute warning** (testing values may be scaled down):
   - In-game: “Backup begins in 5 minutes. Find shelter.”
   - Discord: warning about backup beginning in 5 minutes.
   - Sleep: currently 18 seconds (scaled), intended to be 300 seconds in production.

2. **2-minute warning**:
   - In-game: “Backup begins in 2 minutes.”
   - Discord: hourglass notification for 2 minutes.
   - Sleep: currently 12 seconds (scaled), intended to be 120 seconds in production.

### 6.5 Final warning

- In-game notification: “Server shutting down for backup now.”
- Discord notification: VRising server shutting down for backup.

This is the last call before actual shutdown begins.

### 6.6 Graceful shutdown via RCON

- Logs that it is issuing graceful shutdown via RCON (`save` + `shutdown`).
- Attempts:
  - `Send-VRisingRconCommand -Command "save" -Identifier 3`
    - On failure: logs a warning.
  - `Send-VRisingRconCommand -Command "shutdown" -Identifier 4`
    - On failure: logs a warning.
- Sleeps for 10 seconds to allow shutdown to proceed.

The goal is to let the server flush world state and shut down cleanly before any host-level actions.

### 6.7 Fallback: Kill VRisingServer.exe via WinRM

To ensure the server process is not left running:

- Logs that it is ensuring the VRising server process is stopped inside the VM.
- Uses `Invoke-Command` to run on `<VM_IP>` with `<Credential>` and `-UseSSL`:
  - Attempts to get the process `VRisingServer`.
  - If found, calls `Stop-Process -Id <Id> -Force`.
- On success:
  - Logs that the server process was confirmed stopped or not running.
- On failure:
  - Logs a warning describing the WinRM error.

This provides a safety net if the RCON-based shutdown does not fully succeed.

### 6.8 Shutdown Hyper-V VM

- Logs that it is shutting down VM `<VMName>`.
- Calls:
  - `Stop-VM -Name <VMName> -Force -Confirm:$false`
- Sleeps 10 seconds.

Once this completes, the VM is off and safe for export.

### 6.9 Export VM

- Logs: “Exporting VM...”
- Constructs a backup path:
  - `<BackupFilePath> = <BackupDir>\<VMName>_Backup_<Timestamp>`
- Ensures `<BackupDir>` exists; creates it if necessary.
- Calls:
  - `Export-VM -Name <VMName> -Path <BackupFilePath>`
- Logs backup completion with the final path.
- Sends a Discord notification indicating successful backup.

This step captures the VM state as a full Hyper-V export.

### 6.10 Restart VM

- Attempts to restart the VM:
  - `Start-VM -Name <VMName>`
  - Sleeps 15 seconds.
- On success:
  - Logs that the VM restarted successfully.
  - Sends a Discord notification that the VM is back online.
- On failure:
  - Logs an error with exception details.
  - Sends a Discord notification indicating the restart failure and error.

### 6.11 Sequence completion

- Logs:
  - `=== VampireGuard Backup Sequence Complete for VM <VMName> ===`

This marks the end of the backup run.

---

## 7. Usage pattern and intent

This script is intended to be:

- Run on the Hyper-V host that owns the VRising VM.
- Scheduled via Task Scheduler for recurring backups (after validation).
- Used as part of a broader “VampireGuard” operational workflow, but currently focused solely on backup.

It is **VM-specific** (single target VM) and assumes a stable RCON and WinRM configuration.

---

## 8. Failure modes and behavior

Key failure behaviors:

- **WinRM unreachable:**
  - Backup aborted before any disruptive action.
  - Discord notification sent.
- **RCON unreachable:**
  - Backup aborted before any in-game messaging or shutdown attempts.
  - Discord notification sent.
- **RCON save/shutdown failure:**
  - Logged as warnings.
  - Fallback WinRM process kill used to try to ensure clean state.
- **WinRM fallback failure:**
  - Logged as warning.
  - VM is still shut down at the Hyper-V level.
- **VM export failure:**
  - Logged error (inherent in `Export-VM`).
  - Discord notification indicates backup completion or failure depending on where you extend logic.
- **VM restart failure:**
  - Logged error.
  - Discord notification reports failure and includes the error.

Logging is designed so that post-mortem analysis can reconstruct what happened at each step.

---

## 9. Assumptions and limitations

- Assumes:
  - `<VMName>` uniquely identifies the target VM on the host.
  - `<VM_IP>` is stable and reachable over WinRM (HTTPS).
  - RCON is enabled, reachable, and configured with the given password.
  - Discord webhook URL is valid and reachable.
- Limitations:
  - Single-VM focus (no enumeration of multiple VMs).
  - Hard-coded timings for notifications and delays (currently scaled down for testing).
  - No built-in log rotation or archival.
  - No native retry for `Export-VM`.
  - No metrics/health check after restart beyond simple start call and logging.

---

## 10. Potential future enhancements

Potential areas to extend this script:

- **Parameterization:**
  - Convert configuration values into parameters with defaults.
  - Support multiple environments via parameter sets.

- **Robust health checks:**
  - Add post-restart checks (RCON ping, game query) before declaring success.

- **Config-driven design:**
  - Externalize VM name, IP, backup directory, log directory, and webhook URL to a config file.

- **Improved timing controls:**
  - Make the 5-minute and 2-minute warnings configurable durations.
  - Use a “test mode” flag to scale down waits automatically.

- **Backup rotation and pruning:**
  - Implement retention policies to keep only N most recent exports.

- **Centralized logging:**
  - Send logs to a central log aggregator or dashboard for multiple hosts/VMs.

This script already provides a strong, production-aware backup flow for a single VRising VM. With parameterization and externalized configuration, it can evolve into a generalized VampireGuard backup module.
