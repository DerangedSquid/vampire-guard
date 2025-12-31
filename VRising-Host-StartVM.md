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
