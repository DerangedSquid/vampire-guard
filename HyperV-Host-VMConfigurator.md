# HyperV-Host-VMConfigurator.ps1 — Provisioning Script Reference

This script prepares a Windows host for Hyper‑V usage and provisions a new virtual machine with user‑defined CPU, memory, disk, and networking. It is intended as a one‑time or occasional provisioning tool, not part of the VampireGuard runtime automation pipeline.

---

## 1. Purpose

`HyperV-Host-VMConfigurator.ps1` performs the following:

- Ensures the Hyper‑V feature is installed and enabled.
- Collects current host resource information (RAM, disk, CPU, network adapters).
- Prompts the user for VM sizing and configuration inputs.
- Creates a new Hyper‑V VM with a virtual disk.
- Attaches a Windows installation ISO.
- Creates (if needed) and attaches an external virtual switch.
- Starts the VM for OS installation.

It is designed to give operators an interactive, guided way to stand up a new Hyper‑V VM that will later host workloads such as VampireGuard’s VRising server appliance.

---

## 2. Execution prerequisites

- **Operating system:**
  - Windows 10 Enterprise, Pro, or Education (or compatible Windows with Hyper‑V support).

- **Hardware requirements:**
  - SLAT‑capable CPU with virtualization enabled in BIOS.
  - At least 4 GB RAM (practically more if hosting VMs).

- **Permissions:**
  - Script must be run as a user with administrative rights (to manage Windows features and Hyper‑V).

- **Execution policy:**
  - If execution policy blocks the script, run:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    ```
    This applies only to the current PowerShell session.

- **Paths and resources:**
  - VM storage root: `C:\Hyper V\Hosts` (created/used by the script).
  - ISO path placeholder: `C:\Path\To\ISO\WindowsInstall.iso`

---

## 3. High-level workflow

1. Check whether the Hyper‑V feature is enabled.
2. If not enabled, enable Hyper‑V and request a reboot.
3. Query current host resources (RAM, disk, CPU cores, network adapters).
4. Prompt user for VM configuration (name, memory, disk size, core count, network adapter).
5. Create the VM in `C:\Hyper V\Hosts`.
6. Create and attach a dynamic VHDX.
7. Mount a Windows installation ISO to the VM’s DVD drive.
8. Create an external virtual switch (if not already present) and connect the VM.
9. Start the VM and hand control to the OS installation process.

---

## 4. Detailed execution flow

### 4.1 Hyper‑V feature detection and enablement

- The script calls:
  ```powershell
  $hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
  ```
- If `State -eq "Enabled"`: prints “Hyper‑V is already enabled.”
- If not enabled: enables Hyper‑V and exits after prompting for reboot.

---

### 4.2 Host resource discovery

The script gathers host resource data:

- Available memory (GB)
- Available disk space on C: (GB)
- CPU cores
- Network adapters (Up)

These values are displayed to the user as context for sizing decisions.

---

### 4.3 Interactive user input

Prompts for:

- VM name
- VM memory (GB)
- VM disk size (GB)
- VM CPU cores
- Network adapter selection

All inputs are validated against available system resources.

---

### 4.4 VM creation

- VM path: `C:\Hyper V\Hosts`
- Creates VM with selected memory
- Configures CPU cores

---

### 4.5 Virtual disk creation and attachment

- Creates dynamic VHDX sized per user input
- Attaches disk to VM

---

### 4.6 ISO mounting

- Uses placeholder ISO path: `C:\Path\To\ISO\WindowsInstall.iso`
- Mounts ISO to VM DVD drive

---

### 4.7 Virtual switch creation and network connection

- Switch name: `ExternalSwitch`
- Creates switch if missing
- Connects VM to switch

---

### 4.8 VM startup

Starts the VM so the operator can complete OS installation.

---

## 5. Usage pattern and intent

This script is intended for interactive, one‑off or occasional VM provisioning.

---

## 6. Limitations and assumptions

- Hard‑coded paths for VM storage and ISO
- Only one external switch name
- Assumes system drive is `C:`
- No transcript or log file support

---

## 7. Potential future enhancements

- Convert prompts into parameters
- Add logging/transcripts
- Support multiple ISO profiles
- Make switch name configurable
- Integrate into a full host bootstrap pipeline
