# VRising-WinRMSetup.ps1 — Integrated WinRM HTTPS + CredSSP Setup Script Reference

---

## 1. Purpose

`VRising-WinRMSetup.ps1` configures a secure, certificate-backed WinRM HTTPS channel with CredSSP and NTLM-only delegation between a Hyper-V host and the VRising VM. It is:

- Idempotent (safe to re-run)
- Deterministic (always produces a known-good state)
- Self-validating (tests connectivity and remoting)
- Explicit about failures

This script is a core part of the **VampireGuard** automation suite and is intended for production-grade, fully validated WinRM configuration.

---

## 2. Execution prerequisites

### Environment
- Must be run **inside the VRising VM** when using `-Role VM`
- Must be run **on the Hyper-V host** when using `-Role Host`
- Windows 10/11 or Windows Server
- PowerShell 5.1+

### Permissions
- Must be run as **Administrator** on both VM and host

### Network
- VM must have a **static IPv4 address**
- Host must be able to reach VM on:
  - TCP 5986 (WinRM HTTPS)
  - Any ports required for certificate transfer (local filesystem)

### Certificates
- VM generates a self-signed certificate for WinRM HTTPS
- VM exports the certificate to a shared path
- Host imports the certificate into LocalMachine\Root

### Execution policy
If needed:
- `Set-ExecutionPolicy Bypass -Scope Process`

### Required parameters
- `-Role <VM|Host|Both>`
- `-VmIp <IPv4>`
- `-CertCN <string>`
- Optional:
  - `-CertExportPath`
  - `-CredPath`

---

## 3. High‑level workflow

1. Determine execution role (VM, Host, or Both)
2. VM-side:
   - Ensure network profile is Private
   - Ensure firewall rule for WinRM HTTPS
   - Create or reuse self-signed certificate
   - Trust certificate locally
   - Remove all existing WinRM listeners
   - Create new HTTPS listener
   - Restart WinRM
   - Export certificate for host
3. Host-side:
   - Import VM certificate
   - Enable CredSSP client/server
   - Add VM IP to TrustedHosts
   - Test WinRM HTTPS connectivity
   - Test PSRemoting using stored credentials
4. Display completion status

---

## 4. Detailed execution flow

### 4.1 Logging helpers

Defines:

- `Write-Info` — informational messages  
- `Write-Ok` — success messages  
- `Write-Warn` — warnings  
- `Write-Err` — failure messages  

These provide consistent, color-coded output for all operations.

---

### 4.2 VM-side workflow

#### Set-VmNetworkProfilePrivate
- Ensures all network profiles are set to **Private**
- Updates profiles if necessary

#### Ensure-VmFirewallForWinRMHttps
- Ensures inbound TCP 5986 is allowed
- Creates or enables firewall rule `WinRM-HTTPS-VRising`

#### Ensure-VmCertificateAndListener
- Searches for existing certificate matching `CN=<CertCN>`
- Creates a new self-signed certificate if none exists
- Ensures certificate is trusted in LocalMachine\Root
- Removes **all** existing WinRM listeners
- Creates a new HTTPS listener bound to the certificate
- Restarts WinRM service
- Exports certificate to `CertExportPath`

---

### 4.3 Host-side workflow

#### Import-HostCertificate
- Imports VM’s exported certificate into LocalMachine\Root
- Validates certificate file exists

#### Configure-HostCredSSP
- Enables CredSSP client delegation to the VM
- Enables CredSSP server role

#### Configure-HostTrustedHosts
- Adds VM IP to TrustedHosts if not already present

#### Test-HostWinRM
- Tests WinRM HTTPS connectivity using:
  - `Test-WSMan -UseSSL`

#### Test-HostPSRemoting
- Imports credential from `CredPath`
- Attempts remote command execution:
  - `Invoke-Command -UseSSL -Credential $cred`

---

### 4.4 Execution logic

- Script prints startup banner with selected role
- Switch block executes:
  - VM workflow
  - Host workflow
  - Or warns when using `Both`
- Prints completion banner

---

## 5. Usage pattern and intent

This script is intended for:

- **Production-grade WinRM configuration** between Hyper-V host and VRising VM  
- **Secure remoting** using HTTPS + CredSSP  
- **Automated workflows** that require:
  - Remote command execution
  - File transfers
  - Lifecycle management (VampireGuard)

It is designed to be:

- **Idempotent** — safe to re-run after VM rebuilds  
- **Deterministic** — produces the same validated configuration every time  
- **Self-testing** — verifies connectivity and remoting  

---

## 6. Limitations and assumptions

- Requires **static IPv4** for the VM  
- Assumes certificate export path is reachable by both VM and host  
- Does not manage:
  - Certificate rotation  
  - Certificate cleanup  
  - Firewall hardening beyond WinRM HTTPS  
- Assumes CredSSP is acceptable for your security model  
- Assumes NTLM-only delegation is sufficient  
- `-Role Both` does **not** run both sides automatically — it is informational only  

---

## 7. Potential future enhancements

- Automated certificate rotation and cleanup  
- Hardened firewall profiles  
- Optional Kerberos-based remoting  
- Automatic host/VM pairing  
- Logging to file instead of console-only  
- Enhanced validation (port checks, listener enumeration, certificate expiry warnings)  
- Optional non-interactive mode for CI/CD pipelines  
