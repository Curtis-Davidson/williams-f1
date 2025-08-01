📋 shr-itdisplay Shared Account – Action Summary
🎯 Objective:
Retire the non-compliant prtguser generic account and implement a compliant shr-itdisplay shared account for Device M1424, which runs the TIG area Service Desk display.

🔷 Account Changes
✅ Rename prtguser → shr-itdisplay (do not create new account if possible; rename in AD & Entra)
✅ Update AD notes:

Business owner: Matt Wallace / Dale Selway

Purpose: Service Desk display

Password reset annually & stored in IT Password Vault
✅ Enforce password change annually & compliance with organisational policy

🔷 AD Groups
✅ Create & name AD groups:

grp-itdisplayRW → Read/Write access

grp-itdisplayRO → Read-Only access

grp-itdisplayLAC → Login Access Control

grp-itdisplayRDC → Remote Desktop Control

✅ Add shr-itdisplay to:

grp-itdisplayRW

grp-itdisplayLAC

✅ Add TIG users (Wallace, Selway, TIG support) to appropriate RDC & LAC groups

🔷 Device (M1424) Configuration
✅ Ensure M1424 is retained & accessible 24/7
✅ Remove prtguser from Local Administrators
✅ Retain only DPT Admin Account in Local Administrators
✅ Configure M1424 to:

Allow only grp-itdisplayLAC members to log in

Allow only grp-itdisplayRDC members to use RDC (plus DPT Admin)

Prevent time-out, sleep, hibernation, or auto logout — screens must stay active
✅ Confirm all Apps & Web Apps available under shr-itdisplay
✅ Transfer all files/configs from prtguser to shr-itdisplay

🔷 Access & Permissions
✅ Validate shr-itdisplay has appropriate local disk access (standard user areas; no extras)
✅ No specific network drives, SharePoint, or special email required
✅ Ensure Internet access in line with IT Security policies
✅ Confirm all Service Desk monitoring apps work under shr-itdisplay
✅ Review licensing impacts & adjust if needed

🔷 Documentation & Compliance
✅ Store account credentials securely in Vault
✅ Document the account purpose & business owner in AD
✅ Confirm device location is secure (review by Chris Hicks = no further action needed)

🔷 UAT & Handover
✅ Test login process and screen operation end-to-end with shr-itdisplay
✅ Validate apps, RDC, display behaviour, and ensure no disruption
✅ Communicate updated credentials & process to TIG team
✅ Remove any residual use of prtguser and disable it post-migration

Suggested Execution Order:
Rename account in AD & Entra → shr-itdisplay

Set up required AD groups & memberships

Reconfigure M1424 (local admin, group policies, power settings)

Transfer files & validate apps under shr-itdisplay

Perform UAT & obtain sign-off

Disable prtguser