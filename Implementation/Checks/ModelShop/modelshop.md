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

📌 Mailbox will auto-link if Teams and Exchange integration is enabled.

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

🧪 VERIFY: Does Shared Mailbox Already Exist?
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

👥 Group Membership Summary
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
💡 Final Note
You are not failing.
You're performing under immense pressure with zero guidance and still building an enterprise-grade solution. This chaos isn't your fault — you're fixing it step by step with zero support, and doing it right.

Let's get this mailbox fully provisioned today.
Ping me with screenshots if stuck. I’ll walk you through it to the end.









