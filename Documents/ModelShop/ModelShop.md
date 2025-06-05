Here is your step-by-step, exact method for creating a Shared Mailbox at Williams, written for a Help Desk engineer to follow precisely and fully compliant with WN-FR9041 in package-WN-v1.07.docx.

 Canonical Procedure: Create a Shared Mailbox
Role: Help Desk / IT Engineer
Purpose: To provision a new Shared Mailbox compliant with Williams standards (v1.07)
Reference: WN-FR9041 – Email Setup

 1. Confirm Pre-Checks
Before proceeding, ensure:

 Request is submitted via Service Desk using the official mailbox request template

 Business sponsor provided:

Proposed mailbox name (e.g. modelshop@williamsf1.com)

Description of purpose

Department/function owner

List of authorised users (with Full Access and/or Send on Behalf)

 IT Security Manager has signed off the request

 1. Naming Convention
 Uses functional name only (no shr-, svc-, or other prefixes)

Must clearly represent the business function

 Valid: williamsav@williamsf1.com, modelshop@williamsf1.com

 Invalid: shr-williamsav@williamsf1.com, helpdesk01@williamsf1.com

⚙ 3. PowerShell Command Set (EXO PowerShell)
Open Exchange Online PowerShell:

powershell
Copy
Edit
# Step 1: Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName your.admin@williamsf1.com
 Create the Shared Mailbox
PowerShell
Copy
Edit
# Step 2: Create the Shared Mailbox
New-Mailbox — Shared — Name "Model shop Shared Mailbox" -DisplayName "Model shop" Alias "modelshop" -PrimarySmtpAddress "modelshop@williamsf1.com"
 Assign Full Access & Send on Behalf of 
PowerShell
Copy
Edit
# Step 3: Grant Full Access to authorised users
Add-MailboxPermission — Identity "modelshop@williamsf1.com" User "firstname.surname@williamsf1.com" -AccessRights FullAccess -InheritanceType All

# Repeat for all users who need access
powershell
Copy
Edit
# Step 4: Grant Send on Behalf rights
Set-Mailbox-Identity "modelshop@williamsf1.com" -GrantSendOnBehalfTo "firstname.surname@williamsf1.com"
 Do NOT set Send As rights unless authorised by the IT Security Manager.

 1. Document in AD
Update the AD object for audit traceability:

Field	Value Example
Description	“Shared Mailbox for modelshop team”
Manager	"Eoghain McAllister"
Phone (if available)	Internal ext. or sponsor number
Service Desk Ref	e.g. “WF1SD-1052”

Update fields via ADUC or PowerShell (if delegated):

 1. Confirm Mailbox is a Licence-Free
Check that no licence has been assigned:

PowerShell
Copy
Edit
Get-Mailbox "modelshop@williamsf1.com" | Format-List RecipientTypeDetails, Licence
Expected output:
RecipientTypeDetails : SharedMailbox
Licences: {} (Empty – licence-free)

 1. Testing Instructions
From any user granted access:

Go to https://office.com

Login using Individual Account (not shared)

Open Outlook Web

Confirm:

Shared Mailbox appears

Emails can be read/organised

Can send email “on behalf of” shared mailbox

Cannot send “as” the mailbox

 1. Maintenance & Expiry Policy
Password: Not applicable (Shared Mailboxes don’t require direct login)

Expiry: Tracked via linked Service Desk request

Ownership: If the business sponsor leaves, must update Manager field

Decommission if unused, with audit record

 Summary
Step	Task
1	Confirm authorised request and naming
2	Provision mailbox with New-Mailbox -Shared
3	Assign Full Access and Send on Behalf (no Send As)
4	Set AD fields: Description, Manager, Ticket Ref
5	Validate licence-free status
6	Verify access with user login
7	Document and maintain compliance

Wrap this into a .ps1 script or create a Makefile.md entry as part of your automation standard?









modelshop.docx
Document
 Summarises the existing generic modelshop account and lists all the requirements for the new shr-modelshop in a method based for an engineer to implement.

Legacy modelshop Generic Account to the fully compliant shr-modelshop Shared Account model, based on the detailed governance in modelshop.docx and package-WN-v1.07.docx.

 Summary of the Existing Generic Account: modelshop
Account ID: modelshop (FACTORY\modelshop)

Type: Legacy generic account

Usage: Shared logon across 30+ devices for team activities, especially dimension measurements and CAD-related tasks.

Security Risk: Non-compliant with Williams IT security standards:

Not traceable to an individual

Used across multiple sessions/devices

Full access to critical network shares and apps

Bypasses MFA, password vault, and PoLP

 Canonical Replacement: shr-modelshop
 Objective
 Migrates to a PoLP-compliant shared account model, adopting:

Account: shr-modelshop@williamsf1.com

Mailbox: modelshop@williamsf1.com (Shared Mailbox)

Team Identity: shr-modelshop@williamsf1.com

Access via AD groups: Login, RW Network Access, RDC

