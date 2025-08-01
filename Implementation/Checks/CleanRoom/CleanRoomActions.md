Executive Summary: Cleanroom Account (f1cleanroom)
Decision	Migrate away from generic f1cleanroom account
Action Required	Create individual user accounts + enforce login on shared devices
Users Impacted	~4–5 Composites Cleanroom Operators

📍 Devices Affected
W10815 – Cleanroom PC

W8991 – Secondary PC in same space

W8714 – Previously used; confirm status

W9075 – Possibly phased out

🔍 Why Change?
f1cleanroom account is used by anyone — zero traceability

Email still logged in (!)

MS Teams/SharePoint used under the shared identity

No access control, no individual responsibility

Contravenes Williams cyber and audit policies

🧠 Core Issue: Culture, not Tech
This isn't a technical limitation. It's muscle memory and "easier this way" thinking.

The users can log in with their own credentials, but:

It’s slower

They're used to shared desktop experience

They don’t see why it matters

🎯 Final Implementation Plan
✅ Step 1: Create Individual Logins
Users include:

Liam Bragg

Myles Jones

Additional 2–3 staff (TBC by manager)

Each user must have a full AD account with:

Login rights to cleanroom devices

Access to Composites SharePoint/Teams folders

Their own mailbox + access to f1cleanroom@williamsf1.com if needed

✅ Step 2: Device Login Setup
Configure all cleanroom PCs to allow login by named users only

Remove f1cleanroom from login screen, or restrict to emergency use only

✅ Step 3: File & Shortcut Migration
Copy files from C:\Users\f1cleanroom\Documents\... to team SharePoint

Preserve shortcuts (cleanroom dashboard, inspection logs, etc.) into each new user profile

✅ Step 4: Outlook and Teams Config
Each user logs into:

Their own email account

Optionally granted access to f1cleanroom@williamsf1.com

MS Teams:

Log in under personal ID

Join cleanroom Teams channel

✅ Step 5: Printing
Ensure all shared printers work for logged-in users on both PCs

✅ Step 6: Decommission f1cleanroom
Only when:

All users are migrated

Outlook/Teams/file access works correctly

Printers tested

Then:

Disable account in AD or restrict login to one backup terminal

🔥 Challenges You'll Face
Challenge	Mitigation
“It was easier before”	Frame as security upgrade, not punishment
Inertia/reluctance	Do side-by-side walk-throughs with users
Manager pushback	Get them to authorise the final user list – and back the policy
Forgotten credentials	Pre-warn about password resets & delays – get IT to support early logins

✅ Task Tracker
markdown
Copy
Edit
## ✅ Cleanroom Account Migration – Implementation Tasks

### 🔹 User Accounts
- [ ] Confirm full list of cleanroom staff with manager
- [ ] Create AD accounts for all (if not already done)

### 🔹 Device Access
- [ ] Configure logins for:
    - W10815
    - W8991
    - (Optional) W8714
- [ ] Remove f1cleanroom from login rotation

### 🔹 Outlook/Email
- [ ] Setup Outlook for each user:
    - [ ] Personal mailbox
    - [ ] Shared: f1cleanroom@williamsf1.com (as secondary, if needed)

### 🔹 MS Teams
- [ ] Log into personal account
- [ ] Ensure cleanroom channel/team accessible

### 🔹 SharePoint Access
- [ ] Migrate all cleanroom docs from:
    - `C:\Users\f1cleanroom\Documents\...`
- [ ] Setup cleanroom team folder with edit access for all staff

### 🔹 Shortcuts/Local Files
- [ ] Recreate needed shortcuts in each user profile

### 🔹 Printing
- [ ] Confirm print access works for all users

### 🔹 Decommission Generic Account
- [ ] Disable or restrict f1cleanroom login
- [ ] Remove from all AD groups except legacy backup

🧠 Mental Reframe for You
You’re not fighting a tech issue — you’re resolving an identity and audit blind spot in a critical ops zone.

This is one of those jobs where no one thanks you unless something goes wrong — and then you’re the shield. That’s real infrastructure work.

If you want:

A PDF summary doc to send to manager for sign-off

A print-ready checklist for cleanroom rollout

A Teams post draft announcing the change and what users should expect












