# Master Operator Journey  
**VampireGuard — Full System Deployment & Operations Guide**  
**File:** `/docs/00-operator-journey.md`

This document is the **canonical, start‑to‑finish operator flow** for deploying, securing, running, backing up, restoring, and maintaining a VRising dedicated server using **VampireGuard**.  
It unifies and cross‑links **all existing documentation** across `/docs/architecture`, `/docs/guides`, and `/docs/scripts`.

---

# 1. Overview

VampireGuard is a **deterministic, observable, self‑healing automation suite** for VRising servers running inside a Hyper‑V VM.  
This Operator Journey walks you through the entire lifecycle:

1. Provision the VM  
2. Create NAT networking  
3. Install VRising  
4. Configure WinRM HTTPS  
5. Harden the VM  
6. Start the server  
7. Configure automated backups  
8. Validate the environment  
9. Restore from backup  
10. Operate day‑to‑day

If you follow this sequence, your environment will be **predictable, secure, and fully automatable**.

---

# 2. Architecture Overview

Before beginning, review the system architecture:

- `/docs/architecture/start-here-overview.md`  
- `/docs/architecture/architecture.md`  
- `/docs/architecture/solution-overview.md`

These explain:

- Host ↔ VM relationship  
- NAT networking  
- WinRM HTTPS  
- RCON  
- VRising server  
- Backup/export lifecycle  
- Notification channels  

Understanding this model ensures the rest of the journey makes sense.

---

# 3. Prerequisites

Before starting:

