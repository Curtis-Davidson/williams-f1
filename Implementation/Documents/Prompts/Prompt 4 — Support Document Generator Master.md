# [Department/Project Name] – Shared Account Transition – Support Summary
**Project:** Shared Account Remediation  
**Location:** [Department / Campus]  
**Date:** [DD/MM/YYYY]  
**Prepared by:** [Engineer Name]  
**Account ID:** **`[shr-account-name]`**  
**Status:** Implemented and Active

---

## 1. Purpose of Change
[Short explanation: Why this account exists, what it replaces, and its operational role.]

---

## 2. Overview of Changes
- [Action 1: eg, Created new shared account `shr-xxxx`]
- [Action 2: eg, Disabled legacy `oldaccount`]
- [Action 3: eg, Configured Keeper entry / MFA / shared mailbox]

---

## 3. Devices Using **`[shr-account-name]`**
[List devices restricted to this account. Example:]
- **W1234** – [device description]
- **M5678** – [device description]

---

## 4. Shared Account Configuration
**Account Name:** `[shr-account-name]`  
**Password Policy:** [12-month rotation / no expiry, etc.]  
**OU Path:** `[OU=!Shared Accounts,OU=Factory,...]`  
**Email/Teams Setup:** [Mailbox / Teams access if enabled]

---

## 5. Access Groups and Controls
- `grp-[dept]LAC` – Login Access Control
- `grp-[dept]RW` – Read/Write drive access
- `grp-[dept]RO` – Read-only drive access
- `grp-[dept]RDC` – Remote Desktop access (if applicable)

[Explain if restrictions are applied directly on the AD user object or via groups.]

---

## 6. Keeper Access & Custodians
Account credentials and MFA are stored in Keeper. Access granted to:
- [Name, Role]
- [Name, Role]
- [Name, Role]

---

## 7. Drive and Application Access
**Mapped Drives:**
- `T:\ → \\factory.wf1\DFS2\[DeptShare]`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\[shr-account]`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\common`

**Applications:**  
[List applications verified under this account, e.g. CAD, CAM, CNC tools.]

**SharePoint/OneDrive Integration:**  
[List relevant SharePoint sites, OneDrive folders, or M365 syncs.]

---

## 8. Exceptions / Special Cases
[Document any exemptions: USB policy exclusions, kiosk PCs exempt from screen lock, admin overrides for scanning, etc.]

---

## 9. Policy & Admin Notes
- Legacy account `[oldaccount]` disabled
- Local admin rights removed (except IT)
- Confirmed GPO enforcement for screensaver lock, password complexity, inactivity timeout
- [Any additional notes]

---

## 10. Data & Migration Tasks
- Files migrated from `[oldaccount]` → `[shr-account]`
- Desktop shortcuts created for legacy data access (`C:\Users\oldaccount`)
- Temporary access available until rebuilds (note risk of data loss on reimage)

---

## 11. Validation Summary
Validation performed by:
- [Business Owner Name – Role]
- [Engineer Name]

**Validation Activities:**
- Verified application access (list key apps)
- Confirmed licensing (no errors under new account)
- Tested drive mappings (all accessible as expected)
- Checked login restrictions (only scoped devices allow access)
- Tested printing/scanning/USB workflows (if relevant)
- Confirmed OneDrive/SharePoint sync
- [Other validation steps]

**Result:** All tests passed successfully. Environment confirmed as production-ready.

---