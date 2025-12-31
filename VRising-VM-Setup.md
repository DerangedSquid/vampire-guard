# VRising-VM-Setup.ps1 — Automated VRising Server Bootstrap

This script performs a full automated bootstrap of a VRising dedicated server inside a Windows VM. It handles environment cleanup, SteamCMD installation, server deployment, configuration generation, JSON customization, validation, and optional Windows service installation via NSSM.

It is intended to be run **inside the VRising VM** after OS installation and before applying hardening or lifecycle automation.

---

## 1. Purpose

`VRising-VM-Setup.ps1` performs the following:

- Cleans any previous VRising installation, data, or SteamCMD artifacts  
- Recreates the directory structure under `C:\VRising`  
- Downloads and extracts SteamCMD  
- Installs the VRising Dedicated Server (AppID 1829350)  
- Detects the installed `VRisingServer.exe`  
- Performs a first-run initialization to generate required files  
- Copies template JSON configuration files  
- Applies automatic configuration (server name, ports, save name)  
- Validates the resulting configuration  
- Optionally installs the server as a Windows service using NSSM  

This script provides a **repeatable, idempotent bootstrap** for VRising server deployment.

---

## 2. Execution prerequisites

- **Environment:**
  - Must be run **inside the VRising VM**
  - Windows 10/11 or Windows Server
  - PowerShell 5.1+

- **Permissions:**
  - Script must be run as **Administrator**

- **Network:**
  - VM must have outbound internet access (SteamCMD download + app_update)

- **Paths and resources:**
  - Base directory: `C:\VRising`
  - NSSM (optional): `C:\nssm\nssm.exe`

- **Execution policy:**
  If needed:
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process

---

## 3. High‑level workflow
  1. Stop any running VRising server process
  2. Remove old directories (SteamCMD, Server, Data, LocalLow configs)
  3. Recreate directory structure
  4. Download and extract SteamCMD
  5. Install VRising Dedicated Server via SteamCMD
  6. Detect `VRisingServer.exe`
  7. Run the server once to generate required files
  8. Copy template JSON configs
  9. Apply automatic configuration (server name, ports, save name)
  10. Validate configuration files
  11. Install VRising as a Windows service (optional)
  12. Print final instructions

---

## 4. Detailed execution flow

### 4.1 Environment cleanup
- Stops any running `VRisingServer` process
- Removes:
  - C:\VRising\SteamCMD
  - C:\VRising\Serve
  - C:\VRising\Data
  - `%USERPROFILE%\AppData\LocalLow\Stunlock Studios\VRisingServer`
This ensures a clean, deterministic bootstrap.

---

### 4.2 Directory structure creation
Creates:
  - C:\VRising\SteamCMD
  - C:\VRising\Server
  - C:\VRising\Data\world1
All directories are created with `-Force` to ensure idempotency.

---

### 4.3 SteamCMD download
- Downloads `steamcmd.zip` from the official Steam CDN
- Extracts it into `C:\VRising\SteamCMD`
- Removes the ZIP file after extraction

---

### 4.4 VRising server installation
Runs:
powershell
`.\steamcmd.exe +force_install_dir "C:\VRising\Server\vrisingdedicatedserver" +login anonymous +app_update 1829350 validate +quit`

This installs the VRising Dedicated Server into:
`C:\VRising\Server\vrisingdedicatedserver`

---

### 4.5 VRisingServer.exe detection
Searches recursively under C:\VRising\Server for:
`VRisingServer.exe`
If not found, the script exits with an error.

---

### 4.6 First-run initialization
Runs the server once:
powershell
`Start-Process -FilePath "$serverPath\VRisingServer.exe" -WorkingDirectory $serverPath -Wait`
This generates required runtime files and ensures the server folder structure is complete.

---

### 4.7 Copy template configuration files
VRising no longer generates JSON configs automatically, so the script copies template files from:
`VRisingServer_Data\StreamingAssets\Settings`
Into:
`C:\VRising\Data\world1\Settings`
Files copied:
  - ServerHostSettings.json
  - ServerGameSettings.json

---

### 4.8 Automatic configuration
The script loads both JSON files, applies:
  - Server name
  - Game port
  - Query port
  - Save name
Then writes the updated JSON back to disk.

---

### 4.9 Validation
Ensures:
- `ServerHostSettings.json` exists
- `ServerGameSettings.json` exists
If either is missing, the script exits with an error.

---

### 4.10 Optional Windows service installation (NSSM)
If `C:\nssm\nssm.exe` exists:
- Installs a service named VRisingServer
- Sets startup type to Automatic
- Configures the service to run:
`VRisingServer.exe -persistentDataPath "C:\VRising\Data\world1"`
If NSSM is missing, the script prints instructions for manual installation.

---

## 5. Usage pattern and intent

This script is intended for:

- **[Fresh VRising server deployments](guide://action?prefill=Tell%20me%20more%20about%3A%20Fresh%20VRising%20server%20deployments)**  
- **[Automated rebuilds](guide://action?prefill=Tell%20me%20more%20about%3A%20Automated%20rebuilds)**  
- **[VM template initialization](guide://action?prefill=Tell%20me%20more%20about%3A%20VM%20template%20initialization)**  
- **[Pre‑hardening setup](guide://action?prefill=Tell%20me%20more%20about%3A%20Pre%E2%80%91hardening%20setup)**  
- **[Pre‑VampireGuard lifecycle automation](guide://action?prefill=Tell%20me%20more%20about%3A%20Pre%E2%80%91VampireGuard%20lifecycle%20automation)**  

It is safe to re-run and will always produce a clean, consistent server installation.

---

## 6. Limitations and assumptions

- **[Hard‑coded paths under C:\VRising](guide://action?prefill=Tell%20me%20more%20about%3A%20Hard%E2%80%91coded%20paths%20under%20C%3A%5CVRising)**  
- **[Only supports a single world name (world1)](guide://action?prefill=Tell%20me%20more%20about%3A%20Only%20supports%20a%20single%20world%20name%20(world1))**  
- **[Requires outbound internet access](guide://action?prefill=Tell%20me%20more%20about%3A%20Requires%20outbound%20internet%20access)**  
- **[NSSM must be manually installed for service mode](guide://action?prefill=Tell%20me%20more%20about%3A%20NSSM%20must%20be%20manually%20installed%20for%20service%20mode)**  
- **[Does not configure firewall rules](guide://action?prefill=Tell%20me%20more%20about%3A%20Does%20not%20configure%20firewall%20rules)** (handled by VM hardening script)  
- **[Does not configure WinRM](guide://action?prefill=Tell%20me%20more%20about%3A%20Does%20not%20configure%20WinRM)** (handled by VM WinRM config script)  

---

## 7. Potential future enhancements

- **[Parameterize world name, ports, and server name](guide://action?prefill=Tell%20me%20more%20about%3A%20Parameterize%20world%20name%2C%20ports%2C%20and%20server%20name)**  
- **[Add checksum validation for SteamCMD download](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20checksum%20validation%20for%20SteamCMD%20download)**  
- **[Add transcript logging](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20transcript%20logging)**  
- **[Add retry logic for SteamCMD failures](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20retry%20logic%20for%20SteamCMD%20failures)**  
- **[Add support for multiple worlds](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20support%20for%20multiple%20worlds)**  
- **[Add optional mod installation hooks](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20optional%20mod%20installation%20hooks)**  
