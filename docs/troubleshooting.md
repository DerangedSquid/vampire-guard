# 🧛‍♂️ VampireGuard — Troubleshooting Guide  
### Fast, deterministic diagnostics for common failure modes

VampireGuard is designed to be predictable and observable, but issues can still arise from WinRM configuration, RCON connectivity, Hyper‑V export behavior, or VM hardening. This guide provides targeted diagnostics aligned with the VampireGuard architecture and script sequence.

---

# 1. WinRM HTTPS Issues (Host ↔ VM)

## Common Symptoms
- Scripts hang at **Connecting to remote server…**  
- Errors such as:  
  - `WinRM cannot complete the operation`  
  - `The SSL certificate is not trusted`  
  - `The server did not respond`  
- Backup job stops at **Connect to VM via WinRM HTTPS**

## Quick Checks
- Verify listener exists:
  ```powershell
  winrm enumerate winrm/config/listener
  ```
- Confirm HTTPS is bound to the correct certificate  
- Ensure firewall allows port **5986** from host → VM  
- Validate certificate trust:
  ```powershell
  Test-WSMan -ComputerName <VMName> -UseSSL
  ```

## Fixes
- Recreate the WinRM HTTPS listener  
- Re‑import the VM certificate into `LocalMachine\Root` on the host  
- Ensure the VM hostname matches the certificate CN  
- Re‑run:
  - **02‑VRising-WinRMSetup.ps1**  
  - **03‑VRising-Host-WinRMTrust.ps1**

---

# 2. RCON Connectivity Problems (VM → Server)

## Symptoms
- Backup job hangs at **Send RCON Shutdown**  
- VRising server never stops  
- Errors like:  
  - `Unable to connect to RCON`  
  - `Authentication failed`

## Quick Checks
- Confirm RCON port is open in the VM firewall  
- Validate RCON password in `ServerHostSettings.json`  
- Test manually using a local RCON client  

## Fixes
- Restart the VRising service  
- Regenerate the RCON password  
- Re‑apply firewall rules  
- Re‑run:
  - **08‑VRising-VM-StartServer.ps1**

---

# 3. Hyper‑V Export / Backup Failures (Host)

## Symptoms
- Backup stops at **Export VM to Backup Directory**  
- Errors such as:  
  - `The requested operation could not be completed`  
  - `Access denied`  
  - `0x80070005`

## Quick Checks
- Ensure the backup directory exists and is writable  
- Confirm the VM is fully stopped before export  
- Check disk space on the host  
- Review Hyper‑V event logs  

## Fixes
- Run export manually to confirm the issue  
- Clear stale checkpoints  
- Ensure no other process is locking VM files  
- Re‑run:
  - **09‑VRising-Host-Backup.ps1** in verbose mode

---

# 4. VM Startup / Shutdown Issues (Host ↔ VM)

## Symptoms
- VM doesn’t shut down during backup  
- VM doesn’t start after backup  
- VRising service doesn’t start automatically  

## Quick Checks
- Validate integration services  
- Check VM state:
  ```powershell
  Get-VM -Name <VMName>
  ```
- Check VRising service:
  ```powershell
  Get-Service -Name VRising
  ```

## Fixes
- Re‑enable guest services  
- Reinstall NSSM wrapper  
- Recreate the VRising service  
- Re‑run:
  - **08‑VRising-VM-StartServer.ps1**

---

# 5. Credential / Permission Problems (Host)

## Symptoms
- WinRM authentication failures  
- Export permission errors  
- Errors like:  
  - `Access is denied`  
  - `The user does not have the required privileges`

## Quick Checks
- Ensure the automation account is a local admin on the host  
- Confirm CredSSP is enabled  
- Validate stored credentials  

## Fixes
- Re‑run credential setup  
- Re‑enable CredSSP:
  ```powershell
  Enable-WSManCredSSP -Role Client -DelegateComputer <VMName>
  ```
- Re‑run:
  - **03‑VRising-Host-WinRMTrust.ps1**

---

# 6. Discord Notification Failures (Host)

## Symptoms
- No notifications after backup  
- Errors like:  
  - `400 Bad Request`  
  - `Webhook not found`

## Quick Checks
- Validate webhook URL  
- Confirm JSON payload is valid  
- Test manually:
  ```powershell
  Invoke-RestMethod -Uri <Webhook> -Method Post -Body '{"content":"test"}' -ContentType 'application/json'
  ```

## Fixes
- Regenerate webhook  
- Ensure no trailing spaces or hidden characters in the URL  
- Re‑run backup to confirm notifications

---

# 7. Backup History / Dashboard Issues (Host)

## Symptoms
- History table not updating  
- Dashboard shows stale or missing data  
- Flags not resetting after backup  

## Quick Checks
- Confirm the history JSON file exists  
- Validate JSON structure  
- Check write permissions  

## Fixes
- Recreate the history file  
- Run the history repair function (if implemented)  
- Re‑run:
  - **09‑VRising-Host-Backup.ps1**

---

# 8. Full Diagnostic Workflow (Recommended Order)

1. Test WinRM:
   ```powershell
   Test-WSMan -ComputerName <VMName> -UseSSL
   ```
2. Test RCON  
3. Check VM state  
4. Check VRising service  
5. Run backup in verbose mode  
6. Check logs + Discord output  
7. Review Hyper‑V event logs  
8. Re‑run relevant numbered scripts (01–09)

---

# 9. When to Rebuild the VM

Rebuild only if:

- WinRM cannot be repaired  
- Firewall rules are irreparably corrupted  
- The VM OS is damaged  
- VRising service repeatedly fails to start  

VampireGuard’s architecture makes rebuilds safe because backups are atomic and self‑contained.

---
