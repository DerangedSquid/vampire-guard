# 🧠 VampireGuard — Lessons Learned  
### Architectural insights, operational discoveries, and hard‑won knowledge from building a fully automated VRising server appliance

VampireGuard was not built in a straight line.  
It evolved through experimentation, failures, redesigns, and deep architectural analysis.  
This document captures the lessons learned across the entire project — technical, operational, architectural, and philosophical.

It exists to help future contributors, operators, and maintainers understand *why* VampireGuard is designed the way it is.

---

# 1. Hyper‑V & VM Architecture Lessons

## 1.1 Hyper‑V NAT Is Powerful but Unforgiving
- NAT switches work flawlessly **only** when IPs, ports, and firewall rules are deterministic.  
- Dynamic addressing breaks WinRM, RCON, and game ports.  
- NAT port mappings must be explicitly defined and validated.

## 1.2 Checkpoints Are Dangerous for Game Servers
- Checkpoints corrupt VRising worlds when rolled back.  
- They must be disabled at the VM level and enforced by automation.  
- Backups must be **exports**, not checkpoints.

## 1.3 VM Startup State Must Be Verified
- Hyper‑V sometimes reports “Running” even when the guest OS is stuck.  
- WinRM and RCON are the only reliable indicators of VM health.

## 1.4 VM Rebuilds Should Be Cheap
- Treat the VM as disposable.  
- Backups must be atomic, self‑contained, and restorable without manual intervention.  
- This philosophy drove the sealed‑appliance model.

---

# 2. WinRM Lessons

## 2.1 WinRM HTTPS Is Mandatory
HTTP WinRM is:
- insecure  
- unreliable  
- blocked by many networks  
- incompatible with sealed‑appliance security  

HTTPS with a pinned certificate is the only correct approach.

## 2.2 Certificate Trust Is the #1 Failure Mode
Most WinRM failures came from:
- wrong CN  
- wrong certificate store  
- missing trust on the host  
- mismatched thumbprints  
- firewall rules not scoped correctly  

This led to:
- Script 02 (WinRM Setup)  
- Script 03 (WinRM Trust)  
- Script 07 (VM Quick Setup)  

## 2.3 WinRM Must Be Tested Before Every Operation
A single `Test-WSMan -UseSSL` prevents entire classes of failures.

---

# 3. RCON Lessons

## 3.1 RCON Is the Only Safe Way to Stop VRising
Stopping the VM without RCON:
- corrupts saves  
- causes world rollback  
- breaks player progress  

RCON became a **first‑class citizen** in the architecture.

## 3.2 RCON Must Be Secured
- Strong password  
- Host‑only firewall rule  
- Never exposed publicly  
- Never logged  

## 3.3 RCON Is a Health Indicator
If RCON doesn’t respond:
- the server is hung  
- the VM may be degraded  
- backups must not proceed  

---

# 4. Backup Architecture Lessons

## 4.1 Hyper‑V Export Is the Only Reliable Backup Method
File‑level backups are:
- incomplete  
- inconsistent  
- unsafe during writes  

Hyper‑V export is atomic and self‑contained.

## 4.2 Backups Must Be Graceful
The sequence must be:

1. RCON shutdown  
2. Verify server stopped  
3. VM shutdown  
4. Export  
5. Restart VM  
6. Restart VRising service  
7. Health check  

Any deviation risks corruption.

## 4.3 Backups Must Be Observable
Operators need:
- Discord notifications  
- History logs  
- Clear success/failure states  

Silent backups are dangerous.

---

# 5. VM Hardening Lessons

## 5.1 The VM Must Be Treated as an Appliance
This means:
- no RDP  
- no SMB  
- no unnecessary services  
- no interactive administration  

Everything flows through WinRM or RCON.

## 5.2 Firewall Rules Must Be Explicit
Implicit rules cause:
- intermittent failures  
- inconsistent behavior  
- debugging nightmares  

Explicit inbound rules:
- 5986 (WinRM HTTPS)  
- RCON port  
- Game port  

Everything else is blocked.

## 5.3 Defender Must Be Tuned
VRising writes constantly.  
Defender exclusions prevent:
- performance issues  
- false positives  
- file locking  

---

