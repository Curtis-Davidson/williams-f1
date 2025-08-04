Delegation Setup Instructions
1. Create the AD Group
   This is done in Active Directory before anything in uniFLOW.

Exact command (PowerShell AD):

powershell
Copy
Edit
New-ADGroup -Name "GRP-MACHINE-MFG-DELEGATES" -GroupScope Global -Path "OU=PrintGroups,DC=williams,DC=local"
Add users to group:

powershell

Add-ADGroupMember -Identity "GRP-MACHINE-MFG-DELEGATES" -Members user1,user2,user3
Test group membership:

powershell

Get-ADGroupMember "GRP-MACHINE-MFG-DELEGATES"
2. Log into uniFLOW Management Console
   URL usually: http://<uniflow-server>:<port>/uniflow

Log in with admin credentials

3. Force AD Group Sync in uniFLOW (if needed)
   Go to Configuration → Data Sources

Select your Active Directory source

Click "Synchronise Now"

Wait for sync to complete (~2–5 minutes)

Confirm group exists:

Go to User Management → Groups

Search for: GRP-MACHINE-MFG-DELEGATES

4. Configure Delegation from SHR-MACHINE-MFG to Group
   Go to: User Management → Users

Search for: SHR-MACHINE-MFG

Click into the user profile

Inside SHR-MACHINE-MFG:
Navigate to: Delegation or Delegated Print Job Access

(Tab name may vary: some versions say “Print Job Delegation”)

Click Add Group

Search: GRP-MACHINE-MFG-DELEGATES

Select and add it as a delegate

Set delegation permissions:


✓ View Jobs
✓ Release Jobs
(Optional) ✓ Delete Jobs
Click Save or Apply

5. Confirm Delegation is Active
   Go to: Reports → User Delegation

Check that GRP-MACHINE-MFG-DELEGATES is listed as a delegate for SHR-MACHINE-MFG

6. Test Functionality
   From any user in GRP-MACHINE-MFG-DELEGATES:

Send a print job to \\printserver\Canon-Secure-Queue (logged in as SHR-MACHINE-MFG)

Walk to any Canon printer

Swipe personal access card

Confirm visibility and ability to release jobs submitted by SHR-MACHINE-MFG

 Optional Enhancements
Enable logging so all released jobs still show under user ID (for audit)

Tie GRP-MACHINE-MFG-DELEGATES to the same cost centre for billing

Use group-based policies for card authentication or device access control

 Result
All 40+ users can now use their own cards to access the shared queue.

No session conflicts.

Print job ownership remains clean and accountable.

Easy group-based management moving forward.



Canon uniFLOW – Delegated Print Job Access Overview

Canon uniFLOW allows the delegation of print jobs to both:

Individual AD users

Active Directory (AD) groups

This feature enables secure job sharing, allowing authorised colleagues or teams to:

View

Release

(Optionally) Delete

print jobs originally submitted by another user or shared account (e.g. SHR-MACHINE-MFG).

This is particularly useful in environments with:

Shared departmental accounts

Rotating staff (e.g. shift-based access)

