Action Plan: Deployment of shr-machine-mfg Shared Account
🔷 1️⃣ Create Shared AD Account
Account name:
shr-machine-mfg

Ensure:

Strong password, changed annually

Notes in AD with:

Business owner: Conner Murphy

Purpose: Shared login for Machine Shop devices

Reminder to update vault when password is changed

Password stored in IT-approved vault (e.g., 1Password)

🔷 2️⃣ Create AD Groups
Create the following AD security groups aligned with best practices and naming conventions:

Group Name	Purpose
grp-machine-mfgRO	Read-only network access
grp-machine-mfgRW	Read-write network and apps access
grp-machine-mfgLAC	Login access control – restrict login to specific devices
grp-machine-mfgRDC	Remote Desktop access control

🔷 3️⃣ Configure Group Memberships
Add shr-machine-mfg to:

grp-machine-mfgRW

grp-machine-mfgLAC

Add authorised users to grp-machine-mfgRDC if RDP is required.

Grant grp-machine-mfgRW and grp-machine-mfgRO appropriate NTFS/share permissions:

V:\\machineshop, V:\\cncprogram, V:\\Health & Safety, J:\\machshop, Z:\\Milling

(mapped as V:\\, J:\\, Z:\\)

🔷 4️⃣ Disable Legacy Generic Accounts
Disable the following in AD and Entra ID:

CellA

CellB

🔷 5️⃣ Configure Devices
Affected Devices:

nginx
Copy
Edit
M8662
W9474
M1909
M8687
SEIKI21
On each device:

Remove CellA and CellB from Local Administrators.

Ensure only DPT Admin Account is in Local Administrators.

Confirm DHCP network settings (per device).

Ensure all apps used under CellA/CellB are fully functional under shr-machine-mfg.

Test login & functionality.

🔷 6️⃣ GPO & Login Controls
Create GPO(s) scoped to affected devices or a dedicated OU.

Restrict interactive logon to members of grp-machine-mfgLAC only.

Restrict RDP to members of grp-machine-mfgRDC.

Ensure PoLP (Principle of Least Privilege) is enforced throughout.

🔷 7️⃣ Applications & Web Apps
Migrate all app configurations from CellA/CellB to shr-machine-mfg.

Test and UAT:

MS Edge

Mestec

NX

NX CAD/CAM (on M1909)

Teamcenter

Thread Disk for Windows

MS Office

Confirm intranet & internet access in line with policy.

🔷 8️⃣ Housekeeping
Document ownership & lifecycle of shr-machine-mfg in AD.

Confirm SharePoint access to:

Metallic Manufacturing – Home

Welcome / Shopfloor Development

Ensure no unauthorised local admin accounts remain.

Flag any risks around software licensing & adjust as needed.

🔷 9️⃣ File Transfer & Cleanup
Ensure all files and settings previously tied to CellA/CellB are available under shr-machine-mfg.

UAT each app & web app under shr-machine-mfg.

🔷 Summary Table
Step	Action
1	Create shr-machine-mfg AD account
2	Create & configure AD groups (RO, RW, LAC, RDC)
3	Add account to RW & LAC groups
4	Disable CellA & CellB
5	Update devices (remove old accounts, check apps)
6	Create & apply GPO/OU for login restrictions
7	Migrate & test apps/web apps
8	Document & secure account in vault
9	File transfer & final UAT

If you’d like, I can also draft:

📄 Markdown or Word document of this action plan

📝 PowerShell/commands to create the account & groups

🛠 Sample GPO settings documentation

Say the word if you want me to package it further.



From the document:

📄 In the To-Be Setup Details > Email Setup / MS Teams Setup / Shared Repository / Distribution Lists sections it explicitly states:

Email Setup:

There are no requirements for any special email configuration.
There are no requirements for any new Shared mailbox.
There are no requirements for any new Distribution Lists.

MS Teams Setup:

There are no requirements for MS Teams under this “Shared Account”.

Shared Repository:

There is no requirement to have a repository which can be used for storage of team documents.

So:
✅ No Exchange mailbox, no shared mailbox, no Teams, no DLs, no repository needed.

The shr-machine-mfg account is strictly for login to the specified machines and access to required apps, network shares, and SharePoint as detailed — nothing else.