- Windows 10/11 Pro or Windows Server with Hyper‑V enabled  
- SLAT‑capable CPU  
- At least 16 GB RAM recommended  
- SSD/NVMe storage  
- Administrative privileges  
- VRising license (for clients)  
- Discord webhook (optional but recommended)  
- Static IP plan for the VM  
- Folder structure under `C:\Hyper V\` and `D:\VMBackups\`  

See:

- `/docs/security.md`  
- `/docs/quickstart.md`

---

# 4. Create the VRising VM

You may create the VM manually or using the interactive configurator.

### **Recommended Guide**
- `/docs/guides/vm-creation.md`

### **Script Reference**
- `/docs/scripts/01-HyperV-Host-VMConfigurator.md`

### **Outcome**
You will have:

- A Generation 2 VM  
- 8–12 GB RAM  
- 2–4 vCPUs  
- OS disk + optional data disk  
- Windows installed  
- VRising installation path ready  

Do not proceed until the VM is fully installed and reachable via Hyper‑V console.

---

# 5. Create the NAT Switch & Assign Static IP

This is the foundation for:

- WinRM HTTPS  
- RCON  
- VRising port exposure  
- Host ↔ VM communication  

### **Guide**
- `/docs/guides/nat-switch-setup.md`

### **Outcome**
You will have:

- NAT switch: `VG-NAT`  
- Host gateway: e.g., `192.168.200.1`  
- VM static IP: e.g., `192.168.200.10`  
- NAT mappings for UDP 9876/9877  

Do not proceed until:

- Host can reach VM  
- VM can reach internet  
- NAT mappings appear in `Get-NetNatStaticMapping`

---

# 6. Install VRising Dedicated Server

Install SteamCMD and VRising inside the VM.

### **Guide**
- `/docs/guides/vm-creation.md` (Section: Install SteamCMD + VRising)

### **Script Reference**
- `/docs/scripts/05-VRising-VM-Setup.md`

### **Outcome**
You will have:

- VRising installed at:  
  `C:\VRising\Server\vrisingdedicatedserver`  
- Data directory at:  
  `C:\VRising\Data\world1`  
- VRisingServer.exe launches manually  

Do not proceed until VRising starts cleanly.

---

# 7. Configure WinRM HTTPS (Secure Remote Execution)

This is required for:

- Backup automation  
- Remote process control  
- VM lifecycle management  
- Hardening  
- Health checks  

### **Primary Script**
- `/docs/scripts/02-VRising-WinRMSetup.md`

### **Host Trust Script**
- `/docs/scripts/03-VRising-Host-WinRMTrust.md`

### **Quick VM Setup (optional)**
- `/docs/scripts/07-VRising-VM-WinRMQuickSetup.md`

### **Outcome**
You will have:

- Self‑signed certificate installed  
- WinRM HTTPS listener on port 5986  
- Host trusts VM certificate  
- CredSSP enabled  
- TrustedHosts updated  
- PSRemoting functional  

Do not proceed until:

- `Test-WSMan -UseSSL` succeeds  
- `Invoke-Command` works with stored credentials  

---

# 8. Harden the VRising VM

This step locks down:

- Firewall  
- WinRM  
- RCON  
- Services  
- Accounts  
- Defender  
- Attack surface  

### **Script**
- `/docs/scripts/06-VRising-VM-Harden.md`

### **Outcome**
You will have:

- Only required ports open  
- WinRM HTTPS enforced  
- RCON restricted to host IP  
- Unnecessary services disabled  
- Administrator account disabled  
- Defender configured  

Do not proceed until the hardening log shows no errors.

---

# 9. Start the VRising Server (Inside VM)

### **Script**
- `/docs/scripts/08-VRising-VM-StartServer.md`

### **Outcome**
You will have:

- VRisingServer.exe running  
- Logs written to `C:\VRising\Logs`  
- Discord notification (optional)  
- Persistent data path validated  

Do not proceed until the server is confirmed running.

---

# 10. Configure Automated Backups (Host)

This is the core of VampireGuard.

### **Script**
- `/docs/scripts/09-VRising-Host-Backup.md`

### **Guide**
- `/docs/guides/restore-guide.md`

### **Outcome**
You will have:

- Scheduled backups  
- In‑game notifications  
- Graceful shutdown  
- Forced kill fallback  
- VM export  
- VM restart  
- Discord notifications  
- Dual‑location logs  

Do not proceed until:

- A full backup completes  
- Export folder contains a valid VM export  
- VM restarts cleanly  

---

# 11. Validate the Entire Environment

### **Guide**
- `/docs/guides/validation-checklist.md`

### **Outcome**
You confirm:

- NAT works  
- WinRM works  
- RCON works  
- VRising runs  
- Backups run  
- Restore works  
- Hardening applied  
- Ports open  
- Players can connect  

This is the final gate before production.

---

# 12. Restore Workflow (When Needed)

### **Guide**
- `/docs/guides/restore-guide.md`

### **Outcome**
You can:

- Import VM from backup  
- Reassign NAT switch  
- Reapply static IP  
- Recreate NAT mappings  
- Revalidate WinRM  
- Restart VRising  

This completes the lifecycle.

---

# 13. Player‑Facing Documentation

### **Guide**
- `/docs/how-to-connect.md`

### **Notifications & RCON**
- `/docs/notifications-and-rcon.md`

Provide these to players/admins as needed.

---

# 14. Troubleshooting

### **Guide**
- `/docs/troubleshooting.md`

Covers:

- WinRM  
- NAT  
- RCON  
- VM lifecycle  
- VRising startup  
- Backup failures  

---

# 15. Operational Runbook

### **Guide**
- `/docs/runbook.md`

This is your day‑to‑day operations reference.

---

# 16. Lessons Learned & Security

### **Guides**
- `/docs/lessons-learned.md`  
- `/docs/security.md`

These capture:

- Architectural decisions  
- Security posture  
- Operational insights  

---

# 17. Documentation Navigation

### **Sidebar**
- `/docs/sidebar.md`

### **Master Index**
- `/docs/scripts/Master-Index.md`

These provide structured navigation across the entire documentation suite.

---

# 18. Completion

If you have followed this Operator Journey:

- Your VM is hardened  
- Your server is running  
- Your backups are automated  
- Your restore process is validated  
- Your documentation is complete  
- Your architecture is sound  
- Your system is production‑ready  

VampireGuard is now fully deployed.

---
