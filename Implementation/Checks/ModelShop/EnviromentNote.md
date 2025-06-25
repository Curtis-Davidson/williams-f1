Migrating from a Generic Account (e.g., modelshop) to a Shared Account (shr-modelshop), even with perfect documentation and UAT, there are hidden risks and behavioural edge cases
________________________________________
Unknowns & Post-Migration Landmines: Shared Account Deployment
1. Cached Credentials in Third-Party Apps or Scheduled Tasks
   Risk: Legacy credentials (modelshop) may be stored in:
   •	Windows Credential Manager
   •	Mapped drive connections with "remember me"
   •	App settings (VLC, FTP clients, imaging software)
   •	Scheduled tasks (run as modelshop)
   Mitigation:
   powershell
   CopyEdit
# Identify saved credentials
cmdkey /list

# Scheduled task scan
Get-ScheduledTask | Where-Object {$_.Principal.UserId -like "*modelshop*"}
________________________________________
2. App-Level Identity Assumptions
   Risk: Older or bespoke applications may store:
   •	Local config files under %USERPROFILE%\AppData\
   •	Absolute paths referencing C:\Users\modelshop\...
   •	Licensing tied to SID, username, or login path
   •	Environment variables inherited from modelshop
   Mitigation: Check:
   •	%APPDATA%, %LOCALAPPDATA%, and %PROGRAMDATA%
   •	App logs and ini/config files for user references
   •	Licensing portals for account linkage
________________________________________
3. Orphaned Data
   Risk: Local files never migrated:
   •	Desktop, Downloads, Scans folder
   •	Temporary folders used by plugins (PolyWorks, VXElements)
   Mitigation:
   •	Use robocopy or forensic audit script:
   powershell
   CopyEdit
   robocopy "C:\Users\modelshop" "D:\migration_backup" /MIR /XJ /R:1 /W:1 /LOG:log.txt
________________________________________
4. OneDrive / Photo Sync Breakage
   Risk: Devices uploading photos may still be pointed at modelshop's OneDrive.
   •	Mobile sync apps may still be authenticated with old account
   •	Upload scripts may hardcode modelshop paths
   Mitigation:
   •	Review task scheduler, any Photosync or upload agents
   •	Reauthenticate all upload tools to shr-modelshop OneDrive
________________________________________
5. Misconfigured File/Folder ACLs
   Risk: NTFS or Share permissions may still include modelshop explicitly, causing:
   •	Access Denied errors for shr-modelshop
   •	Confusing “invisible” permissions due to inheritance
   Mitigation:
   powershell
   CopyEdit
# Use PowerShell to scan ACLs
Get-ChildItem X:\ -Recurse | Get-Acl | Where-Object { $_.AccessToString -match "modelshop" }
________________________________________


6. Web App or SharePoint Session Problems
   Risk: If sessions or tokens were cached under modelshop, cookies may expire or prevent login under the new account.
   Mitigation:
   •	Clear browser cache before first shared account use
   •	Re-authenticate SharePoint/Teams/Power BI
________________________________________
7. MS Teams & Email Delegation Errors
   Risk: Some users may not see the shared mailbox or Teams environment, despite being in the group.
   •	Cached profiles
   •	Missing Outlook AutoMap
   •	Incorrect MS Teams tenant sync
   Mitigation:
   •	Force Outlook reprofile
   •	Verify Teams licence is assigned via M365 Admin Portal
   •	Run Test-MapiConnectivity and mailbox delegation tests
________________________________________
8. Reporting & Audit Tool Failures
   Risk: SIEMs, Power BI reports, or monitoring dashboards may filter by modelshop for activity tracking.
   Mitigation:
   •	Update dashboards to track shr-modelshop
   •	Add note in SOC runbook about account name change
________________________________________
9. Email & RDP Autocomplete Confusion
   Risk: Auto-complete entries in Outlook or Remote Desktop Connection still resolve modelshop.
   Mitigation:
   •	Manually remove from Outlook’s AutoComplete cache:
   o	Open new mail → type modelshop → hit Del
   •	Reset Remote Desktop cached usernames via:
   reg
   CopyEdit
   reg delete "HKCU\Software\Microsoft\Terminal Server Client\Default" /v MRU0
