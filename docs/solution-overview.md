# 🧛‍♂️ VampireGuard — Solution Overview  
### A hardened, automated, observable VRising server appliance for Hyper‑V

VampireGuard is a full lifecycle automation framework designed to run a VRising dedicated server inside a secure, single‑purpose Windows VM on Microsoft Hyper‑V. It combines host‑side orchestration, VM‑side hardening, WinRM HTTPS communication, and operational visibility into a cohesive, production‑grade system.

This document provides a high‑level overview of how the system works, why it is designed this way, and how each component fits into the larger architecture.

---

# 1. Purpose & Philosophy

VampireGuard was built to solve a real problem:  
**VRising servers are fragile when managed manually, but extremely reliable when automated.**

The project is guided by several principles:

- **Determinism** — Every script should produce the same result every time.  
- **Idempotency** — Safe to re‑run without breaking anything.  
- **Observability** — You should always know what the server is doing.  
- **Security** — The VM should be locked down to its intended purpose.  
- **Graceful operation** — Backups and shutdowns must never corrupt the world.  
- **Self‑maintenance** — The system should recover from common failure modes.  

The result is a VRising server that behaves like an appliance: predictable, hardened, and easy to operate.

---

# 2. High‑Level Architecture

VampireGuard uses a **two‑layer architecture**:

## 2.1 VM Layer (Inside the VRising VM)

The VM is treated as a sealed appliance. It contains:

- VRising Dedicated Server installation  
- Hardened Windows configuration  
- WinRM HTTPS listener  
- RCON integration  
- NSSM‑based VRising service  
- Firewall lockdown  
- Minimal attack surface  

The VM is not meant to be manually administered after setup.  
All operations flow through WinRM or RCON.

## 2.2 Host Layer (Hyper‑V Host)

The host is responsible for:

- VM lifecycle management  
- Backup orchestration  
- WinRM trust and CredSSP configuration  
- Discord notifications  
- Backup history tracking  
- Scheduled automation  

The host never touches the VRising files directly — it interacts with the VM through secure channels.

---

# 3. Core Components

VampireGuard is composed of several script modules, each with a clear responsibility.  
The components below are listed in the **canonical operational sequence**.

For details on configuring Discord notifications and RCON, see:  
👉 [Notifications & RCON Setup](notifications-and-rcon.md)

---

## 3.1 Host Preparation (01–04)

### **01 — VM Configuration**  
**VRising-Host-VMConfigurator.ps1**  
Ensures the VM is configured correctly for automation (checkpoints disabled, integration services validated, networking prepared).

### **02 — WinRM Setup (Host)**  
**VRising-WinRMSetup.ps1**  
Creates a certificate‑backed WinRM HTTPS listener, configures firewall rules, and prepares secure remote execution.

### **03 — WinRM Trust Establishment**  
**VRising-Host-WinRMTrust.ps1**  
Imports the VM’s certificate, configures TrustedHosts, and enables CredSSP for secure credential delegation.

### **04 — Start VM**  
**VRising-Host-StartVM.ps1**  
Boots the VM and validates WinRM connectivity.

---

## 3.2 VM Preparation (05–08)

### **05 — VM Setup**  
**VRising-VM-Setup.ps1**  
Installs SteamCMD, downloads VRising, and prepares the directory structure.

### **06 — VM Hardening**  
**VRising-VM-Harden.ps1**  
Applies firewall rules, disables unnecessary services, configures Defender, and locks down the VM.

### **07 — WinRM Quick Setup (VM)**  
**VRising-VM-WinRMQuickSetup.ps1**  
Lightweight, interactive WinRM HTTPS configuration for rebuilds or testing.

### **08 — Start VRising Server**  
**VRising-VM-StartServer.ps1**  
Installs and manages the VRising server as an NSSM service, configures RCON, and validates startup.

---

## 3.3 Operations (09)

### **09 — Backup & Lifecycle Automation**  
**VRising-Host-Backup.ps1**  
Performs a full backup cycle:

- Graceful shutdown via RCON  
- VM export  
- Backup history tracking  
- Discord notifications  
- Automatic cleanup  

Backups are atomic and safe to run on a schedule.

---

# 4. Security Model

VampireGuard uses a layered security approach:

- **WinRM over HTTPS** with a self‑signed certificate  
- **Firewall scoping** to host‑only communication  
- **CredSSP** for secure credential delegation  
- **Minimal Windows services**  
- **No inbound HTTP WinRM**  
- **RCON password protection**  
- **Hardened VM with reduced attack surface**  

The VM is effectively a sealed appliance — only the host can manage it.

---

# 5. Automation Lifecycle

A typical automation cycle looks like this:

1. **Host connects to VM via WinRM HTTPS**  
2. **RCON gracefully stops the VRising server**  
3. **VM shuts down cleanly**  
4. **Host exports the VM to a backup directory**  
5. **Backup history is updated**  
6. **Discord notification is sent**  
7. **VM is restarted**  
8. **VRising server service starts automatically**  
9. **Host verifies server health**  

This cycle is deterministic, observable, and safe to run unattended.

---

# 6. Observability & Logging

VampireGuard emphasizes visibility:

- Structured PowerShell logs  
- Discord notifications for:
  - Backup start  
  - Backup success  
  - Backup failure  
  - Server shutdown  
  - Server startup  
- Backup history table  
- Clear error messages  

---
For player connection instructions, see:  
👉 [How to Connect to the VRising Server](how-to-connect.md)
