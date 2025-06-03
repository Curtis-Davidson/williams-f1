## 1. Overview

### Purpose

Enterprise-grade Active Directory user audit tool that:

- Performs security compliance checks
- Generates comprehensive user profiles
- Supports change tracking and risk assessment
- Enables automated security reviews

### Core Features

1. **AD Profile Analysis**
    - Full attribute scanning
    - Security context evaluation
    - Profile path verification
    - FSLogix integration

2. **Security Assessment**
    - Group membership audit
    - GPO inheritance mapping
    - ACL permission analysis

3. **Reporting System**
    - Multi-format export (JSON/CSV/MD/HTML)
    - Delta comparison
    - Audit logging
    - Historical tracking

## 2. Technical Implementation ##

The script `ADUserDiscovery.ps1` is a class-based PowerShell tool that performs a full audit of an individual Active Directory user account. It is designed to run in **read-only mode** with no modification to AD objects.
##  Example Output Location

By default, all outputs are written to:

```
../exports/<Username>/
```

> Example: `../exports/FinanceUser01/`

| File                               | Description                                               |
|------------------------------------|-----------------------------------------------------------|
| `ad_user_summary_<timestamp>.json` | Full user object export (groups, GPOs, ACLs, metadata)    |
| `ad_user_summary_<timestamp>.csv`  | Flat summary for reporting and audit ingestion            |
| `ad_user_summary_<timestamp>.md`   | Markdown report for CAB or engineer review                |
| `ad_user_summary_<timestamp>.html` | Styled browser report                                     |
| `diff_summary.md`                  | Change report vs last snapshot (group, GPO, ACL, OU)      |
| `log_<timestamp>.txt`              | Execution log with INFO/WARN/SUCCESS entries              |
| `meta_<timestamp>.json`            | Metadata for audit (invoker, timestamp, repo, ref)        |
| `last_snapshot.json`               | Used for comparison in future runs (stateful diffing)     |


##  Why This Script Is Safe in Production

|  Characteristic                   | Explanation                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------|
| **Read-only**                     | Uses `Get-ADUser`, `Get-ADGroup`, `Get-GPInheritance`, `Get-Acl`. No `Set-`, `New-`, `Remove-` used. |
| **No Side Effects**               | Does not create, modify, move or delete any AD object. Purely observational. |
| **Fails gracefully**              | If a user does not exist or is inaccessible, script exits cleanly with a warning. |
| **Handles ACL errors**            | If ACLs cannot be retrieved due to permissions, logs a warning and proceeds. |
| **No impact to shares or servers** | Only outputs files to `../exports/<Username>/` directory. No UNC paths touched. |
| **No elevated AD rights needed**  | Can be run with Domain User privileges (read access to AD + ACLs only).     |
###  Key Technical Details

- **Language**: PowerShell (Core & Windows compatible)
- **Modules Required**: `ActiveDirectory` (RSAT tools must be installed)
- **Input Parameter**:
    - `Username` (SamAccountName of the user to audit)
- **Output Directory**:
    - `../exports/<Username>/`
- **Exported Formats**:
    - `CSV` – Summary of key attributes
    - `JSON` – Full object structure for system integration
    - `Markdown` – CAB-ready report format
    - `HTML` – Styled version for browser viewing
    - `Meta` – Metadata log for traceability
    - `Diff` – Snapshot comparison to detect changes since last run

---

##  How to Run

```powershell
# Navigate to the scripts directory
cd /scripts

# Run the audit for a specific user
.\ADUserDiscovery.ps1 -Username johndoe

 
### Describe the Change
This change introduces a **read-only PowerShell script (`ADUserDiscovery.ps1`)** designed to perform a **comprehensive Active Directory user account audit**. The script is executed prior to implementation phases (e.g., onboarding, privilege assignment, automation workflows, or account changes) to ensure the user's configuration is secure, expected, and compliant with internal controls.

It captures and exports key user metadata, including:

-  **Group Memberships** – Validates against expected RBAC design and detects privilege anomalies.
-  **Organisational Unit (OU) Path** – Confirms account placement in the correct OU for GPO inheritance and policy scope.
-  **Linked Group Policy Objects (GPOs)** – Reviews active policies linked to the user's OU, checking against security baselines.
-  **Access Control Lists (ACLs)** – Captures delegated rights to the user object in AD.
-  **FSLogix Profile Path Check** – Detects whether a cloud profile path exists for the user.
-  **User Metadata** – Includes SID, display name, email, enabled state, last logon time, logon script, and profile path.

All outputs are stored in timestamped JSON, Markdown, CSV, and HTML formats under:
### Output Structure

##  Implementation Plan – `ADUserDiscovery.ps1`

This section outlines the structured implementation plan for deploying and using `ADUserDiscovery.ps1` in a production Active Directory environment.

---

###  Purpose

To provide a **read-only audit mechanism** that validates **Active Directory user configurations** prior to group or access changes. This ensures confidence during change control processes by verifying:

- Group memberships  
- Linked GPOs  
- ACLs and inherited permissions  
- Last logon status and OU placement  
- FSLogix and profile path presence

---

###  Step-by-Step Deployment

#### 1. **Clone or Copy Script to Secure Location**

```bash
/scripts/ADUserDiscovery.ps1


Recommended: Place inside a secured, version-controlled repository or script folder on your admin jump box or management server.

2. Verify PowerShell Environment

Ensure the RSAT AD PowerShell module is available:
Get-Module -ListAvailable ActiveDirectory

3. Run a Test Audit
cd /scripts
.\ADUserDiscovery.ps1 -Username testuser1

	•	Output will appear under:

../exports/testuser1/

	•	Validate generated:
	•	CSV, JSON, MD, HTML
	•	ACL analysis and GPO links

4. Integration into CAB or Change Process
	•	Add as a required step for validating generic accounts or access changes.
	•	Export the Markdown or HTML report and attach to CAB ticket.
	•	Use the diff_summary.md to show config drift or audit deltas from previous runs.


#  ADUserDiscovery.ps1 – Implementation & Usage Guide

This guide explains how to implement and run the `ADUserDiscovery.ps1` script in a production environment. It is designed for safe, read-only auditing of Active Directory user accounts before implementing group, permission, or access changes.

---

##  Purpose

The `ADUserDiscovery.ps1` script validates a user's **AD group memberships**, **OU**, **GPO links**, and **ACLs** prior to configuration changes. It ensures:

- Accurate CAB documentation  
- Reduced risk of misconfiguration  
- Visibility into FSLogix and profile setup  
- Historical comparison of user configuration drift  

---

##  Directory Structure

```text
/scripts/ADUserDiscovery.ps1
/exports/<Username>/
    ├── ad_user_summary_<timestamp>.csv
    ├── ad_user_summary_<timestamp>.json
    ├── ad_user_summary_<timestamp>.md
    ├── ad_user_summary_<timestamp>.html
    ├── diff_summary.md
    ├── log_<timestamp>.txt
    └── meta_<timestamp>.json


