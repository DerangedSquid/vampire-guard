# 🤝 Contributing to VampireGuard  
Thank you for your interest in contributing!  
VampireGuard is designed as a **deterministic, hardened, appliance‑style automation framework**, and contributions should follow the same philosophy.

This document explains how to contribute code, documentation, or improvements while maintaining the project’s standards.

---

# 1. Philosophy

VampireGuard is built on these principles:

- **Determinism** — scripts must behave predictably every time  
- **Idempotency** — scripts can be safely re‑run  
- **Security** — WinRM HTTPS, RCON lockdown, hardened VM  
- **Observability** — logs, notifications, and health checks  
- **Operator clarity** — no ambiguity, no hidden behavior  
- **Documentation as architecture** — every feature must be documented  

Contributions must align with these principles.

---

# 2. Repository Structure

```
/scripts/          # 01–09 automation scripts
/docs/             # Documentation suite
/docs/scripts/     # Script-specific documentation
/docs/diagrams/    # Mermaid diagrams
CHANGELOG.md       # Version history
README.md          # Project overview
```

Please follow this structure when adding new files.

---

# 3. How to Contribute

## 3.1 Reporting Issues
If you find a bug, inconsistency, or unclear documentation:

1. Open an Issue  
2. Include:
   - Steps to reproduce  
   - Expected behavior  
   - Actual behavior  
   - Logs or screenshots if relevant  

## 3.2 Submitting Pull Requests

### **Before submitting a PR:**
- Ensure your changes are tested  
- Ensure scripts remain idempotent  
- Ensure documentation is updated  
- Ensure diagrams remain accurate  
- Ensure cross‑links are added where needed  

### **PR Requirements**
- Clear title  
- Description of what changed and why  
- Reference to any related Issues  
- Updated docs if behavior changed  
- Updated CHANGELOG.md (under `[Unreleased]`)  

---

# 4. Coding Standards

## 4.1 PowerShell Scripts
Scripts must:

- Use **explicit parameter blocks**  
- Validate inputs  
- Use `Write-Verbose` for operator visibility  
- Use `Try/Catch` with meaningful error messages  
- Avoid global state  
- Avoid assumptions about environment  
- Be idempotent  
- Log actions clearly  

## 4.2 Documentation
Docs must:

- Use clean GitHub‑friendly Markdown  
- Include cross‑links to related docs  
- Follow the existing tone and structure  
- Include diagrams when appropriate  
- Avoid ambiguity  

---

# 5. Adding New Scripts

If adding a new script:

1. Follow the numbering convention (e.g., `10-NewFeature.ps1`)  
2. Add a documentation file in `/docs/scripts/10-newfeature.md`  
3. Update:
   - README  
   - Sidebar  
   - Architecture (if relevant)  
   - Runbook (if relevant)  
   - Troubleshooting (if relevant)  

---

# 6. Adding New Documentation

If adding a new doc:

1. Place it in `/docs/`  
2. Add it to `_sidebar.md`  
3. Cross‑link it from relevant pages  
4. Ensure it fits the documentation hierarchy  

---

# 7. Versioning

VampireGuard uses **Semantic Versioning**:

- **MAJOR** — breaking changes  
- **MINOR** — new features  
- **PATCH** — fixes  

All changes must be recorded in `CHANGELOG.md`.

---

# 8. Code of Conduct

Be respectful, constructive, and collaborative.  
We welcome contributions from all backgrounds and skill levels.

---

# 9. Getting Help

If you need guidance:

- Open an Issue  
- Start a Discussion  
- Review existing documentation  

We’re happy to help contributors understand the architecture and workflow.

---

# 10. Thank You

Your contributions help make VampireGuard more robust, more secure, and more accessible.  
Thank you for helping build a better automation framework for the VRising community.
