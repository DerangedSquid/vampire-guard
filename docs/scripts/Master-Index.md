# Script Documentation Index  
### VampireGuard Automation Suite

This directory contains detailed documentation for every automation script included in VampireGuard.  
The sequence below reflects the **canonical operational order** for provisioning, hardening, and operating a VRising server on Hyper‑V.

> For the full deployment lifecycle, see the  
> 👉 **[Master Operator Journey](../00-operator-journey.md)**

---

## 🧱 Phase 1 — Host Preparation

### **1. VM Configuration**
- [01-HyperV-Host-VMConfigurator.md](01-HyperV-Host-VMConfigurator.md)  
Configures VM hardware, networking, checkpoints, and baseline settings.

### **2. WinRM Setup (Host)**
- [02-VRising-WinRMSetup.md](02-VRising-WinRMSetup.md)  
Enables WinRM HTTPS, installs certificates, and prepares secure remote execution.

### **3. WinRM Trust Establishment**
- [03-VRising-Host-WinRMTrust.md](03-VRising-Host-WinRMTrust.md)  
Configures CredSSP, certificate trust, and host‑to‑VM secure communication.

### **4. Start VM**
- [04-VRising-Host-StartVM.md](04-VRising-Host-StartVM.md)  
Boots the VM and validates WinRM connectivity.

---

## 🖥️ Phase 2 — VM Preparation

### **5. VM Setup**
- [05-VRising-VM-Setup.md](05-VRising-VM-Setup.md)  
Installs VRising Dedicated Server, SteamCMD, dependencies, and directory scaffolding.

### **6. VM Hardening**
- [06-VRising-VM-Harden.md](06-VRising-VM-Harden.md)  
Applies firewall lockdown, disables unnecessary services, and configures Defender.

### **7. WinRM Quick Setup (VM)**
- [07-VRising-VM-WinRMQuickSetup.md](07-VRising-VM-WinRMQuickSetup.md)  
Fast‑path WinRM configuration for testing or rebuild scenarios.

### **8. Start VRising Server**
- [08-VRising-VM-StartServer.md](08-VRising-VM-StartServer.md)  
Starts the VRising server with persistent data paths, RCON integration, and logging.

---

## 💾 Phase 3 — Operations

### **9. Backup Engine**
- [09-VRising-Host-Backup.md](09-VRising-Host-Backup.md)  
Performs safe, consistent backups with RCON shutdown, VM export, and notifications.

---

## 📌 Notes

- All scripts are **idempotent** and safe to re‑run.  
- Each script includes **logging**, **validation**, and **error‑handling**.  
- This sequence represents the **official operator workflow** for VampireGuard.

---

## 📚 Additional Documentation

- [Notifications & RCON Setup](../notifications-and-rcon.md)  
- [How to Connect to the VRising Server](../how-to-connect.md)
