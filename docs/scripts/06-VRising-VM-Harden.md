# VRising-VM-Harden.ps1 — VM Hardening Script Reference

This script hardens a Windows-based VRising virtual machine into a minimal‑surface, single‑purpose game server. It applies firewall lockdowns, WinRM restrictions, service reductions, account hardening, Defender configuration, and basic integrity checks. It is intended to be run **inside the VM** after OS installation and VRising server deployment.

---

## 1. Purpose

`VRising-VM-Harden.ps1` performs the following:

- Locks down Windows Firewall to only allow:
  - VRising game port (UDP 9876)
  - VRising query port (UDP 9877)
  - RCON from the Hyper‑V host only
  - WinRM HTTPS from the Hyper‑V host only
- Removes any legacy or conflicting firewall rules
- Ensures WinRM is HTTPS‑only and running
- Disables unnecessary Windows services
- Hardens local accounts and validates the Administrators group
- Applies basic Defender and OS hardening (MAPS, real‑time protection, SMBv1 removal)
- Logs all actions to a persistent hardening log
- Performs basic integrity checks (listening ports, UDP endpoints)

This script is designed to be **idempotent** — safe to re‑run without breaking configuration.

---

## 2. Execution prerequisites

- **Environment:**
  - Must be run **inside the VRising VM**
  - Windows 10/11 or Windows Server with PowerShell 5.1+

- **Permissions:**
  - Script must be run as **Administrator**

- **Network assumptions:**
  - VM has a static IP
  - Hyper‑V host IP is known and configured in `$HostIP`
  - WinRM HTTPS is already configured inside the VM

- **Paths and resources:**
  - Hardening log directory: `C:\VRising\Logs`
  - VRising data directory (optional CFA note): `C:\VRising\Data`

---

## 3. High‑level workflow

1. Initialize logging and configuration variables  
2. Set firewall inbound defaults to **Block**  
3. Remove old VRising/WinRM/RCON firewall rules  
4. Create new explicit allow rules for:
   - VRising game port (UDP 9876)
   - VRising query port (UDP 9877)
   - RCON from host only
   - WinRM HTTPS from host only  
5. Remove WinRM HTTP listener (if present)  
6. Ensure WinRM service is running and set to Automatic  
7. Disable unnecessary Windows services  
8. Harden local accounts and validate Administrators group  
9. Apply Defender and OS hardening  
10. Run integrity checks (listening ports, UDP endpoints)  
11. Log completion

---

## 4. Detailed execution flow

### 4.1 Firewall lockdown

- Sets inbound policy to **Block** for Domain, Private, and Public profiles  
- Removes old rules:
  - `VRising Game Port`
  - `VRising Query Port`
  - `VRising RCON from Host`
  - `WinRM HTTPS from Host`
- Creates new rules:
  - Allow UDP 9876 (game)
  - Allow UDP 9877 (query)
  - Allow TCP 25575 (RCON) **from host only**
  - Allow TCP 5986 (WinRM HTTPS) **from host only**

---

### 4.2 WinRM hardening

- Removes HTTP listener if present:
  ```powershell
  winrm delete winrm/config/Listener?Address=*+Transport=HTTP
```
- Ensures WinRM service:
  - Exists
  - Is set to Automatic
  - Is running

### 4.3 RCON hardening
- Firewall restricts RCON to the Hyper‑V host IP
- Script logs the restriction for operator visibility

### 4.4 Disabling unnecessary services
- Stops and disables services such as:
  - Print Spooler
  - Fax
  - RemoteRegistry
  - Windows Error Reporting
  - Telemetry (DiagTrack)
  - Xbox services
  - Bluetooth
  - SSDP Discovery
  - UPnP Device Host
Each action is logged.

### 4.5 Account hardening
- Disables built‑in Administrator (if enabled)
- Enumerates Administrators group
- Logs any accounts not in `$AllowedAdminUsers`
- (Optional removal commented out for safety)

### 4.6 Defender / OS hardening
- Enables Defender real‑time protection
- Enables MAPS cloud protection
- Logs Controlled Folder Access recommendations
- Disables SMBv1 (if installed)

### 4.7 Integrity / surface checks
Logs:
- All listening TCP ports
- All listening UDP ports
This provides a quick post‑hardening surface review.

---

## 5. Usage pattern and intent
This script is intended to be run:
- After OS installation
- After VRising server installation
- Before exposing the VM to the internet
- Anytime you want to re‑assert a hardened baseline
It is safe to re‑run and will not break existing configuration.

---

## 6. Limitations and assumptions
- `$HostIP` must be manually set before running
- `$AllowedAdminUsers` must reflect actual VM hostname and admin accounts
- Does not configure WinRM HTTPS — assumes it is already set up
- Does not remove unexpected admin accounts — only logs them
- Does not enforce Controlled Folder Access (CFA) — only recommends it
- Hardening is focused on a **single‑purpose VRising server**, not a general Windows hardening baseline

---

## 7. Potential future enhancements
- Add transcript logging
- Add optional removal of unauthorized admin accounts
- Add optional service removal instead of disable
- Add optional Defender attack surface reduction (ASR) rules
- Add optional Controlled Folder Access enforcement
- Add parameterization for ports, host IP, and allowed users
- Add a “dry run” mode for previewing changes

