# VRising-VM-StartServer.ps1 — VRising Server Startup Script Reference

This script starts the VRising dedicated server inside the VM, validates environment readiness, logs all operational events, and sends Discord notifications for visibility. It is designed to be idempotent and safe to run repeatedly, whether manually or via scheduled automation.

---

## 1. Purpose

`VRising-VM-StartServer.ps1` performs the following:

- Validates the VRising installation directory  
- Validates the persistent data directory  
- Ensures the server is not already running  
- Starts `VRisingServer.exe` with the correct `-persistentDataPath` argument  
- Logs all actions to `C:\VRising\Logs`  
- Sends Discord notifications for:
  - Successful startup  
  - Already-running state  
  - Failure conditions  

This script is intended to run **inside the VRising VM**, typically as part of VampireGuard’s lifecycle automation.

---

## 2. Execution prerequisites

- **Environment:**
  - Must be run inside the VRising VM
  - Windows 10/11 or Windows Server
  - PowerShell 5.1+

- **VRising installation:**
  - Server installed at:  
    `C:\VRising\Server\vrisingdedicatedserver`
  - Data directory exists at:  
    `C:\VRising\Data\world1`

- **Logging:**
  - Log directory: `C:\VRising\Logs` (auto-created)

- **Discord:**
  - `$DiscordWebhookUrl` must be configured with a valid webhook

- **Execution policy:**
  If needed:
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process

---

## 3. High‑level workflow

1. **[Initialize logging](guide://action?prefill=Tell%20me%20more%20about%3A%20Initialize%20logging)** and create a timestamped log file  
2. **[Validate VRising installation paths](guide://action?prefill=Tell%20me%20more%20about%3A%20Validate%20VRising%20installation%20paths)** (server + data directory)  
3. **[Check if the server is already running](guide://action?prefill=Tell%20me%20more%20about%3A%20Check%20if%20the%20server%20is%20already%20running)**  
4. If running:  
   - **[Log state](guide://action?prefill=Tell%20me%20more%20about%3A%20Log%20state)**  
   - **[Send Discord notification](guide://action?prefill=Tell%20me%20more%20about%3A%20Send%20Discord%20notification)**  
   - **[Exit cleanly](guide://action?prefill=Tell%20me%20more%20about%3A%20Exit%20cleanly)**  
5. If not running:  
   - **[Start VRisingServer.exe](guide://action?prefill=Tell%20me%20more%20about%3A%20Start%20VRisingServer.exe)** with correct arguments  
   - **[Log success or failure](guide://action?prefill=Tell%20me%20more%20about%3A%20Log%20success%20or%20failure)**  
   - **[Send Discord notification](guide://action?prefill=Tell%20me%20more%20about%3A%20Send%20Discord%20notification)**  
6. **[Complete startup sequence](guide://action?prefill=Tell%20me%20more%20about%3A%20Complete%20startup%20sequence)**  

---

## 4. Detailed execution flow

### 4.1 Logging initialization

- Ensures `C:\VRising\Logs` exists  
- Creates a timestamped log file:
`StartLog_YYYY-MM-DD_HH-mm-ss.log`
- Defines:
- **[Write-Log](guide://action?prefill=Tell%20me%20more%20about%3A%20Write-Log)** for timestamped console + file logging  
- **[Send-DiscordNotification](guide://action?prefill=Tell%20me%20more%20about%3A%20Send-DiscordNotification)** for webhook messaging  

---

### 4.2 Environment validation

The script checks:

- **[VRisingServer.exe exists](guide://action?prefill=Tell%20me%20more%20about%3A%20VRisingServer.exe%20exists)** at:
`C:\VRising\Server\vrisingdedicatedserver`
- **[Persistent data path exists](guide://action?prefill=Tell%20me%20more%20about%3A%20Persistent%20data%20path%20exists)** at:
`C:\VRising\Data\world1`

If either is missing:

- **[Logs the error](guide://action?prefill=Tell%20me%20more%20about%3A%20Logs%20the%20error)**  
- **[Sends a Discord failure notification](guide://action?prefill=Tell%20me%20more%20about%3A%20Sends%20a%20Discord%20failure%20notification)**  
- **[Exits with code 1](guide://action?prefill=Tell%20me%20more%20about%3A%20Exits%20with%20code%201)**  

---

### 4.3 Already‑running detection

Runs:

```powershell
Get-Process "VRisingServer"
```
If found:
- Logs that the server is already running
- Sends a Discord success notification
- Exits cleanly
This ensures **idempotent behavior**.

---

### 4.4 Server startup
If the server is not running, the script executes:
```powershell
Start-Process -FilePath $Executable `
    -ArgumentList "-persistentDataPath `"$DataPath`"" `
    -WorkingDirectory $ServerPath `
    -NoNewWindow
```
On success:
- Logs successful launch
- Sends a Discord “server awakening” message
On failure:
- Logs the exception
- Sends a Discord failure message
- Exits with code 1

---

## 5. Usage pattern and intent
This script is intended for:
- Manual server startup inside the VM
- Scheduled Task execution at VM boot
- VampireGuard lifecycle automation
- **Idempotent re‑runs** (safe even if the server is already running)
It ensures consistent startup behavior and operational visibility.

---

## 6. Limitations and assumptions

- **Discord webhook must be configured** before notifications will work  
- **Paths are hard‑coded** under `C:\VRising`  
- **No retry logic** is implemented for failed launches  
- **Does not validate port bindings** after startup  
- **Does not manage Windows service mode** (handled by the setup/bootstrap script)  
- **Assumes VRising is installed via the standard directory layout** created by `VRising-VM-Setup.ps1`  

---

## 7. Potential future enhancements

- **Add retry logic** for transient startup failures  
- **Add port binding validation** after launch  
- **Add structured JSON logging** for better observability  
- **Add optional Windows service integration**  
- **Add a health‑check loop** to confirm server readiness  
- **Add richer Discord embeds** (status color, uptime, server name, player count)  
