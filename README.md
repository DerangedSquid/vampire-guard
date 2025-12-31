# 🧛‍♂️ VampireGuard  
### Automated VRising Server Management for Hyper‑V

VampireGuard is a complete, production‑grade automation suite for running a hardened, observable, self‑maintaining VRising dedicated server on Microsoft Hyper‑V. It transforms a Windows VM into a secure, single‑purpose appliance and provides a full host‑side orchestration layer for backups, lifecycle management, WinRM communication, and operational visibility.

This project was built with a simple goal:  
**Make VRising server hosting reliable, repeatable, and fully automated.**

---

## 🚀 Key Features

- **Full VM lifecycle automation**  
  Setup → Harden → Configure → Start → Backup → Restore

- **Secure WinRM HTTPS communication**  
  Certificate‑backed, firewall‑scoped, CredSSP‑enabled

- **Graceful shutdown + RCON integration**  
  Prevents world corruption and ensures clean backups

- **Deterministic, idempotent scripts**  
  Safe to re‑run, self‑healing, predictable

- **Operational visibility**  
  Discord notifications, structured logs, backup history

- **Hardened VM appliance**  
  Firewall lockdown, service minimization, Defender tuning

- **Production‑ready documentation**  
  Architecture diagrams, troubleshooting, lessons learned

---

## 📦 Documentation

All documentation lives in the `/docs` folder:

- [Quick Start Guide](docs/quickstart.md)
- [Solution Overview](docs/solution-overview.md)
- [Architecture](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Lessons Learned](docs/lessons-learned.md)
- [Script Documentation](docs/scripts/)

---

## 🧭 Quick Start

If you want to get up and running fast, start here:

👉 **[Quick Start Guide](docs/quickstart.md)**

---

## 🏗️ Architecture Summary

VampireGuard uses a two‑layer architecture:

### **1. VM Layer (Inside the VRising VM)**
- VRising installation  
- Hardening  
- WinRM HTTPS listener  
- RCON integration  
- Service installation (NSSM)  

### **2. Host Layer (Hyper‑V Host)**
- VM lifecycle management  
- Backup orchestration  
- WinRM trust + CredSSP  
- Discord notifications  
- Scheduled automation  

Full diagrams available in:  
👉 **[Architecture](docs/architecture.md)**

---

## 🛠️ Scripts Included

### **Host-Side Automation**
- [VRising-Host-Backup.ps1](scripts/VRising-Host-Backup.ps1) — [Docs](docs/scripts/VRising-Host-Backup.md)  
- [VRising-Host-StartVM.ps1](scripts/VRising-Host-StartVM.ps1) — [Docs](docs/scripts/VRising-Host-StartVM.md)  
- [VRising-Host-VMConfigurator.ps1](scripts/VRising-Host-VMConfigurator.ps1) — [Docs](docs/scripts/HyperV-Host-VMConfigurator.md)  
- [VRising-Host-WinRMTrust.ps1](scripts/VRising-Host-WinRMTrust.ps1) — [Docs](docs/scripts/VRising-Host-WinRMTrust.md)  

### **VM-Side Automation**
- [VRising-VM-Setup.ps1](scripts/VRising-VM-Setup.ps1) — [Docs](docs/scripts/VRising-VM-Setup.md)  
- [VRising-VM-Harden.ps1](scripts/VRising-VM-Harden.ps1) — [Docs](docs/scripts/VRising-VM-Harden.md)  
- [VRising-VM-StartServer.ps1](scripts/VRising-VM-StartServer.ps1) — [Docs](docs/scripts/VRising-VM-StartServer.md)  

### **WinRM / Connectivity Tools**
- [VRising-WinRMSetup.ps1](scripts/VRising-WinRMSetup.ps1) — [Docs](docs/scripts/VRising-WinRMSetup.md)  
- [VRising-VM-WinRMQuickSetup.ps1](scripts/VRising-VM-WinRMQuickSetup.ps1) — [Docs](docs/scripts/VRising-VM-WinRMQuickSetup.md)  

---

## 🧪 Requirements

- Windows 10/11 or Windows Server with Hyper‑V  
- VRising Dedicated Server (SteamCMD)  
- PowerShell 5.1+  
- WinRM HTTPS enabled  
- NSSM (optional but recommended)  

---

## 🧛‍♂️ About the Project

VampireGuard was built to solve a real problem:  
**VRising servers deserve the same reliability and automation as enterprise workloads.**

This project is the result of deep iteration, real-world testing, and a commitment to operational excellence.

For the full story, see:  
👉 **[Lessons Learned](docs/lessons-learned.md)**

---
