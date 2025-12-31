# 🧛‍♂️ VampireGuard — Operations Runbook  
### Deterministic procedures for operating, maintaining, and recovering the VampireGuard VRising environment

This runbook defines the operational procedures for running, maintaining, and recovering the VampireGuard‑managed VRising server environment. It is designed for deterministic, low‑ambiguity execution during both routine operations and emergency scenarios.

---

# 1. Purpose

This document provides:

- Step‑by‑step operational procedures  
- Recovery workflows  
- Verification and health‑check steps  
- Emergency actions  
- VM rebuild and restore processes  

It is intended for operators, administrators, and future maintainers of the VampireGuard automation platform.

---

# 2. Daily / Routine Operations

## 2.1 Check VM Health
```powershell
Get-VM -Name <VMName>
```
Confirm:
- State is **Running**  
- No unexpected checkpoints  
- No critical Hyper‑V events  

## 2.2 Check VRising Service
```powershell
Get-Service -Name VRising
```
Confirm:
- Status is **Running**  
- Startup type is **Automatic**  

## 2.3 Check Last Backup
Review:
- Backup history JSON  
- Discord summary notification  
- Timestamp of last successful export  

For notification setup details, see:  
👉 `docs/notifications-and-rcon.md`

## 2.4 Check Disk Space
```powershell
Get-PSDrive -Name C
```
Ensure:
- Sufficient free space for next export  
- Backup directory is not approaching capacity  

---

# 3. Running a Manual Backup

## 3.1 Preconditions
- VM reachable via WinRM HTTPS  
- RCON responding  
- Sufficient disk space  
- No active Hyper‑V operations  

For RCON configuration details, see:  
👉 `docs/notifications-and-rcon.md`

## 3.2 Execute Backup
```powershell
.\scripts\VRising-Host-Backup.ps1 -Verbose
```

## 3.3 Expected Behavior
- RCON shutdown  
- VM transitions to **Off**  
- Hyper‑V export begins  
- Backup directory receives a new timestamped folder  
- VM restarts  
- Discord summary notification sent  

## 3.4 Post‑Backup Validation
- Confirm VM is running  
- Confirm VRising service is running  
- Confirm backup folder exists  
- Confirm history JSON updated  

---

# 4. Restoring From Backup

## 4.1 Locate Backup
Navigate to:
```
<BackupRoot>\<Timestamp>\
```

## 4.2 Import VM
```powershell
Import-VM -Path "<BackupPath>" -Copy
```

## 4.3 Reassign Network Switch
```powershell
Connect-VMNetworkAdapter -VMName <VMName> -SwitchName "<Switch>"
```

## 4.4 Validate WinRM
```powershell
Test-WSMan -ComputerName <VMName> -UseSSL
```

## 4.5 Start VM
```powershell
Start-VM -Name <VMName>
```

## 4.6 Validate VRising Service
```powershell
Get-Service -Name VRising
```

## 4.7 Validate RCON
Send a test command or status query.

For RCON troubleshooting, see:  
👉 `docs/notifications-and-rcon.md`

---

# 5. Starting / Stopping the VM

## 5.1 Graceful Stop (Recommended)
Use RCON to stop the VRising server before shutting down the VM:
```powershell
# Example RCON stop command
# (Actual command depends on your RCON client)
```

Then shut down the VM:
```powershell
Stop-VM -Name <VMName>
```

## 5.2 Forced Stop (Last Resort)
```powershell
Stop-VM -Name <VMName> -Force
```

## 5.3 Start VM
```powershell
Start-VM -Name <VMName>
```

## 5.4 Post‑Start Checks
- WinRM reachable  
- VRising service running  
- RCON responding  

---

# 6. Validating System Health

## 6.1 WinRM Test
```powershell
Test-WSMan -ComputerName <VMName> -UseSSL
```

## 6.2 RCON Test
Send a status command.

## 6.3 VRising Service Test
```powershell
Get-Service -Name VRising
```

## 6.4 Disk Space Test
```powershell
Get-PSDrive -Name C
```

## 6.5 Backup Directory Test
Ensure:
- Directory exists  
- Permissions intact  
- No corruption  

---

# 7. Scheduled Automation (Task Scheduler)

## 7.1 Run Job Manually
Right‑click → **Run**

## 7.2 Check Last Run Result
Look for:
- **0x0** success  
- Any non‑zero code indicates failure  

## 7.3 Fix Common Issues
- Ensure script path is correct  
- Ensure “Run with highest privileges” is enabled  
- Ensure correct user context  
- Ensure working directory is correct  

---

# 8. Log Locations

## 8.1 Host Logs
- PowerShell transcript logs  
- Hyper‑V event logs  

## 8.2 VM Logs
- Windows Event Viewer  
- VRising logs  

## 8.3 VampireGuard Logs
- Backup history JSON  
- Script‑generated logs  

## 8.4 Discord Logs
- Webhook response codes  
- Error messages  

For webhook setup, see:  
👉 `docs/notifications-and-rcon.md`

---

# 9. Emergency Procedures

## 9.1 VM Won’t Start
- Check Hyper‑V event logs  
- Check disk space  
- Remove stale checkpoints  
- Attempt import from last backup  

## 9.2 WinRM Broken
- Recreate HTTPS listener  
- Re‑import certificate  
- Validate firewall rules  
- Re‑run scripts **02** and **03**  

## 9.3 RCON Unresponsive
- Restart VRising service  
- Validate firewall  
- Regenerate password  
- Re‑run script **08**  
- See: `docs/notifications-and-rcon.md`

## 9.4 Backup Export Fails
- Ensure VM is fully off  
- Clear checkpoints  
- Validate permissions  
- Re‑run script **09**  

## 9.5 Restore Fails
- Validate backup integrity  
- Re‑import VM cleanly  
- Reassign network switch  

---

# 10. Rebuild Procedure

## 10.1 Create New VM
- Apply hardened configuration  
- Install VRising  
- Install NSSM wrapper  

## 10.2 Configure WinRM HTTPS
- Generate certificate  
- Bind listener  
- Trust certificate on host  
- Re‑run scripts **02**, **03**, and **07**  

## 10.3 Reconnect VampireGuard
- Validate WinRM  
- Validate RCON  
- Validate service  

## 10.4 Restore From Backup
Follow section 4.

---

# 11. Completion Checklist

- VM running  
- VRising service running  
- WinRM reachable  
- RCON responding  
- Backup history updated  
- Discord notifications working  

---

# 12. Integration References

- **Discord Notifications & RCON Setup**  
  👉 `docs/notifications-and-rcon.md`

- **Player Connection Guide**  
  👉 `docs/how-to-connect.md`
