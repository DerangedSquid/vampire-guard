# 🧛‍♂️ VampireGuard — Quick Start Guide  
### A fast, reliable path to a fully automated VRising server on Hyper‑V

This guide walks you through the exact sequence required to deploy a hardened, observable, fully automated VRising server using VampireGuard. Follow these steps in order to ensure a clean, deterministic setup.

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

# 2. Prepare the Hyper‑V Host

Run these scripts **on the host** before touching the VM.

## Step 2.1 — Configure the VM
Run:

- **VRising-Host-VMConfigurator.ps1**  
  Configures VM hardware, checkpoints, networking, and baseline settings.

## Step 2.2 — Configure WinRM HTTPS (Host)
Run:

- **VRising-WinRMSetup.ps1**  
  Creates a certificate‑backed WinRM HTTPS listener and enables secure remoting.

## Step 2.3 — Establish WinRM Trust
Run:

- **VRising-Host-WinRMTrust.ps1**  
  Imports the VM certificate, configures TrustedHosts, and enables CredSSP.

## Step 2.4 — Start the VM
Run:

- **VRising-Host-StartVM.ps1**  
  Boots the VM and validates WinRM connectivity.

---

# 3. Prepare the VRising VM

Log into the VM and run the following scripts in order.

## Step 3.1 — Initial VM Setup
Run:

- **VRising-VM-Setup.ps1**  
  Installs SteamCMD, downloads the VRising Dedicated Server, and prepares the directory structure.

## Step 3.2 — Harden the VM
Run:

- **VRising-VM-Harden.ps1**  
  Applies firewall rules, disables unnecessary services, and locks down the VM.

## Step 3.3 — Configure WinRM HTTPS (VM)
Choose one:

- **VRising-VM-WinRMQuickSetup.ps1** (fast interactive version)
- **VRising-WinRMSetup.ps1** (full production version)

This ensures the VM exposes a secure WinRM HTTPS listener on port 5986.

---

# 4. Install and Configure the VRising Server Service

Inside the VM:

- **VRising-VM-StartServer.ps1**  
  Installs the VRising server as an NSSM service, configures RCON, and validates startup.

---

# 5. Enable Automated Backups

Run on the host:

- **VRising-Host-Backup.ps1**  
  Performs:

  - Graceful shutdown via RCON  
  - Full VM export  
  - Backup history tracking  
  - Discord notifications  
  - Automatic cleanup of old backups  

You can schedule this using Task Scheduler.

---

# 6. Validate the Deployment

Perform the following checks:

- **Test WinRM HTTPS connectivity**
- **Test PSRemoting with stored credentials**
- **Start the VRising server service**
- **Connect from a VRising client**
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

# 9. Configure Notifications & RCON

To enable Discord alerts and safe RCON-based shutdowns, follow:  
👉 [Notifications & RCON Setup](notifications-and-rcon.md)

---

# 10. Share the Server With Friends

Players can join using the simple guide here:  
👉 [How to Connect to the VRising Server](how-to-connect.md)
