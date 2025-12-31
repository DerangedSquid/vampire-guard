# VRising-VM-WinRMQuickSetup.ps1 — Quick WinRM HTTPS Setup Script Reference

---

## 1. Purpose

`VRising-VM-WinRMQuickSetup.ps1` performs the following:

- Prompts the operator for the VM’s static IPv4 address  
- Validates IPv4 format  
- Ensures the WinRM service is installed and running  
- Creates or reuses a self‑signed certificate for WinRM HTTPS  
- Removes all existing WinRM listeners  
- Creates a new HTTPS listener bound to the certificate  
- Enables Windows Remote Management firewall rules  
- Displays the resulting listener configuration and host‑side test commands  

This script is intended for **quick setup**, **troubleshooting**, and **non‑production environments**.

---

## 2. Execution prerequisites

- **Environment:**
  - Must be run **inside the VRising VM**
  - Windows 10/11 or Windows Server
  - PowerShell 5.1+

- **Permissions:**
  - Must be run as **Administrator**

- **Network:**
  - VM must have a **static IPv4 address**

- **Execution policy:**
  - Run the following if needed:  
    `Set-ExecutionPolicy Bypass -Scope Process`

- **Production note:**
  For full automation and hardened configuration, use:  
  `VRising-WinRMSetup.ps1`

---

## 3. High‑level workflow

1. Prompt for VM IPv4 address  
2. Validate IPv4 format  
3. Ensure WinRM service is running  
4. Create or reuse a self‑signed certificate  
5. Remove all existing WinRM listeners  
6. Create a new HTTPS listener bound to the certificate  
7. Enable WinRM firewall rules  
8. Display listener configuration and host‑side test commands  

---

## 4. Detailed execution flow

### 4.1 Logging helpers

Defines:

- **Write-Status** — timestamped, color‑coded console output  
- **Validate-IPv4** — regex‑based IPv4 validation  

---

### 4.2 Prompt for IPv4 address

Prompts:

`Enter the static IPv4 address for this VM (e.g., 192.168.0.199):`

If invalid:

- Prints an error  
- Exits immediately  

---

### 4.3 Ensure WinRM service

- Checks for the WinRM service  
- Starts it if not running  
- Exits if the service is missing  

---

### 4.4 Certificate creation or reuse

Searches for an existing certificate in `Cert:\LocalMachine\My`:

- Subject: `CN=<IPv4>`  
- `HasPrivateKey = $true`  
- Not expired  

If none found:

- Creates a new self‑signed certificate  
- Logs the thumbprint  

---

### 4.5 Remove existing listeners

Runs:

`winrm delete winrm/config/Listener?Address=*`

Ensures a clean slate.

---

### 4.6 Create HTTPS listener

Creates a new listener:

`winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="<IP>";CertificateThumbprint="<Thumbprint>"}`

If it fails:

- Logs the error  
- Exits  

---

### 4.7 Enable WinRM firewall rules

- Enables all rules in the **Windows Remote Management** firewall group  
- If enabling fails, logs the exception  

---

## 5. Usage pattern and intent

This script is intended for:

- **Quick WinRM HTTPS setup** inside the VM  
- **Testing and validation** of WinRM connectivity  
- **Lightweight or temporary environments**  
- **Developers or operators** who need fast configuration without full automation  

It is **interactive** and **not intended for production automation**.

---

## 6. Limitations and assumptions

- **Not suitable for production** — use the full WinRM setup script instead  
- **No certificate cleanup** — old certificates remain in the store  
- **No TrustedHosts configuration** — must be done on the host  
- **No firewall hardening** beyond enabling WinRM rules  
- **Assumes IPv4 only**  
- **Assumes WinRM HTTPS is desired on all interfaces** (`Address=*`)  

---

## 7. Potential future enhancements

- Add optional TrustedHosts update  
- Add optional certificate cleanup  
- Add support for hostname‑based certificates  
- Add validation of port 5986 binding  
- Add optional non‑interactive mode  
- Add logging to file instead of console only  
