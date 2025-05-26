#  Williams F1 Workstation Audit Suite

## Overview

This repository contains the full suite of **PowerShell-based discovery, compliance, and validation tools** developed by **Curtis-Davidson & Urbantek** for the **Williams F1 Technology Infrastructure environment**.

The goal of this project is to deliver **gold-standard workstation auditing**, **shared-to-individual account transitions**, and **real-time forensic validation** aligned with **ITIL**, **Cyber Essentials**, and **ISO 27001** best practices.

---

## 🔍 Purpose

The scripts in this repository are used to:

- Validate Windows workstation environments before and after change
- Transition ModelShop and engineering workstations from shared to named-user accounts
- Identify high-risk configurations (shared profiles, admin rights, etc.)
- Export real-time data on user accounts, mapped drives, profiles, login history, GPO bindings
- Automate compliance snapshotting via HTML/CSV reports

---

## 📁 Repository Structure

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
	•	❌ No system changes
	•	❌ No AD or GPO writes
	•	✅ All temp files logged and timestamped
	•	✅ Easily revertible — delete /Output and /logs


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




