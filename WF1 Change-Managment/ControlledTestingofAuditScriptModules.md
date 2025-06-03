
========================================================================================================================

Title: Change Control: Controlled Testing of Audit Script Modules (AuditDev, AuditScripts, AuditWS) on Live Workstations
Type: Standard / Normal (non-emergency)
Classification: Controlled Script Execution for Audit, Discovery, and Compliance Verification

========================================================================================================================


1. Change Purpose

The purpose of this change is to execute and validate enterprise-grade audit and discovery PowerShell scripts across three modular environments:
- **AuditDev**: Development and testbed script staging
- **AuditScripts**: Core production audit libraries (admin rights, user rights, software, profiles)
- **AuditWS**: Workstation-bound security, logon, and local discovery logic

This is to verify:
- Script execution integrity
- Log generation
- Module dependency resolution
- No disruption to user processes or logon sessions

Scripts include:
- `workstation-requirements.ps1`
- `workstation-core.ps1`
- `Get-LogonAuditReport.ps1`
- `logon-requirements.ps1`
- `Makefile.ps1` orchestration

------------------------------------------------------------------------------------------------------------------------

2. Scope of Change

Applies to:
- All endpoints executing the `AuditWS` framework scripts
- User workstations and virtual machines tagged as non-critical or test-approved
- Output to dedicated log directories: `C:\AuditScripts\Logs\`, `\Output\`, `\Snapshots\`

Does NOT affect:
- Domain-wide policies
- AD-integrated scripts
- Firewall, AV, or GPO settings

Testing will occur using:
- Admin shell (elevated PowerShell)
- Controlled credentials
- Monitored logs and resource usage (CPU/mem/disk I/O under 5% tolerance)

------------------------------------------------------------------------------------------------------------------------

3. Risk Assessment

Applies to:
- All endpoints executing the `AuditWS` framework scripts
- User workstations and virtual machines tagged as non-critical or test-approved
- Output to dedicated log directories: `C:\AuditScripts\Logs\`, `\Output\`, `\Snapshots\`

Does NOT affect:
- Domain-wide policies
- AD-integrated scripts
- Firewall, AV, or GPO settings

Testing will occur using:
- Admin shell (elevated PowerShell)
- Controlled credentials
- Monitored logs and resource usage (CPU/mem/disk I/O under 5% tolerance)

------------------------------------------------------------------------------------------------------------------------

4. Change Implementation Steps

# Step 1 - Run workstation requirements check
.\requirements\workstation-requirements.ps1

# Step 2 - Run logon requirements validator
.\requirements\logon-requirements.ps1

# Step 3 - Execute audit discovery
.\scripts\williamsf1-workstation-audit.ps1

# Step 4 - Run full logon event history dump
.\Security\Get-LogonAuditReport.ps1

# Step 5 - Verify all output directories and HTML reports
Start-Process "$env:SystemRoot\System32\notepad.exe" "C:\AuditScripts\Logs\*.log"
Start-Process "C:\AuditScripts\Output\LogonAuditReport_*.html"

------------------------------------------------------------------------------------------------------------------------

5. Rollback / Recovery

Rollback Plan:
- Delete all generated output in `C:\AuditScripts\Logs`, `Output`, `Snapshots`
- Remove any installed modules from user scope via:
  ```powershell
  Uninstall-Module -Name 'ImportExcel' -Force -Scope CurrentUser


  	•	No changes to system configuration or registry
	•	No services or scheduled tasks modified
	•	Safe to re-run on clean system with no side effects

Escalation: Rollback plan handled by Curtis-Davidson. If script failure causes OS load issues,
reboot clears all memory-bound impact.

  ----------------------------------------------------------------------------------------------------------------------


  Escalation: Rollback plan handled by Curtis-Davidson. If script failure causes OS load issues, reboot clears all memory-bound impact.


---

### 6. **Validation and Acceptance Criteria**
```markdown
Success =  All modules execute without error
           Logs generated under logs/
           CSV and HTML reports output
           Summary table confirms required modules

Failure =  Exit codes 1001–1003 logged in requirements scripts
           Logon data unavailable
           Missing modules unresolved

------------------------------------------------------------------------------------------------------------------------

7. Business Justification

This change ensures workstation environment scripts are validated in production-like scenarios for audit compliance, security reporting, and workstation telemetry discovery.
This aligns with ITIL and ISO 27001 continuous monitoring and forensic readiness goals.

------------------------------------------------------------------------------------------------------------------------

8. Stakeholders / Approvers
	•	Curtis-Davidson — Change Owner, Script Author
	•	IT Security Team — Notified
	•	Infrastructure Lead — FYI



	                       --------------------------------------------

9. Why I’m Running Exploratory Scripts Instead of Relying Solely on Lansweeper

“The reason I’m executing exploratory PowerShell scripts across ModelShop and workstation endpoints rather than relying
solely on Lansweeper is because Lansweeper—while excellent for static asset inventory—does not provide the depth, context,
or real-time accuracy needed for environment-sensitive testing, profile preservation, and configuration integrity validation.”

Key Advantages of Exploratory Scripts vs Lansweeper


##  Key Advantages of Exploratory Scripts vs Lansweeper

| **Feature / Need**                                 | **Lansweeper**               | **PowerShell Exploratory Scripts**       |
|--------------------------------------------------  |--------------------------- --|------------------------------------------|
| **Real-time execution context**                    | ❌ Not supported             | ✅ Deep per-user inspection              |
| **SID-to-Profile mapping for migration**           | ❌ Not exposed               | ✅ Fully traceable via script            |
| **CAD-specific configurations (registry + paths)** | ❌ Generic data only         | ✅ Custom targeted logic                 |
| **Live event log correlation (logon audits)**      | ❌ Not captured              | ✅ Captured with `Get-WinEvent`          |
| **GPO and local rights enumeration**               | ❌ Requires complex config   | ✅ Scripted via `secedit`, `gpresult`    |
| **Testing impact in situ (pre-change simulation)** | ❌ Not possible              | ✅ Safe, isolated, reportable            |
| **Custom output to HTML, CSV, Teams logs**         | ❌ Vendor-locked             | ✅ Fully controlled outputs              |
| **Version-controlled logic**                       | ❌ GUI-limited               | ✅ GitOps compliant, auditable           |



------------------------------------------------------------------------------------------------------------------------



