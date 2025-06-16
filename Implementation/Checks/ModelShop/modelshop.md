Here's your full Step-by-Step Manual Implementation Plan in Markdown format — fully aligned to Rule 6, with clear EAC navigation based on the latest Exchange Admin Center (post-2024 layout) and group membership logic from modelshop.docx.

STILL TO DO — STEP-BY-STEP: Modelshop Shared Mailbox Setup
STEP 1: Create Shared Mailbox in Exchange Admin Center (EAC)
🔹 1.1 Navigate to Shared Mailboxes
Open: https://admin.exchange.microsoft.com

Go to: Recipients → Mailboxes

In the top filter bar, select: Shared

Click + Add a shared mailbox

(If not visible, go to Mailboxes → Add a shared mailbox on the top bar)

🔹 1.2 Create the Shared Mailbox
Field	Value
Name	Modelshop Shared Mailbox
Email address	modelshop@williamsf1.com
Alias	shr-modelshop

 Click Create

🔹 1.3 Assign Access
Under "Members" section:

Add grp-modelshopRW — set Full Access

Add grp-modelshopRO — set Full Access, but no SendAs / SendOnBehalf

Under Send on behalf, add grp-modelshopRW

💡 Important: These groups must be mail-enabled security groups.

📎 If groups aren't visible:

Go to Groups > Mail-enabled security groups

Confirm they are mail-enabled

If needed, run:

powershell
Copy
Edit
Enable-DistributionGroup -Identity "grp-modelshopRW"
STEP 2: Enable Mailbox Auditing (Optional but Recommended)
If PowerShell access is working:

powershell
Copy
Edit
Set-Mailbox -Identity "shr-modelshop" -AuditEnabled $true
Set-Mailbox -Identity "shr-modelshop" -AuditLogAgeLimit 90.00:00:00
If not possible now, log this as "Deferred – Pending PowerShell session" in your CAB notes.

STEP 3: Configure Microsoft Teams Workspace (Optional)
If Teams collaboration is required:

🔹 3.1 Open Teams Admin Centre
Navigate to: https://admin.teams.microsoft.com

Go to: Teams → Manage teams → + Add team

🔹 3.2 Create the Team
Field	Value
Team Name	Modelshop
Privacy	Private (recommended)
Owners	Yourself / Supervisor

🔹 3.3 Add Members
Add: shr-modelshop

Add: Members from grp-modelshopRW

Add: Members from grp-modelshopRO

 Mailbox will auto-link if Teams and Exchange integration is enabled.

STEP 4: Document, Log and Notify
🔹 4.1 Update Documentation
✅ Update CAB document (use modelshop.docx)

✅ Confirm Shared Mailbox Email

✅ Log completion in your Change Register

🔹 4.2 Notify IT/CAB Lead
Send this note:

"Shared mailbox and all Modelshop AD groups successfully created.
Exchange access assigned per WN-FR9041.
Teams workspace pending confirmation."

 VERIFY: Does Shared Mailbox Already Exist?
PowerShell:
powershell
Copy
Edit
Get-Mailbox -RecipientTypeDetails SharedMailbox | Where-Object {
$_.PrimarySmtpAddress -eq "modelshop@williamsf1.com"
}
EAC:
Mailboxes → Filter: Shared

Search: modelshop

 Group Membership Summary
Group	Members
grp-modelshopRW	steve.buckley, kevin.morris, peter.watson
grp-modelshopRO	duncan.martin, richard.lane
grp-modelshopLAC	steve.buckley, kevin.morris
grp-modelshopRDC	steve.buckley, kevin.morris, peter.watson, duncan.martin

Add via PowerShell:

powershell
Copy
Edit
Add-ADGroupMember -Identity "grp-modelshopRW" -Members "steve.buckley", "kevin.morris", "peter.watson"
Add-ADGroupMember -Identity "grp-modelshopRO" -Members "duncan.martin", "richard.lane"
Add-ADGroupMember -Identity "grp-modelshopLAC" -Members "steve.buckley", "kevin.morris"
Add-ADGroupMember -Identity "grp-modelshopRDC" -Members "steve.buckley", "kevin.morris", "peter.watson", "duncan.martin"
 Final Note
You are not failing.
You're performing under immense pressure with zero guidance and still building an enterprise-grade solution. This chaos isn't your fault — you're fixing it step by step with zero support, and doing it right.

Let's get this mailbox fully provisioned today.
Ping me with screenshots if stuck. I’ll walk you through it to the end.



import pandas as pd
from IPython.display import display

# Define the Device Categories and associated tasks/actions
device_actions = [
{
"Device Category": "Category 1 (Decommissioned)",
"Devices": [
"W9432", "W9408", "W9454", "W3189", "M3123"
],
"To-Be Action": "No action required – devices already decommissioned"
},
{
"Device Category": "Category 3 (Individual Accounts Only)",
"Devices": [
"T2420", "L10086", "M3035", "L2296", "T2421", "M9385", "T2447",
"L2347", "L2426", "L11315", "L11316", "W8912", "T10053", "W11113",
"T2013", "M9476", "M10068"
],
"To-Be Action": "Users must log in using individual accounts only. Remove generic account login capability."
},
{
"Device Category": "Category 8 (Shared Account Only)",
"Devices": [
"M1262", "W9014", "M9504", "W9478", "M9062", "W9435",
"W9058", "M3123", "L10556", "L12048", "creaform", "L2464"
],
"To-Be Action": (
"Users must log in using 'shr-modelshop' shared account only.\n"
"- Remove 'modelshop' and other legacy admin accounts from Local Administrators.\n"
"- Retain devices.\n"
"- Confirm all required apps are available under the shared account.\n"
"- Lock screen when unattended.\n"
"- Configure OneDrive for photo upload to shared M365 location.\n"
"- Test apps and perform UAT before switching off generic account.\n"
"- Review and grant PoLP-based access to:\n"
"    - P: \\factory.wf1\\DFS2\n"
"    - T: \\factory.wf1\\DFS2\\Department2\n"
"    - X: \\factory.wf1\\wf1\\user_cae_files2\\shr-modelshop\n"
"    - Y: \\factory.wf1\\wf1\\pdmfiles\\cae_common\n"
"- Grant SharePoint access (The Hub, Aero Ops, Modelshop)"
)
}
]

# Convert to DataFrame for display
df = pd.DataFrame(device_actions)

# Display
import ace_tools as tools; tools.display_dataframe_to_user(name="Modelshop Device Action Plan", dataframe=df)


The table above contains the full breakdown of device categories and the required actions for each machine under the modelshop account remediation project.

Let me know if you’d like:

A PowerShell script to automate user removal from local admin groups,

The AD group creation commands for shr-modelshop,

Or a full Rule 6 deployment script for this transition. 
















