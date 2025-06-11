RULE 6 IMPLEMENTATION: CAD RDP LOCKDOWN – TUNNELOPS TEAM

Objective:
Only 10 users in TunnelOps can RDP into exactly 3 CAD machines — nothing more.

⸻

1. Create Dedicated RDP Access Group

 Exact Command:

New-ADGroup -Name "wt2-cad-RDP" `
            -SamAccountName "wt2-cad-RDP" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path "OU=Security Groups,OU=TunnelOps,OU=Factory,DC=williamsf1,DC=com" `
            -Description "RDP access to WT2 CAD machines for TunnelOps team (3 machines only)"


2. Add the 10 Approved Users to the Group

 Exact Command:

$users = @(
    "steve.buckley",
    "kevin.morris",
    "peter.watson",
    "duncan.martin",
    "richard.lane",
    "sophie.james",
    "tony.fields",
    "linda.ashley",
    "mark.evans",
    "ian.hobbs"
)

foreach ($u in $users) {
    Add-ADGroupMember -Identity "wt2-cad-RDP" -Members $u
}


3. Add the Group to the Local “Remote Desktop Users” Group on the 3 CAD Machines

 Per Machine Command (Run as Admin):

Add-LocalGroupMember -Group "Remote Desktop Users" -Member "WILLIAMS\wt2-cad-RDP"

Repeat for each CAD machine:
CAD-WT2-01, CAD-WT2-02, CAD-WT2-03

4. Block All Other Logins to Those Machines Except IT Admins

 Use GPO or Local Security Policy (if no central GPO):
•	On each CAD machine:
•	Open secpol.msc
•	Go to:
•	Local Policies → User Rights Assignment
•	Allow log on through Remote Desktop Services
•	Replace any wildcard groups (e.g., Domain Users) with:
•	WILLIAMS\wt2-cad-RDP
•	Domain Admins (or your IT admin group)

 This ensures only your RDP group and IT can RDP in.

⸻

5. Disable Unwanted Interactive Logins (Optional but Recommended)

To prevent anyone from logging in locally (keyboard/mouse) except admins:
•	Local Policy → Deny log on locally
•	Add wt2-cad-RDP

 This prevents someone walking up and logging in, while still allowing remote RDP for TunnelOps.

⸻

6. Audit and Lock Visibility

Ensure the CAD machines:
•	Are not part of general access groups
•	Are in their own OU if GPO targeting is needed
•	Have RDP firewall ports open internally via Group Policy

Verify with:

Get-LocalGroupMember -Group "Remote Desktop Users"

and confirm only:
•	WILLIAMS\wt2-cad-RDP
•	DOMAIN\Admins


Final Test Instruction

On a TunnelOps user’s machine:
1.	Attempt to RDP into one of the CAD boxes — should succeed
2.	Attempt from a user not in the group — should fail
3.	Confirm login events in the CAD machine’s Event Viewer under:
•	Security logs → Event ID 4624 (successful logon) or 4625 (failed)

Summary Snapshot

AD Group Name
wt2-cad-RDP
Users Allowed
10 named TunnelOps engineers
Machines Affected
CAD-WT2-01, CAD-WT2-02, CAD-WT2-03
Login Type Allowed
RDP only
Local Group Membership
Remote Desktop Users
Logon Restriction
Local login denied (optional)
Audit Visibility
Enabled via Event Viewer