________________________________________
10.  Resistance
     Risk: Users may revert to old habits:
     •	Typing modelshop even if disabled
     •	Sharing new credentials insecurely
     •	Leaving devices unlocked
     Mitigation:
     •	Lock modelshop in AD with event alert trigger
     •	Auto-lock GPO after 60 seconds idle (initial enforcement)
________________________________________
11. Forgotten Service Dependencies
    Risk: Background tasks or services running under modelshop context
    •	Printer server jobs
    •	Label printing daemons
    •	Internal APIs or robotic scripts
    Mitigation:
    powershell
    CopyEdit
# Check running services
Get-WmiObject Win32_Service | Where-Object { $_.StartName -like "*modelshop*" }
________________________________________
Final Note: Never Trust the "All Clear"
The appearance of successful login and app usage does not confirm full migration success.
Best Practice:
•	Do a 7-day post-migration audit
•	Run full file ACL check
•	Review Defender logs for blocked access events
•	Interview users anonymously for workflow breakages
________________________________________
________________________________________

Command:
powershell
CopyEdit
robocopy "C:\Users\modelshop" "D:\migration_backup" /MIR /XJ /R:1 /W:1 /LOG:log.txt
________________________________________
Switch-by-Switch Explanation:
Switch	Purpose	Detail
"C:\Users\modelshop"	Source path	This is the full root folder of the user profile being migrated (e.g. Desktop, Documents, AppData).
"D:\migration_backup"	Destination path	This is where you want the data backed up to. You could also use a network UNC path like \\server\migration$\modelshop.
/MIR	Mirror source to destination	Mirrors the entire directory tree, including deletions—be cautious, as it will delete files at the destination that don’t exist at the source. Ideal for backups or migrations where the destination is temporary and disposable.
/XJ	Exclude junction points	Prevents infinite loops caused by NTFS directory junctions or symlinks (e.g. C:\Users\modelshop\AppData\Application Data), which can recurse into themselves.
/R:1	Retry 1 time on failure	If a file is locked or in use, Robocopy will retry once before skipping.
/W:1	Wait 1 second between retries	Reduces wasted time between retry attempts. Defaults are 1,000,000 retries with 30 seconds wait (!), so this drastically improves speed.
/LOG:log.txt	Log output to file	Captures all activity (copied, skipped, failed files) into a text log—useful for review and audit.
________________________________________
Robocopy Detect/Handle Network Shares or Mapped Drives
Not automatically.
Robocopy copies local files only unless:
1.	You explicitly specify a network path as a source or destination, e.g.:
      powershell
      CopyEdit
      robocopy "\\factory.wf1\DFS2\modelshop-data" "D:\backup"
2.	You're copying from C:\Users\modelshop but the user had folders redirected to network shares (e.g. Documents mapped via GPO).
________________________________________
What Robocopy will not detect unless manually configured:
•	Mapped drives like X:\, T:\, P:\ → these must be explicitly listed.
•	SharePoint or OneDrive cloud sync folders if they’re stubbed/offline.
•	Symbolic links pointing to external volumes.
________________________________________
Recommended Practice When Migrating Generic User Data:
1.	Run Robocopy for each known path:
      o	Local profile: C:\Users\modelshop
      o	Mapped drives: Identify with:
      powershell
      CopyEdit
      net use
      o	OneDrive folder (e.g. C:\Users\modelshop\OneDrive - Williams F1\)
2.	Add additional commands for mapped paths:
      powershell
      CopyEdit
      robocopy "X:\modelshop-data" "D:\backup\x-drive" /MIR /R:1 /W:1 /LOG:log_x.txt
3.	Check for symbolic links with:
      powershell
      CopyEdit
      dir /AL /S "C:\Users\modelshop"
________________________________________
Optional Enhancements
Switch	Purpose
/SEC	Copy security (NTFS ACLs)
/COPYALL	Copy all file data + timestamps + ACLs
/Z	Enables restartable mode (safe for large files over network)
/TEE	Output to screen + log simultaneously
________________________________________
Rule 6-compliant step-by-step deployment method to implement section 2: Migration Planning – Strategic Decisions, covering Account Strategy, Access Control, and Identity Governance for shr-modelshop.
________________________________________
 Rule 6 Implementation: Strategic Account Migration Plan
