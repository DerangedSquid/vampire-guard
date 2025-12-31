# NAT Switch Setup Guide (Hyper‑V)

This guide explains how to create and validate a Hyper‑V NAT switch for VampireGuard.  
It ensures your VRising VM has a static internal IP and that VRising ports are reachable externally.

---

## 1. Overview

A NAT switch provides:

- A private internal subnet for the VM  
- A gateway IP on the host  
- NAT translation for outbound traffic  
- Static port mappings for VRising (9876/9877 UDP)

Recommended example subnet:

- Subnet: 192.168.200.0/24  
- Host gateway: 192.168.200.1  
- VM IP: 192.168.200.10  

You may adjust these values, but the subnet must not overlap your physical LAN.

---

## 2. Create the NAT switch

Run on the host in an elevated PowerShell session:

    New-VMSwitch -Name "VG-NAT" -SwitchType Internal

Verify:

    Get-VMSwitch -Name "VG-NAT"

You should see a switch named VG-NAT with SwitchType = Internal.

---

## 3. Assign host gateway IP

Assign the host’s virtual NIC (created by Hyper‑V) a gateway IP in your chosen subnet:

    $NatAdapterName = "vEthernet (VG-NAT)"
    New-NetIPAddress -IPAddress "192.168.200.1" -PrefixLength 24 -InterfaceAlias $NatAdapterName

Verify:

    Get-NetIPAddress -InterfaceAlias $NatAdapterName

You should see 192.168.200.1/24 assigned to vEthernet (VG-NAT).

---

## 4. Create NAT object

Create the NAT object that will translate traffic for this subnet:

    New-NetNat -Name "VG-NAT-Network" -InternalIPInterfaceAddressPrefix "192.168.200.0/24"

Verify:

    Get-NetNat -Name "VG-NAT-Network"

You should see InternalIPInterfaceAddressPrefix = 192.168.200.0/24.

---

## 5. Attach VM to NAT switch

Attach your VRising VM to the VG-NAT switch:

    Connect-VMNetworkAdapter -VMName "VG-VRising-01" -SwitchName "VG-NAT"

Alternatively, you can set this in Hyper‑V Manager under VM Settings → Network Adapter.

---

## 6. Configure static IP inside VM

Inside the VRising VM, assign a static IP in the NAT subnet:

    $IfIndex = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).IfIndex
    New-NetIPAddress -InterfaceIndex $IfIndex -IPAddress "192.168.200.10" -PrefixLength 24 -DefaultGateway "192.168.200.1"
    Set-DnsClientServerAddress -InterfaceIndex $IfIndex -ServerAddresses "1.1.1.1"

Adjust the IP and DNS server to match your environment.

---

## 7. Add VRising port mappings

Expose VRising’s default ports (9876/9877 UDP) through the host:

    Add-NetNatStaticMapping -NatName "VG-NAT-Network" -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 9876 -InternalIPAddress "192.168.200.10" -InternalPort 9876
    Add-NetNatStaticMapping -NatName "VG-NAT-Network" -Protocol UDP -ExternalIPAddress "0.0.0.0" -ExternalPort 9877 -InternalIPAddress "192.168.200.10" -InternalPort 9877

Verify:

    Get-NetNatStaticMapping -NatName "VG-NAT-Network"

You should see mappings for UDP 9876 and 9877 pointing at the VM IP.

---

## 8. Connectivity tests

Host to VM (WinRM port as an example):

    Test-NetConnection 192.168.200.10 -Port 5986

VM to internet:

    Test-NetConnection www.google.com -Port 443

Both should succeed before you proceed with VampireGuard setup.

---

## 9. Summary

At this point:

- The host has a NAT switch and gateway IP.  
- The VM has a static IP on that NAT network.  
- VRising ports are mapped through to the VM.

Your NAT network is now ready for VRising and VampireGuard lifecycle automation.
