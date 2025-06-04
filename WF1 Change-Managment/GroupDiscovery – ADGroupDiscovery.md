# CAB Submission: Active Directory Group Discovery – ADGroupDiscovery.ps1

##  Title
AD Group Snapshot & Drift Detection Script — `ADGroupDiscovery.ps1`

---

## C – Context (Business & Technical Overview)

This script performs an enterprise-grade discovery of an Active Directory (AD) **security or distribution group**, collecting the following attributes:

- **Group metadata:** name, type, scope, description
- **Recursive member resolution** including nested groups
- **Access Control List (ACL)** extraction from the `AD:` provider
- **Drift detection** against previous snapshot (change tracking)
- **Full markdown + HTML report generation** for CAB use

This is part of the wider **Williams F1 AD Governance Audit Framework** to maintain secure group memberships and document AD object states over time for compliance, change tracking, and forensic audits.

---

## R – Risk Assessment (Pre-Change State + Failure Modes)

###  Risk Level: **Low**
- **Read-Only to Active Directory:** All operations use `Get-ADGroup`, `Get-ADGroupMember`, and `Get-Acl`.
- No write or modification commands are executed against AD.
- ACL read may fail on restricted groups — this is safely handled with a warning log.

###  Failure Modes:
| Scenario                            | Impact                                  | Mitigation                          |
|-------------------------------------|------------------------------------------|-------------------------------------|
| Group does not exist                | Script exits with `exit 2`               | Logged as `ERROR` in runtime log    |
| ACL retrieval fails                 | Logs `WARN` and continues                | ACL table in report may be empty    |
| JSON export fails (locked dir)      | Script exits on unhandled error          | Always uses `New-Item -Force`       |
| Compare fails (invalid cache)       | Skips comparison, still exports current  | Recovers in next valid run          |

---

## A – Action Plan (Implementation Steps)

### Required:
```powershell
# Step 1 – Launch from PowerShell
.\ADGroupDiscovery.ps1 -GroupName "Finance-UK"

# Step 2 – Open outputs (Markdown, HTML, or diff)
explorer ..\exports\Finance-UK


#  ADGroupAudit.ps1 – Run Instructions & Production Safety

##  How to Run This Script (Against Any AD Group)

### Step-by-Step:

```powershell
# 1. Open PowerShell as Administrator (if on a server)
cd "C:\YourAuditRepo\scripts"

# 2. Run the script with a valid AD group name
.\ADGroupDiscovery.ps1 -GroupName "Finance-UK"

Output Location

By default, all outputs are written to:




## 📁 Example Output Location

By default, all outputs are written to:

```
../exports/<GroupName>/
```

> Example: `../exports/Finance-UK/`

| File                              | Description                                      |
|-----------------------------------|--------------------------------------------------|
| `group_snapshot_<timestamp>.json` | Full object export (group, members, ACLs)       |
| `group_report_<timestamp>.md`     | Markdown summary for CAB use                    |
| `group_report_<timestamp>.html`   | Styled browser report                           |
| `diff_summary.md`                 | Change report vs last run                       |
| `log_<timestamp>.txt`             | Execution log with INFO/WARN/SUCCESS entries    |


##  Why This Script Is Safe in Production

|  Characteristic                  | Explanation                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------|
| **Read-only**                     | Uses `Get-ADGroup`, `Get-ADGroupMember`, `Get-Acl`. No `Set-`, `New-`, `Remove-` used. |
| **No Side Effects**               | Does not create or modify any AD object. Only reads and exports data.       |
| **Fails gracefully**              | If a group doesn't exist, exits cleanly with a log message.                |
| **Handles ACL errors**            | If ACLs can't be retrieved (permissions), logs a warning and continues.    |
| **Does not touch network shares** | Only writes under `../exports/<GroupName>`. No external dependencies.      |
| **No elevated AD rights needed**  | Only needs read access to the group + ACL (typical for Domain Users).      |