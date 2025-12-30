# 🧛‍♂️ VampireGuard — Troubleshooting Guide

VampireGuard is designed to be deterministic and observable, but issues can still arise from network configuration, WinRM trust, RCON connectivity, or Hyper-V export behavior. This guide provides fast, targeted diagnostics for the most common failure modes.

---

# 1. WinRM HTTPS Issues

## Common Symptoms
- Scripts hang at **Connecting to remote server…**
- Errors like: `WinRM cannot complete the operation`, `The SSL certificate is not trusted`, `The server did not respond`
- Backup job stops at **Connect to VM via WinRM HTTPS**

## Quick Checks
- Verify listener exists:
  ```powershell
  winrm enumerate winrm/config/listener
  ```
- Confirm HTTPS is bound to the correct certificate
- Ensure firewall allows port 5986 from host → VM
- Validate certificate trust:
  ```powershell
  Test-WSMan -ComputerName <VMName> -UseSSL
  ```

## Fixes
- Recreate the WinRM HTTPS listener
- Re-import the certificate into `LocalMachine\Root` on the host
- Ensure the VM’s hostname matches the certificate CN

---

# 2. RCON Connectivity Problems

## Symptoms
- Backup job hangs at **Send RCON Shutdown**
- VRising server never stops
- Errors like: `Unable to connect to RCON`, `Authentication failed`

## Quick Checks
- Confirm RCON port is open in the VM firewall
- Validate RCON password in `ServerHostSettings.json`
- Test manually

## Fixes
- Restart the VRising service
- Regenerate the RCON password
- Re-apply firewall rules

---

# 3. Hyper-V Export / Backup Failures

## Symptoms
- Backup stops at **Export VM to Backup Directory**
- Errors like: `The requested operation could not be completed`, `Access denied`, `0x80070005`

## Quick Checks
- Ensure the backup directory exists and is writable
- Confirm the VM is fully stopped before export
- Check disk space on the host
- Review Hyper-V event logs

## Fixes
- Run export manually to confirm the issue
- Clear stale checkpoints
- Ensure no other process is locking the VM files

---

# 4. VM Startup / Shutdown Issues

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
- Re-enable guest services
- Reinstall NSSM wrapper
- Recreate the VRising service

---

# 5. Credential / Permission Problems

## Symptoms
- WinRM authentication failures
- Export permission errors
- Errors like: `Access is denied`, `The user does not have the required privileges`

## Quick Checks
- Ensure the automation account is a local admin on the host
- Confirm CredSSP is enabled
- Validate stored credentials

## Fixes
- Re-run credential setup script
- Re-enable CredSSP:
  ```powershell
  Enable-WSManCredSSP -Role Client -DelegateComputer <VMName>
  ```

---

# 6. Discord Notification Failures

## Symptoms
- No notifications after backup
- Errors like: `400 Bad Request`, `Webhook not found`

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

---

# 7. Backup History / Dashboard Issues

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

---

# 8. Full Diagnostic Workflow

1. Test WinRM:
   ```powershell
   Test-WSMan -ComputerName <VMName> -UseSSL
   ```
2. Test RCON
3. Check VM state
4. Check VRising service
5. Run backup in verbose mode
6. Check logs + Discord output
7. Review Hyper-V event logs

---

# 9. When to Rebuild the VM

Rebuild only if:
- WinRM cannot be repaired
- Firewall rules are irreparably corrupted
- The VM OS is damaged
- VRising service repeatedly fails to start

VampireGuard’s architecture makes rebuilds safe because backups are atomic and self-contained.