Title: shr-modelshop Shared Account – AD, Group, Access Control and Governance Setup
________________________________________
1. Purpose
   To create the shr-modelshop shared AD account and associated security groups, configure access policies for login and RDP, and apply identity governance policies in line with Microsoft best practice and WF1 security requirements.
________________________________________
2. Exact Commands and Steps
________________________________________
🔹 Step 1: Create the shr-modelshop Shared Account
Full Path:
Active Directory Users and Computers (ADUC) → Shared Accounts OU
File Creation/Command:
powershell
CopyEdit
New-ADUser -Name "shr-modelshop" `
           -SamAccountName "shr-modelshop" `
-UserPrincipalName "shr-modelshop@williamsf1.com" `
           -Path "OU=SharedAccounts,DC=factory,DC=wf1" `
-DisplayName "Modelshop Shared Account" `
           -Description "Shared account for Modelshop team operations" `
-AccountPassword (Read-Host -AsSecureString "Set initial password") `
           -Enabled $true `
-PasswordNeverExpires $true `
           -CannotChangePassword $true `
-UserMustChangePassword $false
Comment:
Creates a secure AD Shared Account with M365 UPN for domain + cloud usage. Password policy enforced via governance below.
________________________________________
🔹 Step 2: Create AD Groups (RW, RO, LAC, RDC)
Full Path:
Active Directory Users and Computers (ADUC) → Security Groups OU
File Creation/Command:
powershell
CopyEdit
New-ADGroup -Name "grp-modelshopRW" -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,DC=factory,DC=wf1" -Description "RW Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopRO" -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,DC=factory,DC=wf1" -Description "RO Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopLAC" -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,DC=factory,DC=wf1" -Description "Login Access Control for shr-modelshop"
New-ADGroup -Name "grp-modelshopRDC" -GroupScope Global -GroupCategory Security -Path "OU=SecurityGroups,DC=factory,DC=wf1" -Description "Remote Desktop Control to Category 8 Devices"
Comment:
Grants precise separation of concerns. Only members of appropriate groups gain access to login, drive mapping, or RDP functionality.
________________________________________
🔹 Step 3: Assign Group Memberships
File Edit Command:
powershell
CopyEdit
# Add shr-modelshop to required groups
Add-ADGroupMember -Identity "grp-modelshopRW" -Members "shr-modelshop"
Add-ADGroupMember -Identity "grp-modelshopLAC" -Members "shr-modelshop"

# Add named users to RDC group
$rdcUsers = @("mark.peers", "julian.davies")
$rdcUsers | ForEach-Object { Add-ADGroupMember -Identity "grp-modelshopRDC" -Members $_ }
Comment:
Only approved users can log in to Category 8 devices via RDP. No excessive permissions are granted.
________________________________________
🔹 Step 4: Enforce LAC on Category 8 Devices
Full File Path:
Group Policy Management Console (GPMC) → GPO: WF1-Modelshop-Device-LAC
File Edit Command:
1.	Create GPO and link to Category 8 device OU.
2.	Edit Computer Configuration → Windows Settings → Security Settings → Local Policies → User Rights Assignment
      o	Allow log on locally → grp-modelshopLAC, Administrators
      o	Deny log on locally → Remove modelshop, deny everyone else if not required
3.	Edit Computer Configuration → Policies → Security Settings → Restricted Groups
      o	Add Administrators → Only allow DPT-Admin, IT-Operations, and remove modelshop
________________________________________
🔹 Step 5: Enforce RDC Access to Category 8 Devices
GPO: WF1-Modelshop-RDC-Access
File Edit Command:
1.	Edit Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → User Rights Assignment
      o	Allow log on through Remote Desktop Services → grp-modelshopRDC, DPT-Admin
2.	Verify:
      powershell
      CopyEdit
      (Get-WmiObject -Class Win32_TerminalServiceSetting).AllowTSConnections
