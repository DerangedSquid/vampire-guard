# 🖥️ VRising VM Setup Guide  
### Installing SteamCMD, VRising Dedicated Server, and Preparing the VM Environment  
**File:** `/docs/guides/vm-setup.md`

This guide walks you through preparing the VRising VM with all required components before hardening, WinRM configuration, and server automation.  
It corresponds to **Phase 2 — VM Preparation** in the Master Operator Journey.

---

# 1. Overview

The VRising VM must be configured with:

- SteamCMD  
- VRising Dedicated Server  
- Required directory structure  
- Baseline configuration files  
- Log and data paths  
- Optional NSSM service scaffolding  

This guide explains the manual steps and links to the automation script that performs them.

For the automated version, see:  
👉 **05‑VRising‑VM‑Setup.md** (../scripts/05-VRising-VM-Setup.md)

---

# 2. Prerequisites

Before running the setup:

- Windows 10/11 or Windows Server installed in the VM  
- Static IP assigned (from NAT switch guide)  
- PowerShell 5.1+  
- Internet access from the VM  
- At least 10 GB free disk space  
- Optional: NSSM downloaded to C:\Tools\NSSM  

If you haven’t created the VM yet, see:  
👉 **VM Creation Guide** (vm-creation.md)

---

# 3. Create Required Directory Structure

Inside the VM, create the following folders:

    C:\VRising\
    C:\VRising\Server\
    C:\VRising\Data\
    C:\VRising\Logs\
    C:\Tools\

If using NSSM:

    C:\Tools\NSSM\

These paths are used by all VampireGuard scripts.

---

# 4. Install SteamCMD

Download SteamCMD from Valve:

1. Go to:  
   https://developer.valvesoftware.com/wiki/SteamCMD

2. Download the Windows version (steamcmd.zip)

3. Extract it to:

       C:\VRising\Server\steamcmd\

4. Run SteamCMD once to bootstrap:

       C:\VRising\Server\steamcmd\steamcmd.exe

It will self‑update and create required files.

---

# 5. Install VRising Dedicated Server

Inside SteamCMD, run:

    login anonymous
    app_update 1829350 validate
    quit

This installs the VRising server into:

    C:\VRising\Server\vrisingdedicatedserver\

---

# 6. Create the VRising Data Directory

VRising stores world data separately from the server binaries.

Create:

    C:\VRising\Data\world1\

This ensures:

- Backups are clean  
- World data persists across updates  
- Server files remain immutable  

---

# 7. Configure Server Settings

VRising uses two main config files:

    C:\VRising\Server\vrisingdedicatedserver\VRisingServer_Data\StreamingAssets\Settings\ServerHostSettings.json
    C:\VRising\Server\vrisingdedicatedserver\VRisingServer_Data\StreamingAssets\Settings\ServerGameSettings.json

Recommended changes:

- Set SaveName to "world1"  
- Set AutoSaveCount to a reasonable number (e.g., 40)  
- Set AutoSaveInterval to 120–300 seconds  
- Configure RCON (required for graceful shutdowns)

For RCON setup, see:  
👉 **Notifications & RCON Setup** (../notifications-and-rcon.md)

---

# 8. Optional: Install VRising as a Service (NSSM)

If using NSSM:

    nssm install VRisingServer "C:\VRising\Server\vrisingdedicatedserver\VRisingServer.exe"

Set:

- Startup directory: C:\VRising\Server\vrisingdedicatedserver\  
- Log path: C:\VRising\Logs\server.log  

This allows:

- Automatic restarts  
- Clean shutdowns  
- Integration with VampireGuard automation  

---

# 9. Validate the Installation

Before proceeding:

1. Launch the server manually:

       C:\VRising\Server\vrisingdedicatedserver\VRisingServer.exe

2. Confirm:

- No missing DLL errors  
- World loads correctly  
- Logs appear in C:\VRising\Logs  
- RCON port is listening (if configured)

3. Close the server cleanly.

If validation fails, see:  
👉 **Troubleshooting Guide** (../troubleshooting.md)

---

# 10. Continue to the Next Step

Once the VM setup is complete, proceed to:

👉 **VM Hardening Guide** (vm-harden.md)  
👉 **WinRM Quick Setup** (../scripts/07-VRising-VM-WinRMQuickSetup.md)  
👉 **Master Operator Journey** (../00-operator-journey.md)

---

# 11. Related Documentation

- **VM Creation:** vm-creation.md  
- **NAT Switch Setup:** nat-switch-setup.md  
- **Restore Guide:** restore-guide.md  
- **Validation Checklist:** validation-checklist.md  

---

# 12. Summary

After completing this guide, your VM will have:

- SteamCMD installed  
- VRising Dedicated Server installed  
- World data directory created  
- Config files prepared  
- Optional NSSM service installed  
- Logs and data paths standardized  

Your VM is now ready for hardening, WinRM configuration, and full VampireGuard automation.

---
