 Modelshop Generic Account Remediation – Migration Strategy & Best Practice (Microsoft Enterprise Architecture Standard)
 Objective
Replace long-term use of modelshop generic account with a secured, auditable shared account shr-modelshop, while preserving operational continuity and aligning with Microsoft Identity, Compliance, and Security Best Practices.

1.  Discovery Summary
   As-Is:
   modelshop used interactively across 25+ workstations (Categories 3 & 8).

Data may be present across:

Local disks (C:)

Network shares (P:, T:, X:, Y:)

OneDrive (linked to generic profile)

SharePoint/Teams (via browser sessions)

To-Be:
Devices split:

Category 3 → Individual AD logins only

Category 8 → shr-modelshop Shared Account

modelshop account to be disabled, then deleted post-stabilisation.

2.  Migration Planning – Strategic Decisions
   2.1 Account Strategy
   Create AD user: shr-modelshop

Create AD Groups:

grp-modelshopRW, grp-modelshopRO

grp-modelshopLAC (Local Access Control)

grp-modelshopRDC (Remote Desktop Control)

Ensure UPN: shr-modelshop@williamsf1.com with M365 identity

2.2 Access Control
Only allow members of grp-modelshopLAC to log in locally.

Only allow members of grp-modelshopRDC to RDP to Category 8 devices.

All access uses PoLP (Principle of Least Privilege).

2.3 Identity Governance
Enforce 12-month password reset via AD policy.

Tag AD account with business owner, usage note, reset tracking.

Store credentials in secured IT Password Vault (e.g. 1Password).

3.  Workstation Actions (Category 3 & 8)
   3.1 Remove Insecure Access
   Remove modelshop from Local Admin group on all Category 8 devices.

Remove lingering named accounts (e.g., Julian.Davies, test, creaform) unless explicitly justified.

3.2 Lockdown Compliance
Ensure workstation GPO enforces:

Session timeout

Login tracking

Account lockout on threshold

No cached credentials

Devices auto-lock on idle (15 mins max).

3.3 Shared Account Lock-in
Prevent shr-modelshop login to non-approved devices via GPO filtering or conditional access.

Configure startup login scripts to ensure shared drive mappings (T:, X:, Y:) reflect shr-modelshop context.

4. ️ Data Discovery & Migration
   4.1 Local Device Risk
   Data may exist in:

C:\Users\modelshop\Documents, Desktop, Downloads

App-specific caches or config folders

Risk: Unstructured or critical data stored locally.

✅Action:

plaintext
Copy
Edit
Manually audit and back up C:\Users\modelshop on Category 8 devices
Move any relevant files to Shared OneDrive or SharePoint location under shr-modelshop
4.2 OneDrive Migration
Evidence shows photo capture/upload workflows exist using OneDrive.

modelshop's OneDrive must be migrated to shr-modelshop.

 Action:

plaintext

Create new M365 OneDrive for shr-modelshop
Migrate photo folders to shr-modelshop OneDrive
Update any automation (e.g., device photo upload apps) to point to new OneDrive
4.3 SharePoint & Teams
No existing SharePoint content needs migration (per doc), but permissions need remapping.

shr-modelshop must be granted access to:

The Hub

ModelShop

Aero Ops

 Action:

plaintext
Copy
Edit
Coordinate with site owners to add shr-modelshop with Contribute or Member access
5.  Application Compatibility
   5.1 Core Apps Must Be Retested
   Some legacy or specialist software (e.g., NX, Creaform VX, WTTP) may store paths or configs under %USERPROFILE%.

These must be retested under the new profile.

 Action:

plaintext
Copy
Edit
UAT all Category 8 software using shr-modelshop login
Confirm config, licensing, plugin compatibility
5.2 Licensing Risks
NX licensing flagged as unverified.

If licensing is tied to hostname, profile path, or SID, issues may occur.

 Action:

plaintext
Copy
Edit
Escalate to license manager to validate licensing model
6.  Shared Mailbox & Collaboration
   6.1 Email
   Setup: modelshop@williamsf1.com as shared mailbox

Grant access to Mark Peers & Julian Davies

No legacy mail migration required.

6.2 Teams
Enable full MS Teams access for shr-modelshop

Ensure it can host and join meetings

Migrate any saved media content (e.g., device-captured photos)

7.  Security, Monitoring & Audit
   Audit all successful logons by shr-modelshop

Alert on failed logons or login attempts on unauthorised devices

Log usage of mapped drives and web access

Monitor data access anomalies (e.g., Power BI usage, SharePoint bulk downloads)

 Recommendation:

