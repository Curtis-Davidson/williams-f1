Markdown summary to describe and justify the ADUserDiscovery.ps1 script for formal CAB approval.

# CAB Submission – Active Directory User Discovery Tool
**Script Name:** `ADUserDiscovery.ps1`
**Author:** Paul R Davidson
**CAB Reference:** `P-135901`
**Version:** `2025.8.0`
**Repository:**  https://github.com/UrbantekDev/williams-f1

---

##  Purpose
This PowerShell script performs a **complete enterprise-grade audit** of a specified Active Directory (AD) user, aligned to WF1 security policy and Rule 6 compliance.

It is designed to:
- Identify **account anomalies**
- Document **access rights**
- Produce **exportable audit records**
- Support risk mitigation for **generic, dormant, or privileged accounts**

---

##  What the Script Does

### 1. **Discovers full AD profile of a user**
- Full AD attributes (`DisplayName`, `Email`, `LastLogon`, etc.)
- SID resolution
- Enabled/disabled state
- ScriptPath & ProfilePath
- FSLogix profile presence check

### 2. **Enumerates Security Context**
- **Group memberships**
- **Linked GPOs** via `Get-GPInheritance`
- **Direct ACLs** via `Get-Acl` (delegated or explicit rights)

### 3. **Defines an `ADUserProfile` Class**
- Allows for object-based handling
- Supports **historical comparison** with previous snapshots
- Enables **diff tracking**: groups, GPOs, OU, and ACLs

### 4. **Outputs Multi-Format Reports**
- `.json` for data pipelines
- `.csv` for Excel/sorting
- `.md` (Markdown) for GitHub reviews or CAB meeting packs
- `.html` for visual clarity in browser/shareable UI
- `.log` for all runtime steps and decisions

### 5. **Supports Change Control Comparison**
- If a prior snapshot exists, differences are logged
- Delta report (`diff_summary.md`) shows what has changed
- Ensures traceability for audit and rollback

---

##  Output Location

All artefacts are written to:
./exports//

Each run is timestamped to prevent overwrites and maintain version history.

---

##  Justification

| Factor                  | Detail                                                                 |
|-------------------------|------------------------------------------------------------------------|
| **Business Risk**       | Generic, shared, or stale AD accounts pose a lateral movement threat.   |
| **Security Mandate**    | Required for WF1 ISO27001 controls and privilege audits.                |
| **Operational Benefit** | Generates full user posture in seconds; reproducible and exportable.   |
| **CAB Readiness**       | Output directly feeds CAB-level reviews via Markdown & HTML export.     |

---

##  Risk Profile

- **Low Operational Risk:** Read-only operations, no account modification.
- **Zero Dependency Runtime:** Native PowerShell + RSAT (`ActiveDirectory` module).
- **Rollback Not Required:** No write operations.
- **Tested Accounts:** All tests run against dummy users in lower environment before production.

---

##  Next Steps

An optional `ADUserReview.ipynb` Jupyter notebook is available for post-analysis tagging (Keep / Remove / CAB Review).
This supports final decision-making before disabling/removing accounts.

---

##  Approval Request

This script is **self-documenting, exportable, and Rule 6 compliant**.
Requesting CAB approval to:

- Schedule weekly audits of high-risk accounts
- Integrate into `make audit-user username=...` CLI workflow
- Link into CloudHealthLink for AI-driven identity reviews


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
|------------------------------------|-----------------------------------------------------------------------------|
| **Read-only**                      | Uses `Get-ADUser`, `Get-ADGroup`, `Get-GPInheritance`, `Get-Acl`. No `Set-`, `New-`, `Remove-` used. |
| **No Side Effects**                | Does not create, modify, move or delete any AD object. Purely observational. |
| **Fails gracefully**               | If a user does not exist or is inaccessible, script exits cleanly with a warning. |
| **Handles ACL errors**             | If ACLs cannot be retrieved due to permissions, logs a warning and proceeds. |
| **No impact to shares or servers** | Only outputs files to `../exports/<Username>/` directory. No UNC paths touched. |
| **No elevated AD rights needed**   | Can be run with Domain User privileges (read access to AD + ACLs only).     |