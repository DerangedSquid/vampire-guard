# 🛡️ VampireGuard — Security Architecture & Hardening Guide  
### A sealed‑appliance security model for VRising on Hyper‑V

VampireGuard is designed around a hardened, appliance‑style VM with a minimal attack surface, strict trust boundaries, and deterministic host‑to‑VM automation. This document defines the security model, required configurations, and operational safeguards that ensure the system remains secure, predictable, and tamper‑resistant.

---

# 1. Security Philosophy

VampireGuard follows these principles:

- **Least privilege** — Only required services and ports are enabled.  
- **Deterministic trust** — WinRM HTTPS with pinned certificates and strict validation.  
- **Isolated blast radius** — The VRising server runs inside a hardened VM, not on the host.  
- **Observable security** — Logs, history, and notifications provide visibility.  
- **Automated enforcement** — Scripts validate and enforce configuration on every run.  

The VM is treated as a **sealed appliance**, not a general‑purpose Windows machine.

---

# 2. Host Security Requirements (Scripts 01–04, 09)

## 2.1 Administrative Context
The automation account must be:

- A local administrator  
- Allowed to run WinRM CredSSP delegation  
- Allowed to manage Hyper‑V  

## 2.2 Credential Storage
Credentials should be stored using:

- `Get-Credential` → `Export-Clixml`  
- Machine‑bound encryption  
- No plaintext secrets in scripts or logs  

Example:
```powershell
Get-Credential | Export-Clixml -Path "$env:ProgramData\VampireGuard\vm-creds.xml"
```

## 2.3 Host Firewall Rules
Required outbound rules:

- TCP 5986 → VM (WinRM HTTPS)  
- TCP RCON port → VM  

No inbound rules are required for VampireGuard.

---

# 3. VM Hardening Requirements (Scripts 05–08)

## 3.1 Remove Unnecessary Services
Disable or remove:

- SMB  
- Remote Desktop  
- Unused Windows features  
- Any service not required by VRising or WinRM  

## 3.2 Firewall Lockdown
Inbound rules allowed:

- TCP 5986 (WinRM HTTPS)  
- TCP RCON port  
- VRising game port (optional, if hosting publicly)  

Everything else should be blocked.

## 3.3 Local Administrator Password
- Use a long, random password  
- Store only in encrypted credential files  
- Rotate periodically  

## 3.4 VRising Service Hardening
- Run under `LocalSystem`  
- Managed via NSSM  
- Logs stored in a restricted directory  

---

# 4. WinRM HTTPS Trust Model (Scripts 02, 03, 07)

WinRM is the backbone of VampireGuard automation. It must be configured securely.

## 4.1 Certificate Requirements
- Self‑signed or CA‑issued  
- CN must match the VM hostname  
- Minimum 2048‑bit RSA  
- Installed in:  
  - VM: `LocalMachine\My`  
  - Host: `LocalMachine\Root`  

## 4.2 Listener Configuration
```powershell
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname='<VMName>'; CertificateThumbprint='<Thumbprint>'}"
```

## 4.3 Trust Validation
On the host:
```powershell
Test-WSMan -ComputerName <VMName> -UseSSL
```

If this fails, automation must not proceed.

---

# 5. RCON Security (Script 08)

## 5.1 Password Requirements
- Long, random, non‑dictionary  
- Stored only in encrypted config  
- Never logged  

## 5.2 Firewall Rules
Allow inbound RCON only from:

- Host IP  
- (Optional) Monitoring systems  

## 5.3 Authentication Failures
Repeated failures should trigger:

- VRising service restart  
- Password rotation  
- Firewall review  

---

# 6. Backup Security (Script 09)

## 6.1 Backup Directory Permissions
- Host‑only access  
- No network shares  
- No user‑writable paths  

## 6.2 Backup Integrity
Each backup folder contains:

- Full VM export  
- No incremental deltas  
- No external dependencies  

This ensures backups are tamper‑resistant and self‑contained.

## 6.3 History File Protection
- JSON file stored in restricted directory  
- Write‑only by automation account  
- Never exposed externally  

---

# 7. Discord Webhook Security

## 7.1 Webhook Handling
- Store URL in encrypted config  
- Never commit to Git  
- Never log full URL  

## 7.2 Payload Validation
Ensure:

- No user‑supplied content  
- No secrets in messages  

---

# 8. Operational Security Controls

## 8.1 Health Checks Before Automation
Automation must validate:

- WinRM trust  
- RCON connectivity  
- VM state  
- Disk space  
- Backup directory permissions  

## 8.2 Post‑Backup Security Checks
- VM state restored  
- VRising service running  
- No unexpected firewall changes  
- No unauthorized services enabled  

---

# 9. Incident Response

## 9.1 WinRM Compromise
- Rotate certificate  
- Recreate listener  
- Re‑import trust on host  
- Review firewall rules  

## 9.2 RCON Compromise
- Rotate password  
- Restrict firewall  
- Restart VRising service  

## 9.3 VM Compromise
- Shut down VM  
- Restore from last known‑good backup  
- Rebuild VM if necessary  

## 9.4 Host Compromise
- Rotate all credentials  
- Rebuild host  
- Re‑establish trust chain  
- Re‑import VM from backup  

---

# 10. Security Checklist

- WinRM HTTPS validated  
- Certificate trusted  
- Firewall locked down  
- RCON secured  
- VRising service hardened  
- Backup directory protected  
- Credentials encrypted  
- Discord webhook secured  
- VM treated as sealed appliance  
