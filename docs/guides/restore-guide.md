# VampireGuard Restore Guide (Hyper‑V Export)

This guide explains how to restore a VRising VM from a VampireGuard backup that uses Hyper‑V exports (or similar VM‑level backups).

---

## 1. Locate the Backup Export

On the host, find the export folder created by VampireGuard. A typical structure looks like:

    D:\VampireGuard\Backups\VG-VRising-01\2025-01-15_020000\
        Virtual Machines\
        Virtual Hard Disks\
        Snapshots\

List available restore points:

    Get-ChildItem "D:\VampireGuard\Backups\VG-VRising-01" -Directory

Choose the timestamped folder you want to restore from.

---

## 2. Decide Your Restore Strategy

Before importing, decide:

- Same host or a different host  
- Same VM name or a new name  
- Paths for VM configuration and disks (for example, D:\HyperV\VG-VRising-01 and D:\HyperV\VG-VRising-01\Disks)

If the original VM still exists and you want to replace it, cleanly shut it down and remove it from Hyper‑V first.

---

## 3. Import the VM From the Export

On the host:

    $ExportPath = "D:\VampireGuard\Backups\VG-VRising-01\2025-01-15_020000"
    $NewVMPath  = "D:\HyperV\VG-VRising-01"
    $NewVHDPath = "D:\HyperV\VG-VRising-01\Disks"

    New-Item -ItemType Directory -Path $NewVMPath -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType Directory -Path $NewVHDPath -ErrorAction SilentlyContinue | Out-Null

    Import-VM -Path $ExportPath -Copy -GenerateNewId -VirtualMachinePath $NewVMPath -VhdDestinationPath $NewVHDPath

This uses “Copy the virtual machine” semantics and generates a new VM ID.

If you prefer to retain the original ID and the old VM has been removed, you can omit -GenerateNewId.

---

## 4. Reconfigure Networking

After import, confirm the VM has a NIC attached to the correct switch:

- In Hyper‑V Manager → VM Settings → Network Adapter → VG-NAT  

Then, inside the VM:

    $IfIndex = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).IfIndex
    New-NetIPAddress -InterfaceIndex $IfIndex -IPAddress "192.168.200.10" -PrefixLength 24 -DefaultGateway "192.168.200.1"
    Set-DnsClientServerAddress -InterfaceIndex $IfIndex -ServerAddresses "1.1.1.1"

Adjust the IP, gateway, and DNS to match your original design.

---

## 5. Recreate NAT Mappings (If Needed)

If you are restoring on a new host or the NAT configuration has changed, recreate the mappings:

    Add-NetNatStaticMapping -NatName "VG-NAT-Network" -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 9876 -InternalIPAddress "192.168.200.10" -InternalPort 9876
    Add-NetNatStaticMapping -NatName "VG-NAT-Network" -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 9877 -InternalIPAddress "192.168.200.10" -InternalPort 9877

Confirm:

    Get-NetNatStaticMapping -NatName "VG-NAT-Network"

---

## 6. Validate the Restored VM

Use the validation checklist (see validation-checklist.md) and confirm:

- The VM boots normally  
- WinRM HTTPS is listening and reachable from the host  
- VRising files exist where you expect them (for example, E:\Games\VRisingServer)  
- VRising server starts successfully  
- Clients can connect to the server  

If any of these fail, resolve them before resuming automated backups.

---

## 7. Update VampireGuard Configuration

If you restored under a new name, new IP, or on a new host, update:

- VM name in VampireGuard configuration  
- VM IP or hostname used for WinRM and RCON  
- Backup target paths or retention settings if they are path‑dependent  

Once configuration is aligned with the restored VM, VampireGuard can resume normal lifecycle and backup operations.
