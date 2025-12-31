# 🧛‍♂️ VampireGuard Documentation  
### Hyper‑V Automation Suite for VRising Dedicated Servers

Welcome to the VampireGuard documentation hub.  
This site provides a complete, structured reference for deploying, operating, and maintaining a fully automated VRising server on Microsoft Hyper‑V.

If you're new here, start with the **Master Operator Journey** — the canonical, end‑to‑end deployment guide.

---

## 🚀 Start Here

### **Master Operator Journey**  
The complete lifecycle: VM → NAT → WinRM → Hardening → VRising → Backups → Validation → Restore  
👉 [00‑operator‑journey.md](00-operator-journey.md)

### **Quick Start Guide**  
A 10‑minute overview of the setup process  
👉 [quickstart.md](quickstart.md)

---

## 🏗️ Architecture & Concepts

- [Solution Overview](solution-overview.md)  
- [Architecture](architecture.md)  
- [Security Architecture](security.md)  
- [Lessons Learned](lessons-learned.md)

---

## 🛠️ Core Automation Scripts

Full script documentation lives in:  
👉 [`scripts/Master-Index.md`](scripts/Master-Index.md)

Scripts are organized into three phases:

### **Phase 1 — Host Preparation**
- VM configuration  
- WinRM HTTPS setup  
- Certificate trust  
- VM startup  

### **Phase 2 — VM Preparation**
- VRising installation  
- Hardening  
- WinRM quick setup  
- Server service installation  

### **Phase 3 — Operations**
- Backup engine  
- RCON shutdown  
- Export lifecycle  

---

## 📚 Guides

- VM Creation  
- NAT Switch Setup  
- VRising Installation  
- Restore Guide  
- Validation Checklist  
- Notifications & RCON  
- How to Connect (Player Guide)

All guides are located in:  
👉 [`guides/`](guides/)

---

## 🧰 Operations

- [Troubleshooting Guide](troubleshooting.md)  
- [Operations Runbook](runbook.md)

---

## ❓ FAQ

Common questions and operational clarifications:  
👉 [faq.md](faq.md)

---

## 📦 Project Repository

Source code, scripts, and documentation:  
https://github.com/DerangedSquid/vampire-guard

---
