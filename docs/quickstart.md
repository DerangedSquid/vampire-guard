# 🧛‍♂️ VampireGuard — Quick Start Guide  
### A fast, high‑level overview for deploying a fully automated VRising server on Hyper‑V

> **For the full, detailed deployment sequence, see the Master Operator Journey:**  
> 👉 **[00‑operator‑journey.md](00-operator-journey.md)**

This Quick Start provides a concise, 10‑minute overview of the VampireGuard setup process.  
It summarizes the required steps and links to the scripts that perform each action.

---

# 1. Prerequisites

Before beginning, ensure the following are ready:

- **Enable CPU virtualization in BIOS/UEFI (Intel VT‑x / AMD‑V / SLAT)**
- **Hyper‑V installed and enabled**
- **A Windows VM created for VRising**
- **Static IPv4 assigned to the VM**
- **PowerShell 5.1+ on both host and VM**
- **NSSM downloaded (optional but recommended)**
- **SteamCMD installed on the VM**

For deeper context, see:  
👉 `/docs/solution-overview.md`  
👉 `/docs/architecture.md`

---

# 2. Prepare the Hyper‑V Host

Run these scripts **on the host** before configuring the VM.

## Step 2.1 — Configure the VM
Run:

- **VRising-Host-VMConfigurator.ps1**  
  Sets up VM hardware, networking, checkpoints, and baseline configuration.

## Step 2.2 — Configure WinRM HTTPS (Host)
Run:

- **VRising-WinRMSetup.ps1**  
  Creates a certificate‑backed WinRM HTTPS listener and enables secure remoting.

## Step 2.3 — Establish WinRM Trust
Run:

- **VRising-Host-WinRMTrust.ps1**  
  Imports the VM certificate, updates TrustedHosts, and enables CredSSP.

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
  Installs SteamCMD, downloads the VRising Dedicated Server, and prepares directories.

## Step 3.2 — Harden the VM
Run:

- **VRising-VM-Harden.ps1**  
  Applies firewall rules, disables unnecessary services, and locks down the VM.

## Step 3.3 — Configure WinRM HTTPS (VM)
Choose one:

- **VRising-VM-WinRMQuickSetup.ps1** (fast interactive version)  
- **VRising-WinRMSetup.ps1** (full production version)

This ensures the VM exposes a secure WinRM HTTPS listener on port **5986**.

---

# 4. Install and Configure the VRising Server Service

Inside the VM:

- **VRising-VM-StartServer.ps1**  
  Launches VRisingServer.exe, configures persistent data paths, and validates startup.

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

Schedule this script using **Task Scheduler** for automated nightly backups.

---

# 6. Validate the Deployment

Confirm the following:

- **WinRM HTTPS connectivity works**
- **PSRemoting works with stored credentials**
- **VRising server starts cleanly**
- **Clients can connect to the server**
- **A manual backup completes successfully**

For a full validation checklist:  
👉 `/docs/guides/validation-checklist.md`

---

# 7. Recommended Next Steps

- Review the **Solution Overview**  
- Study the **Architecture diagrams**  
- Read the **Troubleshooting** appendix  
- Explore **Lessons Learned**  
- Customize your **automation schedule**  

---

# 8. Support & Contribution

If you want to extend VampireGuard:

- Open an issue  
- Submit a pull request  
- Share improvements or scripts  

---

# 9. Configure Notifications & RCON

To enable Discord alerts and safe RCON‑based shutdowns, follow:  
👉 **[Notifications & RCON Setup](notifications-and-rcon.md)**

---

# 10. Share the Server With Friends

Players can join using the simple guide here:  
👉 **[How to Connect to the VRising Server](how-to-connect.md)**

---

> **Next Step:** Continue with the full deployment sequence in the  
> 👉 **[Master Operator Journey](00-operator-journey.md)**  
