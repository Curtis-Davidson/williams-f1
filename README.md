#  Williams F1 Workstation Audit Suite

## Overview

This repository contains the full suite of **PowerShell-based discovery, compliance, and validation tools** developed by **Curtis-Davidson & Urbantek** for the **Williams F1 Technology Infrastructure environment**.

The goal of this project is to deliver **gold-standard workstation auditing**, **shared-to-individual account transitions**, and **real-time forensic validation** aligned with **ITIL**, **Cyber Essentials**, and **ISO 27001** best practices.

---

##  Purpose

The scripts in this repository are used to:

- Validate Windows workstation environments before and after change
- Transition ModelShop and engineering workstations from shared to named-user accounts
- Identify high-risk configurations (shared profiles, admin rights, etc.)
- Export real-time data on user accounts, mapped drives, profiles, login history, GPO bindings
- Automate compliance snapshotting via HTML/CSV reports

---

##  Key Advantages Over Lansweeper

| **Feature**                        | **Lansweeper**    | **AuditScripts**             |
|------------------------------------|-------------------|------------------------------|
| Real-time execution                | ❌ Static only    | ✅ Live and traceable         |
| Deep profile analysis              | ❌ Not supported  | ✅ Full `AppData` + SID       |
| Logon event (4624) parsing         | ❌ Not captured   | ✅ Granular audit             |
| GPO rights validation              | ❌ Complex config | ✅ `secedit` + parsing        |
| Shared-to-user migration support   | ❌ Unsupported    | ✅ Profile-preserving         |
| Custom output (CSV/HTML)           | ❌ Vendor-locked  | ✅ Controlled formats         |
| GitOps versioned, auditable code   | ❌ GUI-limited    | ✅ CI-ready, script-tracked   |

---

##  Repository Structure

/requirements
└── workstation-requirements.ps1     # Preflight checks for admin rights, policy, modules
└── logon-requirements.ps1           # Preflight for logon audit compatibility

/lib
└── workstation-core.ps1             # Core reusable discovery functions (modular)

/scripts
└── williamsf1-workstation-audit.ps1 # Main audit orchestration script

/Security
└── Get-LogonAuditReport.ps1         # 30-day logon success audit (event 4624)

/Output
└── *.csv / *.html                   # Exported audit reports

/logs
└── *.log                            # Timestamped script execution logs

/Makefile.ps1                          # Optional: master runner for CI/test/dev use


---

##  Key Features

-  **Admin Rights & Execution Policy Check**
-  **Module Auto-Installer (`ImportExcel`, `LocalAccounts`, etc.)**
-  **Rich Profile Discovery (`LastUse`, `IsLoaded`, `Roaming`, `SID`)**
-  **Mapped Drive + Installed Application Listings**
-  **User Rights Assignment via `secedit`**
-  **Logon History Auditing (Event ID 4624) with type mapping**
-  **HTML + CSV Reporting Output**
-  **Emoji/Colour-Coded Summary Tables**
-  **Enterprise-Ready Logging with Timestamping**
-  **Fully GitOps-Aligned & CI Safe**

---


##  Usage Instructions

###  Preflight Requirements Check

