# 🗂 CAB Change Submission – Cleanroom Account Migration

##  Title
Decommission of Generic Cleanroom Account (`f1cleanroom`) and Implementation of Named User Access

---

##  Executive Summary

This change will retire the shared `f1cleanroom` account used on all Cleanroom PCs and transition to named user accounts. The aim is to eliminate shared credentials, enforce security compliance, and restore audit traceability in a critical production environment.

This change affects 4–5 Composites Cleanroom operators and is non-disruptive if executed in sequence. Existing data and shortcuts will be preserved, and shared mailbox access will remain available via delegation.

---

##  Justification for Change

###  Problem:
- The generic `f1cleanroom` account is used by multiple users without traceability.
- It remains permanently signed into Outlook and MS Teams, creating an identity spoofing and data loss risk.
- This approach is not inline with Williams Cybersecurity & Audit policies.

###  Solution:
- Migrate all users to named AD accounts.
- Reconfigure Cleanroom PCs to accept only authorised named logins.
- Migrate files and configure email/Teams on a per-user basis.
- Decommission shared account once all users are functional.

---

##  Nature of Change

| Type        | Value                |
|-------------|----------------------|
| Change Type | Scheduled Change     |
| Priority    | Medium (policy compliance) |
| Impact      | Low                  |
| Risk        | Low (with staged rollout) |
| Duration    | Approx. 2–3 days total (can be phased by shift) |

---

##  Technical Implementation Plan

###  Step 1: Confirm Users
- [ ] Get final user list from Composites Manager
- [ ] Validate AD accounts exist or create new ones:
    - Liam Bragg
    - Myles Jones
    - 2–3 other staff (TBC)

###  Step 2: Prepare Devices
- [ ] Restrict login rights on:
    - `W10815` (main PC)
    - `W8991` (secondary PC)
    - `W8714` (if still in use)
- [ ] Remove `f1cleanroom` from login rotation

###  Step 3: SharePoint & Files
- [ ] Backup & migrate files from `C:\Users\f1cleanroom\Documents\`
- [ ] Upload to Cleanroom SharePoint team folder
- [ ] Recreate relevant shortcuts in each user’s profile

###  Step 4: Email & Teams
- [ ] Configure Outlook for each user:
    - Personal mailbox
    - Delegate access to `f1cleanroom@williamsf1.com` (if required)
- [ ] Log into MS Teams as personal accounts
    - Join Cleanroom team/channel

###  Step 5: Printing
- [ ] Confirm access to Cleanroom printers from named accounts

###  Step 6: Decommission `f1cleanroom`
- [ ] Disable in AD after full testing
- [ ] Retain only on emergency terminal if required
- [ ] Remove from all AD groups (except backup group if defined)

---

##  Rollback Plan

If login issues or access problems arise:

1. Re-enable `f1cleanroom` account in AD
2. Temporarily restore login rights on Cleanroom PCs
3. Revert Outlook and Teams login to shared account for affected users
4. Troubleshoot individual profile issues before retrying named user rollout

Rollback Time Estimate: **~30 minutes per PC**

---

##  Communication Plan

- **Staff notification:** Cleanroom staff to be briefed in person + via printed one-pager at terminals
- **Manager sign-off:** Required before account deactivation
- **Support availability:** IT support available during all shifts for login assistance

---

##  Validation / Testing

| Component        | Test Criteria                                |
|------------------|----------------------------------------------|
| Login            | Each user can log in to all designated PCs   |
| File access      | Users can access all Cleanroom docs on SharePoint |
| Email            | Outlook functional (personal + shared access) |
| Teams            | Users logged in, joined to Cleanroom channel |
| Printing         | All print devices accessible via named accounts |

---

##  Compliance Note

This change directly enforces:
- Cybersecurity policy (no shared logins)
- User identity traceability
- Audit & compliance requirements

---

##  Change Owner
**Name:** Curtis-Davidson  
**Department:** Infrastructure  
**Email:** [Add yours]  
**Date Submitted:** [Add Date]

---

##  Attachments

- [x] Implementation.md (full execution tracker)
- [x] Cleanroom team user list (TBC from Composites Manager)
- [x] Screenshots of device logins (optional)
- [x] Post-migration confirmation sheet

