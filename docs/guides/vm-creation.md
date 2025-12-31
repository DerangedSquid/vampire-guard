# VRising VM Creation Guide (Hyper‑V)

This guide walks you through creating a VRising VM that works cleanly with VampireGuard’s lifecycle and backup flows.

---

## 1. Recommended VM Specs

Suggested baseline:

- OS: Windows Server 2019/2022 or Windows 10/11 Pro  
- Generation: Generation 2 (UEFI)  
- vCPU: 2–4  
- RAM: 8–12 GB (avoid starving the VM)  
- Disks:
  - OS disk: 80–120 GB
  - Data disk (recommended): 100–200 GB for VRising + saves

You can scale up based on player count and world size.

---

## 2. Create the VM (Hyper‑V Manager)

1. Open Hyper‑V Manager on the host.  
2. In the left pane, right‑click the host → New → Virtual Machine.  
3. Name: VG-VRising-01 (or similar).  
4. Generation: Generation 2.  
5. Memory: at least 8192 MB.  
6. Networking:
   - Temporary: an external switch.
   - Later: switch to VG-NAT (if not already created).
7. Virtual hard disk:
   - Create new VHDX (e.g., 100 GB).
   - Store it on a fast SSD/NVMe volume.
8. Installation options:
   - Attach your Windows ISO.

Complete the wizard and create the VM.

---

## 3. Install the Guest OS

Inside the VM:

- Boot from the Windows ISO.  
- Complete the standard Windows installation.  
- Install all critical and security updates.  
- Enable Remote Desktop (optional but useful).  
- Set a strong password for the local Administrator account.

Once finished, you should be able to log in via the Hyper‑V console (and optionally RDP).

---

## 4. Add an Optional Data Disk

A separate data disk makes backups and restores cleaner.

On the host:

1. Shut down the VM.  
2. In Hyper‑V Manager, right‑click VG-VRising-01 → Settings.  
3. Under SCSI Controller → Hard Drive → Add.  
4. Create a new VHDX (e.g., 100–200 GB).  
5. Start the VM.

Inside the VM:

1. Open Disk Management (diskmgmt.msc).  
2. Initialize the new disk.  
3. Create a new NTFS volume and assign a drive letter (for example, E:).  

Plan to host SteamCMD and VRising on this data disk.

---

## 5. Attach VM to the NAT Switch

If you have already created VG-NAT:

    Connect-VMNetworkAdapter -VMName "VG-VRising-01" -SwitchName "VG-NAT"

Or, use Hyper‑V Manager → VM Settings → Network Adapter → VG-NAT.

Inside the VM, configure a static IP on the NAT subnet (see NAT switch guide).

---

## 6. Install SteamCMD and VRising

Inside the VM, on your data disk (for example, E:):

    New-Item -ItemType Directory -Path "E:\Tools\SteamCMD"
    New-Item -ItemType Directory -Path "E:\Games\VRisingServer"

Download SteamCMD from Valve and extract it into E:\Tools\SteamCMD.

Then, from a Command Prompt or PowerShell in that folder:

    steamcmd +login anonymous +force_install_dir "E:\Games\VRisingServer" +app_update 1829350 validate +quit

After this completes, VRising server files should be under E:\Games\VRisingServer.

---

## 7. First Manual VRising Server Run

Inside the VM:

    cd /d "E:\Games\VRisingServer"
    VRisingServer.exe

Confirm:

- The server window opens and starts without immediate crash.  
- Config and save directories are created.  
- Logs indicate the server is listening on the expected ports (9876/9877).

If this works, you know the VM is capable of running VRising before introducing automation.

---

## 8. Prepare for VampireGuard

Before plugging in VampireGuard:

- Ensure WinRM HTTPS is configured and reachable from the host.  
- Ensure firewall rules allow VRising, RCON, and WinRM traffic.  
- Decide where configuration files (for VRising and VampireGuard) will live.

The VM is now ready to be managed by VampireGuard.
