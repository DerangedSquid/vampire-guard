# 🧛‍♂️ VampireGuard — Quick Start Guide
### A fast, reliable path to a fully automated VRising server on Hyper‑V

This guide walks you through the minimum required steps to get VampireGuard deployed and operational. Follow these steps in order and you’ll end up with a hardened VRising VM, secure WinRM communication, automated backups, and a fully observable server lifecycle.

---

# 1. Prerequisites

Before you begin, ensure the following are ready:

- **Hyper‑V installed and enabled**
- **A Windows VM created for VRising**
- **Static IPv4 assigned to the VM**
- **PowerShell 5.1+ on both host and VM**
- **NSSM downloaded (optional but recommended)**
- **SteamCMD installed on the VM**

---

# 2. Prepare the VRising VM

Log into the VM and run the following scripts in order.

## Step 2.1 — Initial VM Setup
Run:

- **VRising-VM-Setup.ps1**  
  Installs SteamCMD, downloads the VRising Dedicated Server, and prepares the directory structure.

## Step 2.2 — Harden the VM
Run:

- **VRising-VM-Harden.ps1**  
  Applies firewall rules, disables unnecessary services, and locks down the VM into a single‑purpose appliance.

## Step 2.3 — Configure WinRM HTTPS
Choose one of the following:

- **VRising-WinRMSetup.ps1** (full production version)
- **VRising-VM-WinRMQuickSetup.ps1** (interactive quick version)

This creates a certificate‑backed WinRM HTTPS listener and opens port 5986.

---

# 3. Prepare the Hyper‑V Host

On the host machine, run the following scripts.

## Step 3.1 — Establish WinRM Trust
Run:

- **VRising-Host-WinRMTrust.ps1**  
  Imports the VM’s certificate, configures TrustedHosts, and enables CredSSP.

## Step 3.2 — Configure VM Integration
Run:

- **VRising-Host-VMConfigurator.ps1**  
  Validates VM state, ensures checkpoints are disabled, and prepares the host for lifecycle automation.

---

# 4. Install and Configure the VRising Server Service

Inside the VM:

- **VRising-VM-StartServer.ps1**  
  Installs the VRising server as an NSSM service (if enabled), configures RCON, and validates startup.

---

# 5. Enable Automated Backups

On the host:

- **VRising-Host-Backup.ps1**  
  Performs:

  - Graceful shutdown via RCON  
  - Full VM export  
  - Backup history tracking  
  - Discord notifications  
  - Automatic cleanup of old backups  

You can schedule it using Task Scheduler.

---

# 6. Validate the Deployment

Perform the following checks:

- **Test WinRM HTTPS connectivity**
- **Test PSRemoting with stored credentials**
- **Start the VRising server service**
- **Connect to the server from a VRising client**
- **Trigger a manual backup**

If everything passes, your VampireGuard deployment is fully operational.

---

# 7. Recommended Next Steps

- Review the Solution Overview
- Study the Architecture diagrams
- Read the Troubleshooting appendix
- Explore the Lessons Learned
- Customize your automation schedule

---

# 8. Support & Contribution

If you want to extend VampireGuard:

- Open an issue
- Submit a pull request
- Share improvements or scripts

---