Integrate with Microsoft Defender for Endpoint

Implement Defender Identity Protection alerts for Shared Account anomalies

8.  Rollback Contingency Plan
   If issues arise:

Enable modelshop temporarily (flagged in AD as legacy)

Retest issue

Apply fix, confirm success under shr-modelshop

Re-disable modelshop immediately

9.  Standardised Deployment Flow (Workstation-Side)
   Rule 6 Deployment (for Category 8)
   Verify modelshop is not present in:

Local Administrators

Remote Desktop Users

Ensure GPO applied for shr-modelshop lockdown.

Confirm apps, drive maps, OneDrive folder path.

Run manual check for local modelshop data:


Get-ChildItem "C:\Users\modelshop" -Recurse | Out-File "modelshop_file_audit.txt"
Migrate all data to shr-modelshop OneDrive where appropriate.

Reboot, validate login, test application.

Document changes and submit verification report.

10.  Unknowns and Long-Term Risks (Architect Notes)
    Shadow App Configs: Some apps may reference modelshop path or SID internally.

Credential Leak: modelshop credentials may be stored in automation scripts, services, or old batch files.

User Habit Persistence: Some users may continue entering modelshop out of habit — risk of lockouts or confusion.

Device Drift: LAN-bound or semi-isolated devices (e.g., Creaform, PolyWorks) may not get full GPO updates.

 Final Notes
This transition is not simply technical—it is cultural. The goal is:

Security without disruption

Auditability without resistance

Access control without loss of productivity

Document every deviation. Confirm every risk. Migrate once—correctly.



migrating from a Generic Account (e.g., modelshop) to a Shared Account (shr-modelshop), even with perfect documentation and UAT, there are hidden risks and behavioural edge cases that only surface after go-live. Below is a veteran architect’s list of post-migration unknowns to actively monitor—many of these are lessons learned the hard way over 30 years in enterprise.

 Unknowns & Post-Migration Landmines: Shared Account Deployment
 1. Cached Credentials in Third-Party Apps or Scheduled Tasks
Risk: Legacy credentials (modelshop) may be stored in:

Windows Credential Manager

Mapped drive connections with "remember me"

App settings (VLC, FTP clients, imaging software)

Scheduled tasks (run as modelshop)

Mitigation:

powershell
Copy
Edit
# Identify saved credentials
cmdkey /list

# Scheduled task scan
Get-ScheduledTask | Where-Object {$_.Principal.UserId -like "*modelshop*"}
 2. App-Level Identity Assumptions
Risk: Older or bespoke applications may store:

Local config files under %USERPROFILE%\AppData\

Absolute paths referencing C:\Users\modelshop\...

Licensing tied to SID, username, or login path

Environment variables inherited from modelshop

Mitigation: Check:

%APPDATA%, %LOCALAPPDATA%, and %PROGRAMDATA%

App logs and ini/config files for user references

Licensing portals for account linkage

 3. Orphaned Data
Risk: Local files never migrated:

Desktop, Downloads, Scans folder

Temporary folders used by plugins (PolyWorks, VXElements)

Mitigation:

Use robocopy or forensic audit script:

powershell
Copy
Edit
robocopy "C:\Users\modelshop" "D:\migration_backup" /MIR /XJ /R:1 /W:1 /LOG:log.txt


 4. OneDrive / Photo Sync Breakage
Risk: Devices uploading photos may still be pointed at modelshop's OneDrive.

Mobile sync apps may still be authenticated with old account

Upload scripts may hardcode modelshop paths

Mitigation:

Review task scheduler, any Photosync or upload agents

Reauthenticate all upload tools to shr-modelshop OneDrive

5. Misconfigured File/Folder ACLs
Risk: NTFS or Share permissions may still include modelshop explicitly, causing:

Access Denied errors for shr-modelshop

Confusing “invisible” permissions due to inheritance

Mitigation:

powershell
Copy
Edit
# Use PowerShell to scan ACLs
Get-ChildItem X:\ -Recurse | Get-Acl | Where-Object { $_.AccessToString -match "modelshop" }


 6. Web App or SharePoint Session Problems
Risk: If sessions or tokens were cached under modelshop, cookies may expire or prevent login under the new account.

Mitigation:

Clear browser cache before first shared account use

Re-authenticate SharePoint/Teams/Power BI

 7. MS Teams & Email Delegation Errors
Risk: Some users may not see the shared mailbox or Teams environment, despite being in the group.

Cached profiles

Missing Outlook AutoMap

Incorrect MS Teams tenant sync

Mitigation:

Force Outlook reprofile

Verify Teams licence is assigned via M365 Admin Portal

