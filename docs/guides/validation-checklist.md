# VampireGuard Validation Checklist

Use this checklist after initial setup, significant changes, or a restore to confirm your environment is healthy.

---

## 1. Host and Hyper‑V

- Hyper‑V role is installed and running  
- VRising VM (e.g., VG-VRising-01) appears in Hyper‑V Manager  
- Host has enough free RAM, CPU, and disk for VM + backups  

---

## 2. NAT Switch and Mappings

- VMSwitch **VG-NAT** exists and is **Internal**  
- Host vNIC **vEthernet (VG-NAT)** has gateway IP (e.g., 192.168.200.1/24)  
- NAT object **VG-NAT-Network** exists with correct subnet (e.g., 192.168.200.0/24)  
- Static mappings exist for VRising ports **9876/9877 UDP** to VM IP  

---

## 3. VM Networking

- VM is attached to **VG-NAT**  
- VM has correct static IP (e.g., 192.168.200.10)  
- VM can reach the internet (Test-NetConnection to google.com:443)  
- Host can reach VM (Test-NetConnection to port 5986 after WinRM setup)  

---

## 4. WinRM HTTPS

- HTTPS listener exists inside VM on port **5986**  
- VM firewall allows inbound **5986**  
- Host → VM WinRM test command succeeds  

---

## 5. VRising Server

- VRising server files exist (e.g., E:\Games\VRisingServer)  
- SteamCMD runs successfully and can update the server  
- Manual run of **VRisingServer.exe** starts without crash  
- Logs show server listening on expected ports  

---

## 6. RCON

- RCON enabled in VRising config  
- RCON port reachable from host or LAN admin machine  
- RCON test command (list players, broadcast, etc.) succeeds  

---

## 7. VampireGuard Automation

- VampireGuard config points to correct VM name, IP, and paths  
- Start/stop/restart flows succeed  
- Backup/export workflow completes successfully  
- Backup disk usage is within expected limits  

---

## 8. Player Connectivity

- LAN clients can connect via host LAN IP + port 9876  
- External clients can connect via public IP + forwarded UDP ports  
- Server remains stable under typical load  

---

## 9. Post‑Restore Checks

- Player characters, bases, and progression intact  
- Scheduled tasks or automation entries still valid  
- Notifications (Discord, etc.) still functioning  

If all sections pass, your VampireGuard environment is healthy and production‑ready.
