# 📜 VampireGuard — Changelog  
All notable changes to this project will be documented in this file.  
This project adheres to **Semantic Versioning** and the **Keep a Changelog** format.

---

# [1.0.0] — 2025‑12‑30  
### 🎉 Initial Public Release  
This release represents the first fully documented, fully automated, production‑ready version of **VampireGuard**, including the complete script suite, architecture, runbooks, diagrams, and operator/player documentation.

---

## 🚀 Added

### **Documentation**
- Added **`notifications-and-rcon.md`**  
  - Full Discord webhook setup  
  - Full RCON configuration  
  - Security notes  
  - Testing instructions  
  - Integration with scripts 08 & 09  

- Added **`how-to-connect.md`**  
  - Player‑friendly connection guide  
  - Direct Connect instructions  
  - Troubleshooting steps  
  - Shareable for server owners  

- Added **`lessons-learned.md`**  
  - Exhaustive architectural insights  
  - Hyper‑V, WinRM, RCON, NAT, backups, hardening  
  - Automation philosophy  
  - Documentation philosophy  
  - Operator & player experience lessons  

- Added **GitHub Pages `_sidebar.md`**  
  - Full navigation tree  
  - Script‑aligned structure  
  - Clean operator/player separation  

### **Diagrams**
- Added **new high‑level architecture diagram** (Host ↔ VM subgraphs)  
- Added **backup lifecycle diagram**  
- Added **VM hardening flow diagram**  
- Added **WinRM trust chain diagram**  

### **README Enhancements**
- Added modern shields.io badges  
- Added project identity banner  
- Added summary bar  
- Added links to new docs  
- Added visuals section  

---

## 🛠️ Changed

### **architecture.md**
- Replaced old diagram with new subgraph‑based architecture diagram  
- Added integration references to new docs  
- Improved clarity and alignment with script sequence  

### **troubleshooting.md**
- Added direct links to notifications & RCON setup  
- Added player connection reference  
- Improved RCON and Discord troubleshooting sections  

### **runbook.md**
- Added cross‑links to notifications & RCON  
- Added player connection reference  
- Improved backup and validation sections  

### **README.md**
- Updated with new links  
- Updated visuals  
- Updated badges  
- Added player guide reference  
- Added notifications & RCON reference  

---

## 🧹 Improved

- Standardized cross‑linking across all docs  
- Ensured all operator workflows reference correct scripts  
- Ensured all player workflows reference correct guides  
- Improved consistency of headings, spacing, and formatting  
- Ensured all diagrams are GitHub‑friendly  
- Ensured all docs follow the canonical script sequence (01–09)  
- Improved repo clarity and onboarding experience  

---

## 🧩 Repository Structure

- `/docs` now contains:
  - Architecture  
  - Troubleshooting  
  - Runbook  
  - Quick Start  
  - Security  
  - Notifications & RCON  
  - How to Connect  
  - Lessons Learned  
  - Script documentation  
  - Diagrams  
  - Sidebar for GitHub Pages  

- `/scripts` contains the full 01–09 automation suite  

---

## 🔐 Security

- Reinforced documentation around:
  - WinRM HTTPS  
  - Certificate trust  
  - RCON password storage  
  - Firewall scoping  
  - VM hardening  

---

# [Unreleased]  
### Planned for future versions

- GitHub Pages landing page  
- Script dependency graph  
- NAT networking diagram  
- Dashboard for backup history  
- Optional metrics exporter  
- Optional scheduled maintenance tasks  

---

