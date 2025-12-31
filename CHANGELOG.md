# 📜 VampireGuard — Changelog  
All notable changes to this project are documented here.  
This project adheres to **Semantic Versioning** and the **Keep a Changelog** format.

---

# [1.0.1] — 2025‑12‑31  
### 🔧 Documentation, Guides, and Consistency Update  
This release captures all improvements, additions, and structural fixes made between **2025‑12‑28** and **2025‑12‑31**.

---

## 🚀 Added

### **New Guides**
- Added vm-setup.md  
  - SteamCMD installation  
  - VRising server installation  
  - Directory structure  
  - Config preparation  
  - Validation steps  

- Added virtualization-check.md  
  - BIOS/UEFI virtualization requirements  
  - SLAT verification  
  - Hyper‑V capability checks  
  - Troubleshooting virtualization failures  

### **Documentation Enhancements**
- Added missing cross‑links in Operator Journey  
- Added guide references for VM Setup, NAT, Restore, Validation  
- Added new guide entries to /docs/guides/  
- Added missing links to README and sidebar  
- Added new documentation landing page (index.md)  
- Added FAQ skeleton to eliminate sidebar dead link  

### **Script Documentation**
- Updated all script docs (01–09) for consistency  
- Ensured each script has a dedicated documentation page  
- Added missing links to Master Script Index  

---

## 🛠️ Changed

### **Operator Journey**
- Updated sequencing  
- Added references to new guides  
- Ensured all referenced files exist  
- Improved clarity and flow  

### **README.md**
- Updated script ordering to match canonical sequence  
- Added missing guide references  
- Improved documentation map  
- Updated visuals and badges  

### **Sidebar**
- Added new guides  
- Ensured navigation matches repo structure  
- Removed dead links  

### **Master Script Index**
- Updated cross‑links  
- Ensured consistency with Operator Journey  
- Added missing script references  

### **Architecture Docs**
- Updated diagrams  
- Improved clarity  
- Added references to new guides  

---

## 🧹 Improved

- Eliminated all remaining documentation rabbit holes  
- Ensured all guides referenced in Quickstart and Operator Journey exist  
- Standardized link paths across all docs  
- Improved consistency of headings, spacing, and formatting  
- Ensured deterministic navigation across the entire documentation suite  
- Cleaned up CHANGELOG.md logical inconsistencies  
- Consolidated duplicate 1.0.0 entries  
- Added proper 1.0.1 release section  

---

## 🔐 Security

- Improved documentation around:
  - WinRM HTTPS  
  - Certificate trust  
  - RCON password storage  
  - Firewall scoping  
  - VM hardening  
- Added virtualization requirements to prevent Hyper‑V misconfiguration  

---

# [1.0.0] — 2025‑12‑30  
### 🎉 Initial Public Release  
This release represents the first fully documented, fully automated, production‑ready version of VampireGuard.

---

## 🚀 Added

### **Documentation**
- notifications-and-rcon.md  
- how-to-connect.md  
- lessons-learned.md  
- GitHub Pages _sidebar.md  

### **Diagrams**
- High‑level architecture diagram  
- Backup lifecycle diagram  
- VM hardening flow diagram  
- WinRM trust chain diagram  

### **README Enhancements**
- Badges, banner, summary bar, visuals, and links  

---

## 🛠️ Changed
- Updated architecture, troubleshooting, runbook, and README  
- Improved clarity, cross‑links, and script alignment  

---

## 🧹 Improved
- Standardized cross‑linking  
- Ensured canonical script sequence  
- Improved repo clarity and onboarding  

---

## 🧩 Repository Structure
- /docs contains full documentation suite  
- /scripts contains complete 01–09 automation suite  

---

## 🔐 Security
- Reinforced WinRM HTTPS, certificate trust, RCON security, firewall scoping, and VM hardening  

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
