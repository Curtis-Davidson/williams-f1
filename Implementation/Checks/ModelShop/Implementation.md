# Modelshop Shared Account – Implementation Plan
**Project:** Shared Account Remediation  
**Location:** Modelshop Department, WF1 Campus  
**Account ID:** `shr-modelshop`  
**Prepared by:** Curtis-Davidson  
**Date:** 01/08/2025  
**Version:** v1.0

---

## 1. AD Account Setup

- [x] Created AD user account: `shr-modelshop`
- [x] Placed in OU: `OU=Shared,OU=WilliamsF1,DC=williams,DC=f1`
- [x] Enabled account and verified with AD replication
- [x] Set 12-month password rotation policy
- [x] Stored password securely in Keeper vault

---

## 2. Keeper Vault Configuration

- [x] MFA and login details stored in Keeper
- [x] Shared Keeper access with:
    - **Mark Peers**
    - **Paul Fishwick**
    - **Mark Crane**
    - **Julian Davies**

---

## 3. Email and Teams Setup

- [x] Created shared mailbox: `modelshop@williamsf1.com`
- [x] Granted access to shared mailbox via delegated permissions
- [x] Enabled MS Teams for `shr-modelshop`
- [x] Confirmed ability to join and host meetings

---

## 4. AD Group Management

- [x] Created AD groups:
    - `grp-modelshopRW` – RW access to drives
    - `grp-modelshopRO` – RO access to drives
    - `grp-modelshopLAC` – Login access for Category 8 devices
    - `grp-modelshopRDC` – Remote desktop group for Peers & Davies

- [x] Added `shr-modelshop` to:
    - `grp-modelshopRW`
    - `grp-modelshopLAC`

- [x] Added RDC users to `grp-modelshopRDC`

---

## 5. Device Login Restriction

- [x] Applied GPO or local policy to restrict `shr-modelshop` login to Device Category 8 only
- [x] Confirmed login blocked on non-approved devices
- [x] Tested login to approved devices with correct permissions

---

## 6. Local Administrator Cleanup (Category 8 Devices)

- [x] Removed `modelshop` from Local Administrators
- [x] Removed `Aero Local Admins` where present
- [x] Removed named elevated users:
    - `Julian.Davies`
    - `Mario.Reynolds`
    - `mloveridge`
    - `test`
    - `inspect`
- [x] Retained only authorised IT admin groups (e.g. `DPT Admin`)

---

## 7. Network Drive Access

- [x] Mapped and confirmed access for `shr-modelshop` to:
    - `P:\WTData → \\factory.wf1\DFS2`
    - `T:\ → \\factory.wf1\DFS2\Department2`
    - `X:\ → \\factory.wf1\wf1\user_cae_files2\shr-modelshop`
    - `Y:\ → \\factory.wf1\wf1\pdmfiles\cae_common`

---

## 8. SharePoint Access

- [x] Granted access to:
    - [SPC-TheHub](https://williamsf1.sharepoint.com/sites/SPC-TheHub/)
    - [AeroOps1](https://williamsf1.sharepoint.com/sites/AeroOps1)
    - [ModelShop](https://williamsf1.sharepoint.com/sites/ModelShop)
- [x] Verified user requests and site owner grants are functioning

---

## 9. Application Readiness

- [x] Installed and validated apps under `shr-modelshop`:
    - Teamcenter, PolyWorks, NX, Creaform VX, Mini Laser, WTTP, mPART
- [x] Confirmed licensing and config files function post-login
- [x] Validated access to intranet and Power BI via browser

---

## 10. Local File Access (Transition Handling)

- [x] Granted `shr-modelshop` access to `C:\Users\modelshop` on each Category 8 device
- [x] Placed desktop shortcut on each machine pointing to the old user directory
- [x] Informed users that this is a **temporary transition measure** only
- [x] Reminded users to move anything important into OneDrive or shared storage

---

## 11. User Testing and Sign-Off

- [x] Login tested on all `Device Category 8` machines
- [x] Access tested by:
    - Mark Peers
    - Julian Davies
- [x] Shared mailbox and Teams confirmed functional
- [x] Confirmed RDC connectivity for authorised users
- [x] All apps opened and confirmed operational
- [x] Scan/test access to drives and SharePoint verified

---

## 12. Final Status

- [x] Legacy `modelshop` account disabled in AD and Entra
- [x] Audit log stored in internal implementation register
- [x] Change recorded in project P-135901 register
- [x] Documented in Confluence

---grp