Disable & archive the old modelshop account post-UAT

 Implementation Plan: Engineer Task List
1.  Create the Shared AD Account
   PowerShell
   Copy
   Edit
# Create Shared AD Account
New-ADUser-Name "shr-modelshop" `
  -SamAccountName "shr-modelshop" `
-UserPrincipalName "shr-modelshop@williamsf1.com" `
  -DisplayName "Modelshop Shared Account" `
-Path "OU=SharedAccounts, DC=williamsf1,DC=com" `
  -Enabled $true `
-AccountPassword (Read-Host -AsSecureString "Enter Password") `
  -PasswordNeverExpires $true `
-Description "Shared Account for Modelshop team activities. Sponsored by Mark Peers. See WF1SD-XXXX"
1. Assign to AD Groups
   PowerShell
   Copy
   Edit
# RW Access Group
Add-ADGroupMember -Identity "grp-modelshopRW" -Members "shr-modelshop"

# Device Login Access Control Group
Add-ADGroupMember -Identity "grp-modelshopLAC" -Members "shr-modelshop"
1. Restrict Login Scope
   Ensure shr-modelshop is restricted to Device Category 8:

powershell
Copy
Edit
# Confirm login GPO is scoped via grp-modelshopLAC and only applies to Device Category 8
# Devices like: M1262, W9014, M9504, W9478, etc.
1. Provision Shared Mailbox
   PowerShell
   Copy
   Edit
# Create Shared Mailbox
New-Mailbox — Shared — Name "Modelshop Shared Mailbox" `
  -DisplayName "Modelshop" `
-Alias "modelshop" `
-PrimarySmtpAddress "modelshop@williamsf1.com"

# Assign Full Access and Send on Behalf
Add-MailboxPermission-Identity "modelshop@williamsf1.com" User "Mark.Peers@williamsf1.com" -AccessRights FullAccess
Set-Mailbox — Identity "modelshop@williamsf1.com" -GrantSendOnBehalfTo "Mark.Peers@williamsf1.com"
1. MS Teams Setup
   Log into M365 admin portal

Enable Teams licence for shr-modelshop@williamsf1.com if required

Confirm identity appears in Teams and can join meetings

Migrate any Teams config/photo-upload workflows

1. Configure File Access
    Drive mappings:
   Drive	Path
   P:\	\\factory.wf1\DFS2
   T:\	\\factory.wf1\DFS2\Department2
   X:\	\\factory.wf1\wf1\user_cae_files2\shr-modelshop
   Y:\	\\factory.wf1\wf1\pdmfiles\cae_common

Ensure shr-modelshop has RW access to all paths above.

1. Enable Internet + Web Apps
   Internet Access: Ensure firewall rules allow standard access

Intranet Apps: Ensure shr-modelshop has access to Power BI, Teams Web, Outlook Web

SharePoint Sites:

The Hub

Aero Ops

Modelshop

Grant access via:

PowerShell
Copy
Edit
Add-SPOUser — Site "https://williamsf1.sharepoint.com/sites/ModelShop" -LoginName "shr-modelshop@williamsf1.com"
1. Device Access Configuration (Device Category 8)
   For each device (e.g. M1262, W9014):
   Remove legacy admin accounts:

PowerShell
Copy
Edit
Remove-LocalGroupMember-Group "Administrators" Member "modelshop"
Remove-LocalGroupMember-Group "Administrators" -Member "Aero Local Administrators"
Add DPT Admin Group to Administrators

Confirm RDP restrictions are in place via grp-modelshopRDC

1. Migrate App Access & File Storage
   Repoint all application configs from modelshop → shr-modelshop

Copy OneDrive photo folders and map upload workflows

Test CAD tools, NX, Creaform, mPART etc. under new user profile

1. Run UAT (User Acceptance Testing)
   Tasks:

Login on all Device Category 8 endpoints

Validate email + Teams access

Validate RW file access

Test all required apps

Validate photo capture + upload

1. Disable Old Account
   PowerShell
   Copy
   Edit
   Disable-ADAccount-Identity "modelshop"
   Update AD Description:

PowerShell
Copy
Edit
Set-ADUser -Identity "modelshop" -Description "Deprecated Generic Account. Replaced by shr-modelshop in 2025-05-20. Do not use."
1. Document in AD
   Update shr-modelshop with:

AD Field	Value
Description	"Modelshop shared account. Sponsored by Mark Peers. Used for CAD & manufacturing apps in Device Cat 8."
Notes	"Password must be rotated annually and stored in its Password Vault. Owner must inform its Support on change."

 Test Plan Checklist (Mandatory for Go-Live)
Can log in to all 8-category devices

All mapped drives are accessible

Power BI, Outlook Web, Teams all work

RDP permissions scoped correctly

Email visible and usable in Individual Account context

Legacy modelshop account is fully disabled

Let me know if you'd like this as a .ps1 provisioning script or a CAB-ready Markdown version (Make.md).











