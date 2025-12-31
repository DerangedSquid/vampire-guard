# Start‑Here Architecture Overview

This document provides a high‑level overview of the VampireGuard architecture and how the major components interact.  
It is intended to be the first file new operators read before diving into setup or automation details.

---

## 1. Components

### Hyper‑V Host
- Runs VampireGuard automation scripts  
- Hosts the VRising VM  
- Provides the VG‑NAT virtual switch  
- Handles NAT port mappings for external access  

### VRising VM
- Runs Windows (Server or Pro)  
- Hosts the VRising dedicated server  
- Exposes WinRM HTTPS for remote management  
- Exposes RCON for administrative control  

### Network Layer
- VG‑NAT internal network between host and VM  
- NAT mappings exposing VRising ports externally  
- Router/edge device forwards UDP 9876/9877 to the host  

### Players & Admins
- Players connect via VRising client  
- Admins connect via RCON or remote tools  
- VampireGuard orchestrates lifecycle, backups, and notifications  

---

## 2. Mermaid Architecture Diagram

```mermaid
flowchart TD
    subgraph Host["Hyper-V Host"]
        VG["VampireGuard Scripts<br/>(PowerShell Automation)"]
        HV["Hyper-V<br/>VRising VM"]
        NAT["VG-NAT Switch<br/>Internal vSwitch + NAT"]
    end

    subgraph VM["VRising VM (Guest OS)"]
        OS["Windows (Server/Pro)"]
        VR["VRising Dedicated Server"]
        WRM["WinRM HTTPS<br/>(Remote Management)"]
        RCON["RCON Endpoint"]
    end

    subgraph Players["Players / Admins"]
        P1["Players<br/>(VRising Clients)"]
        ADM["Admin<br/>(RCON, Remote Mgmt)"]
    end

    Internet["Internet / WAN"]
    Router["Router / Firewall"]

    VG -->|Start/Stop/Backup/Restore VM| HV
    VG -->|Invoke Remote Commands| WRM
    VG -->|Notifications / Status| ADM

    HV -->|vNIC| NAT
    NAT --> VM

    VR -->|UDP 9876/9877| NAT
    NAT --> Router
    Router --> Internet
    Internet --> P1

    ADM -->|RCON Client| RCON
    ADM -->|RDP/Other| OS
```

---

## 3. How to Use This Document

This file should be the first stop for new operators.
From here, proceed to:

- `/docs/guides/nat-switch-setup.md`
- `/docs/guides/vm-creation.md`
- `/docs/guides/restore-guide.md`
- `/docs/guides/validation-checklist.md`
- Script‑specific documentation under `/docs/scripts/`

This overview provides the conceptual map needed to understand how VampireGuard orchestrates the entire VRising server lifecycle.