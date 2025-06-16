Here's a distilled, action-only summary of the required tasks and configuration steps to replace the prtguser generic account with the compliant shared account shr-itdisplay.

 Required Actions for New Shared Account (shr-itdisplay)
 1. Account Creation
Create AD shared account: shr-itdisplay

🏷 2. AD Group Setup
Create and configure the following AD groups:

grp-itdisplayRO – Read-only access to network areas

grp-itdisplayRW – Read-write access to network/local areas

grp-itdisplayLAC – Login access control for device login

grp-itdisplayRDC – Remote Desktop Control group

 3. Group Membership
Add shr-itdisplay to:

grp-itdisplayRW

grp-itdisplayLAC

Add authorised users (Matt Wallace, Dale Selway, TIG Desktop Support team) to:

grp-itdisplayRDC

 4. Device Configuration (M1424)
Ensure Device M1424 remains in use

Remove prtguser from Local Administrators

Add only DPT Admin Account to Local Administrators

Configure screens: disable timeout, screen sleep, hibernation, auto log-out

 5. Access Permissions
Apply PoLP (Principle of Least Privilege)

Grant only standard user access to local drive (e.g., OneDrive)

Ensure Internet access follows security policy

No SharePoint, Email, or MS Teams access needed

 6. App Migration
Migrate all apps and config from prtguser to shr-itdisplay

Core apps include MS Edge + Service Desk-specific apps

 7. File Migration
Migrate any saved files/configs from prtguser to shr-itdisplay

🛡 8. Security & Compliance
Rename prtguser → shr-itdisplay (or create new if rename isn't clean)

Ensure password policy:

Strong password

Changed at least annually

Stored in IT-approved password vault (e.g., 1Password)

Annotate AD account:

Owner

Reset frequency

Purpose description

 9. Risk Mitigation
Flag risks:

App dependencies may fail if hardcoded to prtguser

Ensure apps are reconfigured for shr-itdisplay

Test RDC and login on M1424 before rollout

 Expected Outcome
Non-compliant prtguser account fully retired

All service desk display functions maintained using shr-itdisplay

Account aligned with IT security policies and audit standards

Only approved users and devices can interact with the system

full Rule 6 deployment script or AD group creation script to match.