# 6. Automation Lessons

## 6.1 Scripts Must Be Idempotent
Operators re‑run scripts constantly.  
Idempotency prevents:
- duplicate services  
- duplicate firewall rules  
- broken listeners  
- inconsistent state  

## 6.2 Scripts Must Validate Before Acting
Every script now:
- checks prerequisites  
- validates environment  
- confirms state  
- logs actions  

This prevents cascading failures.

## 6.3 Deterministic Ordering Matters
The final script sequence (01–09) emerged from trial and error.  
Running scripts out of order caused:
- broken trust chains  
- missing listeners  
- failed backups  
- inconsistent VM state  

The numbering system solved this.

---

# 7. Observability Lessons

## 7.1 Discord Notifications Are Essential
Operators need:
- backup start  
- backup success  
- backup failure  
- shutdown/startup events  

Without notifications, failures go unnoticed.

## 7.2 Logs Must Be Structured
Human‑readable logs are not enough.  
Structured logs allow:
- dashboards  
- history tracking  
- automated analysis  

## 7.3 Health Checks Must Be Explicit
Implicit health checks (e.g., “VM is running”) are misleading.  
Explicit checks:
- WinRM  
- RCON  
- VRising service  
- Disk space  
- Backup directory  

These became part of the runbook.

---

# 8. Documentation Lessons

## 8.1 Documentation Is Part of the Architecture
The system is only as good as its onboarding.  
We learned that:
- operators need sequencing  
- players need simplicity  
- contributors need clarity  

## 8.2 Cross‑Linking Prevents Dead Ends
Every doc must link to:
- notifications-and-rcon  
- how-to-connect  
- troubleshooting  
- runbook  
- architecture  

This prevents user confusion.

## 8.3 Markdown Must Be Clean and GitHub‑Friendly
- No broken links  
- No ambiguous headings  
- No inconsistent formatting  

This led to the final documentation suite.

---

# 9. Networking Lessons

## 9.1 NAT Requires Explicit Port Mappings
VRising uses:
- UDP 9876  
- UDP 9877  
- RCON TCP  
- WinRM TCP 5986  

All must be mapped explicitly.

## 9.2 Static IPs Are Mandatory
DHCP breaks:
- WinRM  
- NAT  
- RCON  
- Game ports  

Static addressing is non‑negotiable.

## 9.3 Host Firewall Must Be Considered
Even when VM rules are correct, host rules can block traffic.

---

# 10. Repo & Code Lessons

## 10.1 Script Naming Must Be Semantic
The 01–09 numbering system:
- enforces order  
- improves onboarding  
- clarifies dependencies  

## 10.2 Repo Structure Must Be Predictable
- `/scripts`  
- `/docs`  
- `/docs/scripts`  
- `/docs/diagrams`  

Predictability reduces cognitive load.

## 10.3 Documentation Is a First‑Class Artifact
Not an afterthought.

---

# 11. Player Experience Lessons

## 11.1 Players Need a Simple Connection Guide
Operators shouldn’t have to explain:
- IP  
- Port  
- Password  
- Direct Connect  

The `how-to-connect.md` file solves this.

## 11.2 Backups Should Be Invisible to Players
Backups should:
- be fast  
- be graceful  
- not interrupt gameplay  

This shaped the backup architecture.

---

# 12. Philosophy Lessons

## 12.1 Treat the VM as Disposable
If rebuilds are cheap, failures are cheap.

## 12.2 Automation Should Inspire Confidence
Operators should trust the system, not fear it.

## 12.3 Observability Is Non‑Negotiable
A system you can’t see is a system you can’t trust.

## 12.4 Determinism Beats Cleverness
Predictable > fancy  
Repeatable > magical  
Explicit > implicit  

---

# 13. Summary

VampireGuard is the result of:

- architectural rigor  
- operational discipline  
- security‑first design  
- automation‑driven philosophy  
- deep troubleshooting  
- iterative refinement  
- real‑world testing  

These lessons ensure the system is:

- hardened  
- observable  
- deterministic  
- operator‑friendly  
- player‑friendly  
- future‑proof  

VampireGuard is more than a VRising server —  
it’s a model for how to build sealed, automated, self‑maintaining game server appliances.

---