________________________________________
🔹 Step 6: Identity Governance – Enforce Shared Account Policy
File Edit Command:
powershell
CopyEdit
# Set AD Notes for auditing
Set-ADUser -Identity "shr-modelshop" `
-Add @{
info="Business Owner: Mark Peers; Must update password annually; Use IT vault on change"
description="Modelshop shared account for Category 8 device access and shared workflows"
}
Additional Governance:
•	Enforce password reset every 12 months:
o	GPO or Azure Conditional Access
•	Record and store current password in 1Password
•	If changed, update vault and notify IT Support securely
________________________________________
🔹 Step 7: Verify Everything
Test Instruction:
1.	Use a Category 8 device.
2.	Log in using shr-modelshop; confirm login success.
3.	Attempt RDP from unauthorised user → must fail.
4.	Attempt RDP from julian.davies → must succeed.
5.	Attempt login as shr-modelshop on Category 3 device → must fail.
6.	Confirm network drive mounts and app access works.
________________________________________
Final Outcome
•	shr-modelshop account securely provisioned
•	PoLP enforced across login, file access, and remote control
•	Legacy account modelshop fully isolated
•	Shared account governance documented and auditable
________________________________________
Rule 6  AD best
________________________________________
CopyEdit
#  shr-modelshop – Shared Account AD Implementation Plan
**Author:** Microsoft Systems Architect  
**Client:** Williams F1 – Modelshop  
**Date:** 2025-06-17  
**Version:** 1.0  
**Purpose:** Strategic implementation of a shared account for secure access control, replacing legacy `modelshop` generic use.

---

##  Overview

This document defines the **step-by-step Active Directory and Governance implementation** for the `shr-modelshop` shared account, including:

- Account creation and M365 integration
- AD group structure (RW, RO, LAC, RDC)
- Device login and RDP restrictions
- Governance, documentation, and password lifecycle

---

## 🔹 Step 1: Create Shared AD User – `shr-modelshop`

**Path:** `OU=SharedAccounts,DC=factory,DC=wf1`

```powershell

---


### 
--- New-ADUser -Name "shr-modelshop" `
           -SamAccountName "shr-modelshop" `
           -UserPrincipalName "shr-modelshop@williamsf1.com" `
           -Path "OU=SharedAccounts,DC=factory,DC=wf1" `
           -DisplayName "Modelshop Shared Account" `
           -Description "Shared account for Modelshop team operations" `
           -AccountPassword (Read-Host -AsSecureString "Set initial password") `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true `
           -UserMustChangePassword $false
________________________________________
🔹 Step 2: Create Required AD Groups
Path: OU=SecurityGroups,DC=factory,DC=wf1
powershell
CopyEdit
New-ADGroup -Name "grp-modelshopRW" -GroupScope Global -GroupCategory Security -Description "RW Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopRO" -GroupScope Global -GroupCategory Security -Description "RO Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopLAC" -GroupScope Global -GroupCategory Security -Description "Login Access Control for shr-modelshop"
New-ADGroup -Name "grp-modelshopRDC" -GroupScope Global -GroupCategory Security -Description "Remote Desktop Control to Category 8 Devices"
________________________________________

🔹 Step 3: Assign Group Memberships
powershell
CopyEdit
Add-ADGroupMember -Identity "grp-modelshopRW" -Members "shr-modelshop"
Add-ADGroupMember -Identity "grp-modelshopLAC" -Members "shr-modelshop"

