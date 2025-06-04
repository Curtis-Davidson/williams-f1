# 📦 Canonical Makefile Index – Williams F1 Automation Suite

This document describes all supported `make.ps1` targets for departmental auditing, environment insight, and compliance tracking. Run from `/scripts`.

---

##  Basic Targets

| Target           | Description |
|------------------|-------------|
| `workstation`    | Runs full audit against current workstation – applications, profiles, GPOs, mapped drives. |
| `shareduser`     | Runs AD user audit (group memberships, login details, ACLs, FSLogix, etc). |
| `group`          | Prompts for AD group name and runs deep insight extraction – members, ACLs, changes. |
| `all`            | Runs all audits sequentially (`workstation`, `shareduser`, `group`). |

---

##  Verification Targets

| Target           | Description |
|------------------|-------------|
| `verify`         | Checks if snapshot diffs (`diff_summary.md`) exist – confirms audit change tracking is working. |
| `verify-env`     | Runs full environment readiness check (RSAT, modules, permissions). |

---

##  Export & Versioning

| Target           | Description |
|------------------|-------------|
| `export-md`      | Lists all Markdown reports generated across audit exports. |
| `push`           | Auto-commits changes to Git, creates a dated tag, and pushes to remote origin. Useful for backup, compliance, or CI workflows. |

---

##  Examples

```powershell
# Check if audit diffs are being generated:
.\make.ps1 verify

# Run group audit and auto-export report:
.\make.ps1 group

# Commit and tag snapshot updates:
.\make.ps1 push

Folder Structure
	•	/scripts/make.ps1 – main runner
	•	/exports/<type>/<group>/ – audit JSONs, Markdown, HTML
	•	/docs/Make.md – this reference file
	•	/scripts/Test-EnvironmentReadiness.ps1 – dependency checker
	
	Notes
	•	Git tagging format: snapshot-YYYYMMDD-HHMM
	•	Markdown diff files: diff_summary.md
	•	HTML reports: report_<timestamp>.html
	•	Markdown summaries: report_<timestamp>.md

⸻

Last Updated: $(Get-Date -Format "yyyy-MM-dd")
By: Paul R Davidson @ Urbantek


---

Would you like:
- A `make doc` target to print or cat this from the CLI?
- Slack auto-alerts on `make push`?

Next move is yours.

Path: /README.md
Purpose: Usage instructions and overview of the make.ps1 system and audit tooling.

#  Williams F1 | Intelligent Audit Suite

A canonical PowerShell automation toolkit for Active Directory, Workstation, and Group auditing — complete with diffing, snapshot export, ACL detection, FSLogix state, and Markdown/HTML reporting.

---

##  How to Use

You run the audit system from the `/scripts` directory using `make.ps1`, like so:

```powershell
cd /scripts
.\make.ps1 <target>

Replace <target> with any of the supported commands (see below).


Prerequisites

Before using, ensure the following dependencies are met:
	•	 Windows PowerShell 5.1+
	•	 RSAT: Active Directory Tools (for Get-ADGroup, Get-ADUser, etc)
	•	 ActiveDirectory Module Loaded (Import-Module ActiveDirectory)
	•	 Permissions to query AD, GPO, FSLogix registry, and ACL paths
	•	 Git (if using make push for versioning)

Run the following to confirm:

.\make.ps1 verify-env



# Audit the current workstation
.\make.ps1 workstation

# Audit a specific AD group
.\make.ps1 group

# Check audit environment is healthy
.\make.ps1 verify-env

# Push all snapshots to Git (requires Git configured)
.\make.ps1 push


File Outputs

Exports are stored in /exports/<group_or_machine_name>/ and include:
	•	snapshot_<timestamp>.json – Full snapshot of state
	•	diff_summary.md – Markdown diff between runs
	•	report_<timestamp>.md – Markdown summary
	•	report_<timestamp>.html – HTML full report

⸻

 Designed For
	•	Department-level audits (IT, SecOps, GRC, IAM)
	•	Workstation intelligence and compliance
	•	Active Directory group analysis
	•	FSLogix and GPO visibility
	•	Git-based historical snapshots
	
	
	##  Available Targets

| **Target**      | **Description**                                                                  |
|------------------|---------------------------------------------------------------------------------|
| `workstation`    | Full machine audit (apps, drives, GPOs, FSLogix, etc)                           |
| `shareduser`     | Active Directory audit of user/group info                                       |
| `group`          | Interactive deep audit of AD group incl. ACLs, members, diffing                 |
| `all`            | Runs all audit modules in sequence                                              |
| `verify`         | Confirms if change diffs were captured since last run                           |
| `verify-env`     | Checks PowerShell environment readiness and modules                             |
| `export-md`      | Lists all Markdown summaries for review/export                                  |
| `push`           | Git auto-commit of snapshots and diffs with tag                                 |















ADGroupDiscovery.ps1 — What It Does

Tracks Active Directory group data with full export and change tracking:
•	Group metadata (name, description, type, scope)
•	All resolved members (recursive expansion)
•	ACLs on the group object
•	Markdown + HTML reports
•	JSON snapshot cache + diff detection
•	Optional future use in Jupyter post-analysis


Rule 6 Instruction Set for ADGroupDiscovery.ps1


1. Exact Command
.\ADGroupDiscovery.ps1 -GroupName "Finance-UK"


2. Full File Path
/scripts/ADGroupDiscovery.ps1

3. Directory Creation (if needed)
New-Item -Path "../exports/<GroupName>" -ItemType Directory -Force

4. File Creation/Edit Command
   code /scripts/ADGroupDiscovery.ps1


5. Then verify:
•	Markdown: ..\exports\Finance-UK\group_report_<timestamp>.md
•	HTML: ..\exports\Finance-UK\group_report_<timestamp>.html
•	Diff (if any): ..\exports\Finance-UK\diff_summary.md
•	Snapshot: ..\exports\Finance-UK\group_snapshot_<timestamp>.json

