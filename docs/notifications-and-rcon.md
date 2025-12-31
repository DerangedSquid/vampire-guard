# 🔔 Notifications & RCON Configuration Guide  
### How to enable Discord notifications and secure RCON for VampireGuard

VampireGuard integrates two communication channels to provide observability and safe lifecycle automation:

- **Discord Webhooks** — for operational notifications (backup start, success, failure, shutdown, startup)
- **RCON** — for graceful VRising server shutdowns and health checks

This guide explains how to configure both systems, validate connectivity, and secure them properly.

---

# 1. Discord Notifications  
### Used by: **09‑VRising-Host-Backup.ps1**

VampireGuard uses Discord webhooks to send operational alerts such as:

- Backup started  
- Backup completed  
- Backup failed  
- Server shutdown  
- Server startup  

These notifications provide real‑time visibility into server health and automation status.

---

## 1.1 Create a Discord Webhook

1. Open your Discord server  
2. Go to **Server Settings → Integrations**  
3. Select **Webhooks**  
4. Click **New Webhook**  
5. Choose a channel (recommended: `#server-status` or `#vampireguard`)  
6. Copy the **Webhook URL**

You will paste this URL into your VampireGuard configuration.

---

## 1.2 Store the Webhook URL Securely

**Never commit the webhook URL to Git.**

Store it in an encrypted file:

```powershell
Read-Host "Enter Discord Webhook URL" |
    ConvertTo-SecureString -AsPlainText -Force |
    ConvertFrom-SecureString |
    Out-File "$env:ProgramData\VampireGuard\webhook.txt"
```

The backup script will read this file at runtime.

---

## 1.3 Test the Webhook

```powershell
Invoke-RestMethod `
  -Uri "<YourWebhookURL>" `
  -Method Post `
  -Body '{"content":"VampireGuard webhook test"}' `
  -ContentType 'application/json'
```

If you see a message in Discord, the webhook is working.

---

## 1.4 Security Notes

- Treat webhook URLs like passwords  
- Do not log the full URL  
- Do not store it in plaintext  
- Restrict who can access the ProgramData directory  

---

# 2. RCON Configuration  
### Used by: **08‑VRising-VM-StartServer.ps1** and **09‑VRising-Host-Backup.ps1**

RCON is required for:

- Graceful VRising server shutdown  
- Health checks  
- Pre‑backup validation  

Without RCON, backups cannot safely stop the server, risking world corruption.

---

# 2.1 Enable RCON in VRising

On the VM, open:

```
C:\VRisingServer\VRisingServer_Data\StreamingAssets\Settings\ServerHostSettings.json
```

Ensure the following fields exist:

```json
"Rcon": {
  "Enabled": true,
  "Password": "<YourStrongPassword>",
  "Port": 25575
}
```

### Password Requirements
- Long  
- Random  
- Not reused  
- Not stored in plaintext  

---

# 2.2 Store the RCON Password Securely

```powershell
Read-Host "Enter RCON Password" |
    ConvertTo-SecureString -AsPlainText -Force |
    ConvertFrom-SecureString |
    Out-File "$env:ProgramData\VampireGuard\rcon.txt"
```

The VM‑StartServer and Backup scripts will read this file.

---

# 2.3 Open the RCON Port in the VM Firewall

```powershell
New-NetFirewallRule `
  -DisplayName "VRising RCON" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 25575 `
  -Action Allow
```

Restrict the rule to **host‑only** if possible.

---

# 2.4 Test RCON Connectivity

From the host:

```powershell
# Example using a simple TCP test
Test-NetConnection -ComputerName <VMName> -Port 25575
```

Or use an RCON client to send a test command.

---

# 2.5 Security Notes

- Only allow RCON from the host IP  
- Never expose RCON to the public internet  
- Rotate the password periodically  
- Never log the password  

---

# 3. Integration With VampireGuard Scripts

## 3.1 VM‑StartServer (Script 08)
- Reads encrypted RCON password  
- Configures NSSM service  
- Validates RCON connectivity  

## 3.2 Host‑Backup (Script 09)
- Reads encrypted RCON password  
- Sends graceful shutdown command  
- Verifies server stopped  
- Performs VM export  
- Sends Discord notifications  

---

# 4. Validation Checklist

### Discord
- Webhook created  
- Webhook stored securely  
- Test message received  
- Backup script sends notifications  

### RCON
- Enabled in ServerHostSettings.json  
- Strong password set  
- Firewall rule applied  
- Connectivity test passes  
- Backup script successfully shuts down server  

---

# 5. Reference Links

- Discord Webhooks Documentation  
  https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks

- VRising Dedicated Server Guide  
  https://github.com/StunlockStudios/vrising-dedicated-server-instructions

---

# 6. Summary

Discord notifications provide **visibility**.  
RCON provides **safe lifecycle control**.  
Together, they enable VampireGuard to deliver:

- Graceful shutdowns  
- Atomic backups  
- Real‑time alerts  
- Full observability  

This document ensures end‑users can configure both systems correctly and securely.

---
