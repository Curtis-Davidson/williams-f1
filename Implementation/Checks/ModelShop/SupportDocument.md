# Modelshop Shared Account Transition – Support Summary
**Project:** Shared Account Remediation  
**Location:** Modelshop Department, WF1 Campus  
**Date:** 01/08/2025  
**Prepared by:** Paul Davidson  
**Account ID:** `shr-modelshop`  
**Status:** Implemented and Active

---

## 1. Purpose of Change

Transition Modelshop from using a legacy `modelshop` generic account to a secured, access-controlled shared account (`shr-modelshop`).  
This change supports operational collaboration while aligning with current IT security policies and auditability requirements.

---

## 2. Overview of Changes

- Created and implemented `shr-modelshop` as the official shared account for Modelshop collaboration.
- Disabled legacy `modelshop` account across all devices post-UAT.
- Users now log in with:
    - **Individual accounts** on standard workstation devices (Category 3).
    - `shr-modelshop` on shared/team-based machines (Category 8).
- Keeper MFA vault and shared email/Teams access configured.

---

## 3. Devices Using `shr-modelshop` (Category 8)

The following machines are now restricted to the `shr-modelshop` account:

- **M1262**, **W9014**, **M9504**, **W9478**, **M9062**, **W9435**, **W9058**
- **M3123**, **L10556**, **L12048**, **creaform**, **L2464**

Standard setup for these devices includes:
- Access to required apps (e.g. Teamcenter, NX, Creaform VX, PolyWorks).
- Persistent internet connection (DHCP).
- Standardised OneDrive and SharePoint paths.
- Locked screen policy when unattended.
- Local admin cleanup per security guidance.

---

## 4. Scanning Laptops (Modelshop & TunnelOps)

The following devices are used for **Creaform scanning and dimensional analysis**. These are mobile and shared between **Modelshop** and **TunnelOps**:

- **creaform** (confirmed dedicated scanning machine)
- **L10556**, **L12048**, **L2464** (laptops used for scanning workflows)

These devices:
- Run **Creaform VX**, **PolyWorks**, and other scan-aligned applications
- Require uninterrupted network access and OneDrive sync
- Should not have login scope restricted beyond current GPO settings
- Must remain operational for portable scanning activities and cross-departmental use

---

## 5. Access Groups and Controls

**AD Groups Implemented:**
- `grp-modelshopRW` – Read/Write access to network drives
- `grp-modelshopRO` – Read-only access
- `grp-modelshopLAC` – Login access control for shared devices
- `grp-modelshopRDC` – Remote desktop access for designated users

**Login Configuration:**
- Only users in `grp-modelshopLAC` may log into Category 8 devices using `shr-modelshop`.
- RDC allowed only for:
    - **Mark Peers**
    - **Julian Davies**

---

## 6. Shared Account Configuration

**Account Name:** `shr-modelshop`  
**Password Policy:** 12-month rotation, stored in Keeper  
**OU Path:** `OU=Shared,OU=WilliamsF1,DC=williams,DC=f1`

**Email Setup:**
- Shared mailbox: `modelshop@williamsf1.com`
- Accessible alongside personal mailbox for assigned users

**MS Teams:**
- Full Teams functionality enabled for `shr-modelshop`
- Includes meetings, chat, collaboration

---

## 7. Drive and App Access

**Mapped Network Drives:**
- `P:\WTData → \\factory.wf1\DFS2`
- `T:\ → \\factory.wf1\DFS2\Department2`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\shr-modelshop`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\cae_common`

**SharePoint Access:**
- The Hub: [SPC-TheHub](https://williamsf1.sharepoint.com/sites/SPC-TheHub/)
- Aero Ops: [AeroOps1](https://williamsf1.sharepoint.com/sites/AeroOps1)
- Modelshop: [ModelShop](https://williamsf1.sharepoint.com/sites/ModelShop)

**Apps Enabled:**
- All apps previously tied to `modelshop` are now configured under `shr-modelshop`
- MS Office, Teams, PolyWorks, NX, Creaform, Mini Laser, mPART, WTTP, Teamcenter

---

## 8. Keeper Access & Account Custodians

The password and MFA credentials for the `shr-modelshop` shared account are stored securely in **Keeper**, and are managed in line with the IT Support team's secure vault policies.

Access to the Keeper vault entry is delegated to the following contacts:

- **Mark Peers** – Modelshop Process Manager
- **Paul Fishwick** – Shift Supervisor
- **Mark Crane** – Shift Supervisor
- **Julian Davies** – Senior Operator (Modelshop Scanning Lead)

These four individuals are responsible for managing the shared account login across shifts and ensuring continuity of access.

---

## 9. Device Administrator Cleanup

Accounts removed from local administrators:
- Legacy account `modelshop`
- Aero Local Admins group
- User-specific elevated accounts no longer needed (e.g. `Julian.Davies`, `Mario.Reynolds`, `mloveridge`)

All device-specific removals logged in internal system and executed via GPO/Ansible.

---

## 10. Data & Migration Tasks

- Files from old `modelshop` OneDrive and folders migrated to `shr-modelshop` OneDrive
- Team members now save photos directly to M365 storage via configured endpoints
- Any apps tied to legacy paths were reconfigured under the new account

**Local File Access Transition:**
On all devices where `shr-modelshop` has replaced `modelshop`:
- `shr-modelshop` has been granted read/write access to the previous `modelshop` local user directory (e.g. `C:\Users\modelshop`)
- A desktop shortcut pointing to this folder has been created on each machine
- This allows users to access and retrieve any files from the previous configuration
- This is intended as a **temporary transition measure only** – if a device is rebuilt, those local files may no longer be available
- Users have been advised to copy any needed files into OneDrive or network locations

---

## 11. Rollback & Contingency

If rollback required:
- Temporary reactivation of `modelshop` can be performed under IT supervision
- Previous drive permissions and app configs retained for limited fallback period

---

## 12. Validation Summary

All the following were confirmed:
- Drive access confirmed ✅
- Apps and licensing functional under new login ✅
- Teams and Email operational ✅
- RDC and login restrictions functioning as scoped ✅
- Devices successfully tested by end users ✅

---

## 13. Next Steps

- Monitor usage of `shr-modelshop` and audit authentication logs
- Review user feedback after 30 days for potential refinements
- Finalise UAT sign-off and archive legacy configuration notes

---