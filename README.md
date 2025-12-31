<!-- PROJECT BADGES -->
<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-Automation-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Hyper--V-VM%20Lifecycle-8A2BE2?style=for-the-badge" />
  <img src="https://img.shields.io/badge/WinRM-HTTPS%20Secure-4B9CD3?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Backups-Atomic%20Exports-2E8B57?style=for-the-badge" />
  <img src="https://img.shields.io/badge/RCON-Graceful%20Shutdowns-DAA520?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Production%20Ready-32CD32?style=for-the-badge" />
</p>

<!-- PROJECT TITLE VISUAL -->
<p align="center">
  <img src="https://img.shields.io/badge/VampireGuard-HyperV%20VRising%20Automation-8B0000?style=for-the-badge&logo=windows" />
</p>

<!-- QUICK SUMMARY BAR -->
<p align="center">
  <b>Hardened VM</b> • <b>Secure WinRM</b> • <b>RCON Integration</b> • <b>Deterministic Backups</b> • <b>Full Observability</b>
</p>

---

# 🧛‍♂️ VampireGuard  
### Automated VRising Server Management for Hyper‑V

VampireGuard is a complete, production‑grade automation suite for running a hardened, observable, self‑maintaining VRising dedicated server on Microsoft Hyper‑V. It transforms a Windows VM into a secure, single‑purpose appliance and provides a full host‑side orchestration layer for backups, lifecycle management, WinRM communication, and operational visibility.

This project was built with a simple goal:  
**Make VRising server hosting reliable, repeatable, and fully automated.**

---

# 🚀 Start Here — Master Operator Journey

If you're deploying VampireGuard for the first time, begin with the **Master Operator Journey**:

👉 **[00‑operator‑journey.md](docs/00-operator-journey.md)**

This guide walks you through the entire lifecycle:  
VM creation → NAT → WinRM → Hardening → VRising install → Backups → Validation → Restore.

---

## 🧭 Quick Start (10‑Minute Overview)

If you want a fast, high‑level summary of the setup process:

👉 **[Quick Start Guide](docs/quickstart.md)**

For the full, detailed deployment sequence, see the  
👉 **[Master Operator Journey](docs/00-operator-journey.md)**

---

## 📚 Documentation Map

- **Master Operator Journey** — full deployment sequence  
- **Quick Start** — high‑level overview  
- **Architecture** — system design and diagrams  
- **Guides** — NAT, VM creation, restore, validation, notifications  
- **Scripts** — detailed documentation for each automation script  
- **Runbook** — day‑to‑day operations  
- **Troubleshooting** — common issues and fixes  
- **Security** — hardening and best practices  
- **Lessons Learned** — design rationale and insights  

---

## 📦 Documentation

All documentation lives in the `/docs` folder:

- [Master Operator Journey](docs/00-operator-journey.md)
- [Quick Start Guide](docs/quickstart.md)
- [Solution Overview](docs/solution-overview.md)
- [Architecture](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Lessons Learned](docs/lessons-learned.md)
- [Script Documentation](docs/scripts/)

---

## 📣 Notifications & RCON

VampireGuard integrates:

- **Discord Webhooks** for backup alerts, shutdown/startup messages, and error reporting  
- **RCON** for graceful VRising server shutdowns and health checks  

Configuration instructions:  
👉 [Notifications & RCON Setup](docs/notifications-and-rcon.md)

---

## 🎮 How Players Connect

Server owners can share this guide with friends or community members:

👉 [How to Connect to the VRising Server](docs/how-to-connect.md)

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

### **Phase 1 — Host-Side Preparation**
1. [VRising-Host-VMConfigurator.ps1](scripts/VRising-Host-VMConfigurator.ps1) — [Docs](docs/scripts/01-HyperV-Host-VMConfigurator.md)  
2. [VRising-WinRMSetup.ps1](scripts/VRising-WinRMSetup.ps1) — [Docs](docs/scripts/02-VRising-WinRMSetup.md)  
3. [VRising-Host-WinRMTrust.ps1](scripts/VRising-Host-WinRMTrust.ps1) — [Docs](docs/scripts/03-VRising-Host-WinRMTrust.md)  
4. [VRising-Host-StartVM.ps1](scripts/VRising-Host-StartVM.ps1) — [Docs](docs/scripts/04-VRising-Host-StartVM.md)  

### **Phase 2 — VM Preparation**
5. [VRising-VM-Setup.ps1](scripts/VRising-VM-Setup.ps1) — [Docs](docs/scripts/05-VRising-VM-Setup.md)  
6. [VRising-VM-Harden.ps1](scripts/VRising-VM-Harden.ps1) — [Docs](docs/scripts/06-VRising-VM-Harden.md)  
7. [VRising-VM-WinRMQuickSetup.ps1](scripts/VRising-VM-WinRMQuickSetup.ps1) — [Docs](docs/scripts/07-VRising-VM-WinRMQuickSetup.md)  
8. [VRising-VM-StartServer.ps1](scripts/VRising-VM-StartServer.ps1) — [Docs](docs/scripts/08-VRising-VM-StartServer.md)  

### **Phase 3 — Operations**
9. [VRising-Host-Backup.ps1](scripts/VRising-Host-Backup.ps1) — [Docs](docs/scripts/09-VRising-Host-Backup.md)     

---

## 🧪 Requirements

- Windows 10/11 or Windows Server with Hyper‑V  
- VRising Dedicated Server (SteamCMD)  
- PowerShell 5.1+  
- WinRM HTTPS enabled  
- NSSM (optional but recommended)  

Before beginning setup, review the  
👉 **[Master Operator Journey](docs/00-operator-journey.md)**

---

## 🧛‍♂️ About the Project

VampireGuard was built to solve a real problem:  
**VRising servers deserve the same reliability and automation as enterprise workloads.**

This project is the result of deep iteration, real-world testing, and a commitment to operational excellence.

For the full story, see:  
👉 **[Lessons Learned](docs/lessons-learned.md)**

---