# Add named users to RDC group
$rdcUsers = @("mark.peers", "julian.davies")
$rdcUsers | ForEach-Object { Add-ADGroupMember -Identity "grp-modelshopRDC" -Members $_ }
________________________________________
🔹 Step 4: Enforce Local Login Restrictions via GPO
GPO: WF1-Modelshop-Device-LAC
•	Allow log on locally → grp-modelshopLAC, Administrators
•	Deny log on locally → remove modelshop
•	Use Restricted Groups to remove all legacy local admins
________________________________________
🔹 Step 5: Restrict RDP Access to Category 8 Devices
GPO: WF1-Modelshop-RDC-Access
•	Allow log on through Remote Desktop Services → grp-modelshopRDC, DPT-Admin
•	Confirm service enabled:
powershell
CopyEdit
(Get-WmiObject -Class Win32_TerminalServiceSetting).AllowTSConnections
________________________________________
🔹 Step 6: Identity Governance & AD Metadata
powershell
CopyEdit
Set-ADUser -Identity "shr-modelshop" `
    -Add @{
        info="Business Owner: Mark Peers; Must update password annually; Use IT vault on change"
        description="Modelshop shared account for Category 8 device access and shared workflows"
    }
•	Enforce password update every 12 months via GPO or CA
•	Store in approved IT password vault (e.g., 1Password)
•	Require secure vault update on password change
________________________________________
🔹 Step 7: Validation Procedure
Action	Expectation
Login to Category 8 device with shr-modelshop	✅ Success
Login to Category 3 device with shr-modelshop	❌ Blocked
RDP as unapproved user	❌ Blocked
RDP as mark.peers	✅ Success
Shared drives and apps	✅ Accessible
modelshop login	❌ Disabled
________________________________________
 Result
•	shr-modelshop fully compliant, secure shared account
•	Only approved devices and users allowed
•	Full PoLP enforcement via AD and GPO
•	Governance, auditability, and compliance ensured
________________________________________

---



CheckList Copy---



#  Modelshop Account Remediation – 

##  Purpose
Replace the insecure, overused `modelshop` generic account with:
- `shr-modelshop` shared domain account (for shared team machines)
- Individual accounts (for personal workstations)

---

##  Current ("As-Is") State
- Multiple users log into a **generic modelshop account** on many devices.
- Used for shift work, collaborative tasks, shared responsibilities.
- Breaks IT security policy (no auditability, high risk).

---

##  Future ("To-Be") Setup

###  Secure Login Rules:
- **Device Category 3**: Use **Individual Accounts only**
- **Device Category 8**: Use **shr-modelshop** shared domain account

###  Shared Account Rules:
- `shr-modelshop` will have proper:
  - Email (`modelshop@williamsf1.com`)
  - Teams account
  - Access to key drives: `P:\`, `T:\`, `X:\`, `Y:\`
  - Access to SharePoint sites: The Hub, Aero Ops, Modelshop

---

##  Devices Breakdown

###  Devices already decommissioned (Category 1):
- W9432, W9408, W9454, W3189, M3123

###  Devices now using Individual Login (Category 3):
- T2420, L10086, M3035, L2296, T2421, M9385, T2447, L2347, L2426,
  L11315, L11316, W8912, T10053, W11113, T2013, M9476, M10068

###  Devices using Shared Account (Category 8):
- M1262, W9014, M9504, W9478, M9062, W9435, W9058, M3123,
  L10556, L12048, creaform, L2464

---

##  Key Users with shr-modelshop Access
- ~40 named users
- Only 2 users need Remote Desktop (RDP): **Mark Peers, Julian Davies**

---

##  Shared Account Access Summary

| Resource Type        | Access Notes                                    |
|----------------------|-------------------------------------------------|
| **Drives**           | P:/ T:/ X:/ Y:/                                 |
| **Local Disk**       | Full C: access like a standard user             |
| **SharePoint**       | The Hub, Aero Ops, Modelshop                    |
| **Email**            | Shared Mailbox: shr-modelshop@williamsf1.com       |
| **MS Teams**         | Full Teams access for collaboration             |
| **Photos**           | Devices must upload to shr-modelshop OneDrive   |

---

##  Security & Admin Rules

- Remove `modelshop` from all Local Admin groups
- Create proper AD groups:
  - `grp-modelshopRW` – full file access
  - `grp-modelshopLAC` – login permission
  - `grp-modelshopRDC` – Remote Desktop access

---

##  UAT & Rollback

- UAT required for all apps under shr-modelshop
- If something breaks, **fallback = re-enable `modelshop` temp**

---

##  Final Tasks Summary

| Task                             | Required Action                                   |
|----------------------------------|---------------------------------------------------|
| Create shr-modelshop AD account  | ✅ Done via IT                                     |
| Setup mailbox + Teams            | ✅ Follow `WN-FR9041` & `FR9051`                  |
| Setup drive & SharePoint access  | ✅ Use AD groups (`RW`, `LAC`, `RDC`)             |
| Remove old admin accounts        | ✅ Device-by-device cleanup                       |
| Setup OneDrive for photos        | ✅ Migrate and sync devices for upload            |
| Update AD metadata               | ✅ Owner, use-case, password rotation notes       |
| Store password securely          | ✅ Use 1Password, rotate annually                 |

---

##  Risks to Flag

- Some apps may break (rely on modelshop hardcoded logic)
- NX license gaps
- Team habits may cause friction during shift

---
"""



 