Run Test-MapiConnectivity and mailbox delegation tests

 8. Reporting & Audit Tool Failures
Risk: SIEMs, Power BI reports, or monitoring dashboards may filter by modelshop for activity tracking.

Mitigation:

Update dashboards to track shr-modelshop

Add note in SOC runbook about account name change

 9. Email & RDP Autocomplete Confusion
Risk: Auto-complete entries in Outlook or Remote Desktop Connection still resolve modelshop.

Mitigation:

Manually remove from Outlook’s AutoComplete cache:

Open new mail → type modelshop → hit Del

Reset Remote Desktop cached usernames via:

reg
Copy
Edit
reg delete "HKCU\Software\Microsoft\Terminal Server Client\Default" /v MRU0
‍‍ 
10. 
11. Behavioural Resistance or Misuse
Risk: Users may revert to old habits:

Typing modelshop even if disabled

Sharing new credentials insecurely

Leaving devices unlocked

Mitigation:

Send daily reminder emails for 2 weeks

Lock modelshop in AD with event alert trigger

Auto-lock GPO after 60 seconds idle (initial enforcement)

 11. Forgotten Service Dependencies
Risk: Background tasks or services running under modelshop context

Printer server jobs

Label printing daemons

Internal APIs or robotic scripts

Mitigation:

powershell
Copy
Edit
# Check running services
Get-WmiObject Win32_Service | Where-Object { $_.StartName -like "*modelshop*" }
 Final Note: Never Trust the "All Clear"
The appearance of successful login and app usage does not confirm full migration success.

Best Practice:

Do a 7-day post-migration audit

Run full file ACL check

Review Defender logs for blocked access events

Interview users anonymously for workflow breakages

Would you like me to wrap this as a Markdown report, OneNote page, or PDF for distribution to the implementation team? I can also generate audit scripts for each item.






Command:
powershell
Copy
Edit

robocopy "C:\Users\modelshop" "D:\migration_backup" /MIR /XJ /R:1 /W:1 /LOG:log.txt
 Switch-by-Switch Explanation:
Switch	Purpose	Detail
"C:\Users\modelshop"	Source path	This is the full root folder of the user profile being migrated (e.g. Desktop, Documents, AppData).
"D:\migration_backup"	Destination path	This is where you want the data backed up to. You could also use a network UNC path like \\server\migration$\modelshop.
/MIR	Mirror source to destination	Mirrors the entire directory tree, including deletions—be cautious, as it will delete files at the destination that don’t exist at the source. Ideal for backups or migrations where the destination is temporary and disposable.
/XJ	Exclude junction points	Prevents infinite loops caused by NTFS directory junctions or symlinks (e.g. C:\Users\modelshop\AppData\Application Data), which can recurse into themselves.
/R:1	Retry 1 time on failure	If a file is locked or in use, Robocopy will retry once before skipping.
/W:1	Wait 1 second between retries	Reduces wasted time between retry attempts. Defaults are 1,000,000 retries with 30 seconds wait (!), so this drastically improves speed.
/LOG:log.txt	Log output to file	Captures all activity (copied, skipped, failed files) into a text log—useful for review and audit.



Robocopy copies local files only unless:
You explicitly specify a network path as a source or destination, e.g.:

powershell
Copy
Edit
robocopy "\\factory.wf1\DFS2\modelshop-data" "D:\backup"
You're copying from C:\Users\modelshop but the user had folders redirected to network shares (e.g. Documents mapped via GPO).

 What Robocopy will not detect unless manually configured:
Mapped drives like X:\, T:\, P:\ → these must be explicitly listed.

SharePoint or OneDrive cloud sync folders if they’re stubbed/offline.

Symbolic links pointing to external volumes.

🛡 Recommended Practice When Migrating Generic User Data:
Run Robocopy for each known path:

Local profile: C:\Users\modelshop

Mapped drives: Identify with:

powershell
Copy
Edit
net use
OneDrive folder (e.g. C:\Users\modelshop\OneDrive - Williams F1\)

Add additional commands for mapped paths:

powershell
Copy
Edit
robocopy "X:\modelshop-data" "D:\backup\x-drive" /MIR /R:1 /W:1 /LOG:log_x.txt
Check for symbolic links with:

powershell
Copy
Edit
dir /AL /S "C:\Users\modelshop"
 Optional Enhancements
Switch	Purpose
/SEC	Copy security (NTFS ACLs)
/COPYALL	Copy all file data + timestamps + ACLs
/Z	Enables restartable mode (safe for large files over network)
/TEE	Output to screen + log simultaneously













