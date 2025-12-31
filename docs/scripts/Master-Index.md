# Script Documentation Index  
### VampireGuard Automation Suite

This directory contains detailed documentation for every automation script included in VampireGuard.  
The sequence below reflects the **correct operational order** for configuring, hardening, and operating a VRising server on Hyper‑V.

---

## 🧱 Phase 1 — Host Preparation

### **1. VM Configuration**
- [HyperV-Host-VMConfigurator.md](HyperV-Host-VMConfigurator.md)  
Configures the VM hardware, networking, checkpoints, and baseline settings.

### **2. WinRM Setup (Host)**
- [VRising-WinRMSetup.md](VRising-WinRMSetup.md)  
Enables WinRM HTTPS, installs certificates, and prepares secure remote execution.

### **3. WinRM Trust Establishment**
- [VRising-Host-WinRMTrust.md](VRising-Host-WinRMTrust.md)  
Configures CredSSP, certificate trust, and host‑to‑VM secure communication.

### **4. Start VM**
- [VRising-Host-StartVM.md](VRising-Host-StartVM.md)  
Boots the VM and validates WinRM connectivity.

---

## 🖥️ Phase 2 — VM Preparation

### **5. VM Setup**
- [VRising-VM-Setup.md](VRising-VM-Setup.md)  
Installs VRising Dedicated Server, SteamCMD, dependencies, and service scaffolding.

### **6. VM Hardening**
- [VRising-VM-Harden.md](VRising-VM-Harden.md)  
Applies firewall lockdown, disables unnecessary services, and configures Defender.

### **7. WinRM Quick Setup (VM)**
- [VRising-VM-WinRMQuickSetup.md](VRising-VM-WinRMQuickSetup.md)  
Fast‑path WinRM configuration for testing or rebuild scenarios.

### **8. Start VRising Server**
- [VRising-VM-StartServer.md](VRising-VM-StartServer.md)  
Starts the VRising server with NSSM, RCON integration, and graceful shutdown logic.

---

## 💾 Phase 3 — Operations

### **9. Backup**
- [VRising-Host-Backup.md](VRising-Host-Backup.md)  
Performs safe, consistent backups with pre‑shutdown RCON and post‑backup validation.

---

## 📌 Notes

- Scripts are idempotent and safe to re‑run.  
- Each script includes logging, validation, and error‑handling patterns.  
- This sequence is the **canonical operator workflow** for VampireGuard.

---

### Additional Documentation

- [Notifications & RCON Setup](../notifications-and-rcon.md)  
- [How to Connect to the VRising Server](../how-to-connect.md)
