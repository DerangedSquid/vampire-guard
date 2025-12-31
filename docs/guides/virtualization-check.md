# 🧬 Virtualization Support & BIOS Configuration Guide  
### Ensuring Hyper‑V Compatibility Before Deploying VampireGuard  
**File:** `/docs/guides/virtualization-check.md`

This guide ensures your system supports hardware virtualization and that all required CPU features are enabled before installing Hyper‑V or running any VampireGuard automation.  
Missing virtualization support is one of the most common root causes of VM creation failures, WinRM issues, and broken operator workflows.

---

# 1. Overview

Hyper‑V requires the following CPU features:

- Intel VT‑x **or** AMD‑V  
- SLAT (Second Level Address Translation)  
- Hardware‑assisted virtualization  
- Data Execution Prevention (DEP)  
- Optional but recommended: IOMMU / VT‑d  

If these are disabled in BIOS/UEFI, Hyper‑V may install but **VMs will not run**, causing cascading failures across the entire VampireGuard stack.

This guide helps you verify and enable these features.

---

# 2. Step 1 — Check Virtualization Support in Windows

Run the following commands in PowerShell:

### Check if virtualization is enabled:

    systeminfo | find "Virtualization"

Expected output:

- “Virtualization Enabled In Firmware: Yes”

### Check SLAT support:

    Get-WmiObject Win32_Processor | Select-Object Name, SecondLevelAddressTranslationExtensions

Expected output:

- `SecondLevelAddressTranslationExtensions : True`

### Check Hyper‑V capability:

    Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

Expected output:

- `State : Enabled` (or “Disabled” if not yet installed)

If any of these checks fail, proceed to BIOS configuration.

---

# 3. Step 2 — Enable Virtualization in BIOS/UEFI

Reboot your system and enter BIOS/UEFI setup.  
Common keys: **DEL**, **F2**, **F10**, **F12**, **ESC**.

Enable the following settings (names vary by vendor):

### Intel systems:

- Intel Virtualization Technology (VT‑x)  
- Intel VT‑d (IOMMU)  
- Intel Hyper‑Threading (optional but recommended)  
- Execute Disable Bit (XD)  

### AMD systems:

- SVM Mode (AMD‑V)  
- AMD IOMMU  
- NX Mode (No‑Execute)  

### Additional recommended settings:

- Enable “Hardware Virtualization”  
- Enable “Memory Remapping”  
- Disable “Legacy Virtualization” or “Compatibility Mode” if present  

Save changes and reboot.

---

# 4. Step 3 — Re‑run Validation After BIOS Changes

After rebooting, run the validation commands again:

    systeminfo | find "Virtualization"

    Get-WmiObject Win32_Processor | Select-Object Name, SecondLevelAddressTranslationExtensions

If all checks return positive results, your system is now Hyper‑V ready.

---

# 5. Step 4 — Validate Hyper‑V Installation

If Hyper‑V is not yet installed:

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

Reboot when prompted.

Then confirm:

    Get-VMHost

Expected output includes:

- Logical processors  
- VirtualizationFirmwareEnabled : True  
- IovSupport : True (if IOMMU enabled)

---

# 6. Troubleshooting

### Virtualization still shows as disabled
- BIOS changes were not saved  
- System has a second virtualization layer (e.g., VMware, VirtualBox) blocking Hyper‑V  
- Windows Core Isolation / Memory Integrity may interfere  
- Some OEMs hide virtualization settings under “Advanced Mode”

### SLAT shows as False
- Older CPUs may not support SLAT  
- Hyper‑V cannot run without SLAT  
- No workaround exists except upgrading hardware

### Hyper‑V role fails to install
- Ensure Windows is Pro/Enterprise/Server  
- Ensure no conflicting hypervisors are installed  
- Disable Windows Subsystem for Android (WSA) if present

---

# 7. Integration With the Operator Journey

This guide should be completed **before**:

- Installing Hyper‑V  
- Creating the NAT switch  
- Running VMConfigurator  
- Running any VampireGuard host scripts  
- Attempting VM creation or import  

Add this step to your preflight checklist to avoid silent failures.

---

# 8. Related Documentation

- **VM Creation Guide** (vm-creation.md)  
- **NAT Switch Setup** (nat-switch-setup.md)  
- **VM Setup Guide** (vm-setup.md)  
- **Validation Checklist** (validation-checklist.md)  
- **Master Operator Journey** (../00-operator-journey.md)

---

# 9. Summary

After completing this guide, you will have:

- Verified CPU virtualization support  
- Enabled VT‑x / AMD‑V in BIOS  
- Confirmed SLAT capability  
- Validated Hyper‑V readiness  
- Eliminated a major class of VM creation and automation failures  

Your system is now fully prepared for Hyper‑V and VampireGuard deployment.

---
