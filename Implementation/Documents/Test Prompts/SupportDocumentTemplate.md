# [Department/Project Name] – Shared Account Transition – Support Summary

**Project:** Shared Account Remediation  
**Location:** [Department / Campus]  
**Date:** [DD/MM/YYYY]  
**Prepared by:** [Engineer Name]  
**Account ID:** **`[shr-account-name]`**  
**Status:** Implemented and Active

---

## 1. Purpose of Change
[Why this account exists, what it replaces, and its operational role.  
e.g., “New shared account for Kit Cutting area replacing legacy `kitops`. Provides secure, auditable access to shared devices and mapped drives.”]

---

## 2. Overview of Changes
- [Action 1: Created new shared account `shr-xxxx`]
- [Action 2: Disabled legacy `oldaccount`]
- [Action 3: Configured Keeper entry / MFA / shared mailbox]
- [Action 4: Applied OU policies / login restrictions]

---

## 3. Devices Using **`[shr-account-name]`**
[List devices restricted to this account, with device IDs + description]
- **W1234** – CAD workstation
- **M5678** – CNC controller

---

## 4. Shared Account Configuration
**Account Name:** `[shr-account-name]`  
**Password Policy:** [12-month rotation / no expiry / Keeper only]  
**OU Path:** `[OU=!Shared Accounts,OU=Factory,...]`  
**Email/Teams Setup:** [Mailbox created / Teams access enabled / N/A]

---

## 5. Access Groups and Controls
- `grp-[dept]LAC` – Login Access Control
- `grp-[dept]RW` – Read/Write drive access
- `grp-[dept]RO` – Read-only drive access
- `grp-[dept]RDC` – Remote Desktop access (if applicable)

[Clarify: Restrictions applied directly on AD object or via groups.]

---

## 6. Keeper Access & Custodians
Account credentials and MFA stored in Keeper. Access granted to:
- [Name – Role]
- [Name – Role]
- [Name – Role]

---

## 7. Drive and Application Access
**Mapped Drives:**
- `T:\ → \\factory.wf1\DFS2\[DeptShare]`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\[shr-account]`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\common`

**Applications Verified:**
- [List key applications e.g., CAD, CAM, CNC tools]

**SharePoint/OneDrive:**
- [Relevant SharePoint sites or M365 syncs]

---

## 8. Exceptions / Special Cases
[Document any exemptions: kiosk policy, USB exceptions, scanning/printing overrides, etc.]

---

## 9. Policy & Admin Notes
- Legacy account `[oldaccount]` disabled
- Local admin rights removed (except IT)
- Confirmed GPO enforcement (password, lockout, inactivity timeout)
- [Other admin/security notes]

---

## 10. Data & Migration Tasks
- Files migrated from `[oldaccount]` → `[shr-account]`
- Desktop shortcuts created for legacy data (`C:\Users\oldaccount`)
- Temporary access available until rebuilds (note risk of data loss on reimage)

---

## 11. Validation Summary
**Validation Performed by:**
- [Business Owner – Role]
- [Engineer – Name]

**Activities:**
- Verified login on scoped devices
- Tested mapped drives
- Confirmed app licensing under new account
- Tested printing/scanning/USB workflows
- Confirmed OneDrive/SharePoint sync
- [Other checks]

**Result:** ✅ All tests passed. Account active and production-ready.

---