```powershell
.\requirements\workstation-requirements.ps1
.\requirements\logon-requirements.ps1

.\scripts\williamsf1-workstation-audit.ps1
Logon Activity Report

Output saved to:

/Output/LogonAuditReport_yyyyMMdd_HHmm.csv
/Output/LogonAuditReport_yyyyMMdd_HHmm.html

Audit Targets

This repo is validated against:
	•	Windows 10/11 Pro + Enterprise
	•	Domain-joined and local-only machines
	•	ModelShop engineering systems
	•	Virtual and physical workstations

Risk Mitigation & Rollback

All scripts are read-only unless writing logs or reports.
	•	 No system changes
	•	 No AD or GPO writes
	•	 All temp files logged and timestamped
	•	 Easily revertible — delete /Output and /logs


Best Practices
	•	Pull latest before running: git pull origin main
	•	Always run PowerShell as Administrator
	•	Use consistent log naming: hostname_timestamp.log
	•	Store exports to \\fileserver\AuditBackups\


Git Commit Policy

All commits must follow format:

feat(scope): description

• Summary bullet list (if multiple changes)
• Gold-standard audit trace
Author: Curtis-Davidson & Urbantek



-----------------------------------------------------

#  Williams F1 Workstation + Shared User Audit Framework

## Overview

This repository contains the **comprehensive auditing, compliance, and workstation validation scripts** developed by **Curtis-Davidson & Urbantek** for the **Williams F1 Technology Infrastructure**.

It is purpose-built for:
- **Audit discovery across Windows workstations**
- **Live user session logging**
- **Profile integrity verification**
- **Shared-to-individual account migrations (ModelShop)**
- **GPO and security rights validation**

This tooling is aligned to **ITIL**, **Cyber Essentials**, and **ISO 27001** and is designed for controlled execution across critical engineering systems with zero risk to data or workstation function.

---

##  Project Goals

- Identify and reduce shared account risk (ModelShop & high-risk groups)
- Safely transition to named-user accounts without corrupting profiles
- Maintain license, config, and CAD software functionality post-migration
- Build GitOps-aligned audit framework for workstation integrity

---

##  Repo Structure

/requirements/
├── workstation-requirements.ps1   # Validates environment before any script runs
├── logon-requirements.ps1         # Ensures logon auditing support is active

/lib/
└── workstation-core.ps1           # Core modular PowerShell functions

/scripts/
└── williamsf1-workstation-audit.ps1   # Orchestrates full audit logic (apps, drives, users)

Security/
└── Get-LogonAuditReport.ps1       # Event ID 4624 logon success audit, 30-day window

/logs/
└── *.log                          # All execution logs saved here

/Output/
└── *.html / *.csv                # All report exports saved here


--------------

---

##  Usage Instructions

###  1. Run Environment Check (Admin Required)

```powershell
.\requirements\workstation-requirements.ps1
.\requirements\logon-requirements.ps1

2. Run Core Workstation Audit

.\scripts\williamsf1-workstation-audit.ps1


3. Run Logon Event Audit (30 Days)

.\Security\Get-LogonAuditReport.ps1

Outputs:
	•	/Output/LogonAuditReport_yyyyMMdd_HHmm.csv
	•	/Output/LogonAuditReport_yyyyMMdd_HHmm.html


ModelShop Shared User Migration

This repo supports safe transition from shared accounts (e.g. WorkshopUser) to individual domain users.

What’s Audited Before Change:
	•	User SID and profile path mapping
	•	AppData, NTUSER.DAT, installed apps
	•	CAD software bindings (SolidWorks, MeshLab, etc.)
	•	Mapped drives and printers
	•	secedit export of user rights
	•	Event log presence of shared logins (4624 analysis)

Migration Methodology:
	•	Backup profile folder and registry
	•	Create new domain user accounts (individual + shared group)
	•	Use Profwiz or direct SID mapping in registry for migration
	•	Verify licensing and user config post-login
	•	Document profile state before/after change
	•	Rollback by reassociating original profile key if needed



Pre-Migration Safety Commands:

robocopy "C:\Users\WorkshopUser" "\\fileserver\backups\ModelShop" /MIR /XJ
reg export "HKCU" "\\fileserver\backups\ModelShop\ntuser-backup.reg"






What This Framework Ensures
	•	No profile corruption during testing
	•	Fully logged, exportable reports (CSV/HTML)
	•	Separation of discovery logic from user config
	•	Customisable to any OU / GPO / workstation type
	•	Auditable change trail for every executed action

⸻

 Rollback Plan

All scripts are read-only by design. If a profile migration fails:
	•	Restore C:\Users\WorkshopUser from backup
	•	Reassign registry SID under: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList

	Restore exported registry keys
	•	Reboot workstation and confirm session state


Recommended Execution Sequence

# 1. Precheck
.\requirements\workstation-requirements.ps1

# 2. Profile / Rights Audit
.\scripts\williamsf1-workstation-audit.ps1

# 3. Logon Forensics
.\Security\Get-LogonAuditReport.ps1

# 4. Export reports
Open /Output/*.html



----------------

Security & Logging
	•	All logs are stored under /logs/
	•	All output is timestamped
	•	All scripts log to file + stdout
	•	Zero destructive actions, all read operations



--------------

Git Commit Format


feat(scope): describe feature or fix

• Bullet-style summary of change
• Always sign off: Curtis-Davidson & Urbantek

Author & Maintainer

Curtis-Davidson
Lead Dev Infrastructure Audit Architect
paul@urbantek.com


Status

Production Ready — Live on Williams F1 infrastructure

License

Private repository under Urbantek.
Do not redistribute or replicate without express permission.










