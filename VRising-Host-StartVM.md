# VRising-Host-StartVM.ps1 — VM Auto‑Start Script Reference

This script automatically starts the VRising Hyper‑V virtual machine when the host user logs in. It also sends a Discord notification indicating whether the VM was started or was already running. This script is intended to be used as a lightweight login‑triggered automation on the Hyper‑V host.

---

## 1. Purpose

`VRising-Host-StartVM.ps1` performs the following actions:

- Checks the current state of the VRising VM.
- Starts the VM if it is not already running.
- Sends a Discord notification indicating:
  - The VM is powering on, or
  - The VM was already running, or
  - The VM failed to start.
- Outputs status messages to the console for local visibility.

This script is designed to be executed automatically at host login via Task Scheduler or the Windows Startup folder.

---

## 2. Configuration

The script defines two configuration values:

- **VM name**
  - Variable: `<VMName>`
  - Example: `"HO-VR-HV01"`

- **Discord webhook URL**
  - Variable: `<DiscordWebhookUrl>`
  - Placeholder: `"https://discord.com/api/webhooks/<id>/<token>"`

These values must be set correctly for the script to function.

---

## 3. Discord Notification Function

### Function: `Send-DiscordNotification`

This helper function:

- Accepts a message string.
- Wraps it into a JSON payload:  
  `{ "content": "<message>" }`
- Sends it to `<DiscordWebhookUrl>` using `Invoke-RestMethod`.
- Catches and logs any errors to the console.

This provides out‑of‑band visibility when the VM starts or fails to start.

---

## 4. VM Start Logic

The main logic block performs the following:

### 4.1 Retrieve VM object

```powershell
$vm = Get-VM -Name $VMName

### 4.2 Check VM state

- If the VM is **not running**:
  - Calls `Start-VM -Name <VMName>`
  - Writes a console message confirming the start
  - Sends a Discord notification indicating the VM is powering on

- If the VM **is already running**:
  - Writes a console message indicating it is already online
  - Sends a Discord notification indicating the VM was already running

### 4.3 Error handling

If any exception occurs:

- A console error is printed in red
- A Discord notification is sent indicating the VM failed to start

This ensures operators are aware of failures even when not logged into the host.

---

## 5. Usage Pattern and Intent

This script is intended to be:

- Run automatically when the Hyper‑V host user logs in
- Used as part of a lightweight operational workflow
- Ensuring the VRising VM is always brought online when the host becomes active

Typical deployment methods:

- Windows Task Scheduler (trigger: “At log on”)
- Windows Startup folder (for simple environments)

---

## 6. Limitations and Assumptions

- Assumes the VM exists and is named correctly.
- Assumes the user running the script has permission to manage Hyper‑V VMs.
- Assumes the Discord webhook URL is valid.
- Does not include retry logic for VM startup.
- Does not include logging to disk (console + Discord only).

---

## 7. Potential Future Enhancements

- Add logging to file for audit history.
- Add retry logic for VM startup failures.
- Add health checks after VM start (e.g., ping, WinRM, RCON).
- Parameterize VM name and webhook URL.
- Integrate with a broader VampireGuard host automation suite.

---

## 8. Summary

`VRising-Host-StartVM.ps1` is a simple, reliable script that ensures the VRising VM is started automatically when the host user logs in. It provides immediate operator visibility through Discord notifications and is suitable for lightweight automation scenarios.
