# Modelshop Shared Account Transition – Support Summary
**Project:** Shared Account Remediation  
**Location:** Modelshop Department, WF1 Campus  
**Date:** 01/08/2025  
**Prepared by:** Paul Davidson  
**Account ID:** **`shr-modelshop`**  
**Status:** Implemented and Active

---

## 1. Purpose of Change

Transition Modelshop from using a legacy `modelshop` generic account to a secured, access-controlled shared account (**`shr-modelshop`**).  
This change supports operational collaboration while aligning with current IT security policies and auditability requirements.

---

## 2. Overview of Changes

- Created and implemented **`shr-modelshop`** as the official shared account for Modelshop collaboration.
- Disabled legacy `modelshop` account across all devices post-UAT.
- Users now log in with:
    - **Individual accounts** on standard workstation devices.
    - **`shr-modelshop`** on shared/team-based machines.
- Keeper MFA vault and shared email/Teams access configured.

---

## 3. Devices Using **`shr-modelshop`**

The following machines are now restricted to the **`shr-modelshop`** account:

- **M1262**, **W9014**, **M9504**, **W9478**, **M9062**, **W9435**, **W9058**
- **M3123**, **L10556**, **L12048**, **creaform**, **L2464**
  The shared account **SHR-MODELSHOP** has been restricted to log on only to the following machines as part of the shared account lockdown policy:

- **M1262**
- **M9062**
- **W9478**
- **M9504**
- **W9014**
- **W9435**
- **L2464** *(Creaform 1)*
- **L10556** *(Creaform 2)*
- **Creaform**
- **L12048** *(Creaform 3)*

These restrictions have been implemented to ensure secure, role-specific access and are aligned with our standardised shared account control framework. Any authentication attempts from machines outside this list will be denied at the domain controller level.


Standard setup for these devices includes:
- Access to required apps (e.g. Teamcenter, NX, Creaform VX, PolyWorks).
- Persistent internet connection (DHCP).
- Standardised OneDrive and SharePoint paths.
- Locked screen policy when unattended.
- Local admin cleanup per security guidance.

---

## 4. Exception – Creaform Scanning Laptops (Modelshop & TunnelOps)

The following devices are used for **Creaform scanning and dimensional analysis**. These are mobile and shared between **Modelshop** and **TunnelOps**:

- **creaform** (dedicated scanning machine)
- **L10556**, **L12048**, **L2464** (laptops used for scanning workflows)

### Usage
These devices:
- Run **Creaform VX**, **PolyWorks**, and other scan-aligned applications.
- Must remain operational for portable scanning activities and cross-departmental use.

### USB Exclusion for Licensing
These scanning laptops must retain **USB storage access** because the Creaform licensing system requires a USB device to be detected to validate and run the software.  
Any USB blocking policies must explicitly exclude these devices.

### Requirement
These laptops must remain **exempt from USB lockdown enforcement** via policy to support necessary USB peripherals.

### Reason
- **Licensing dependency:** The *Creaform VX* software relies on physical USB access for a hardware dongle to validate its license.
- **Hardware connectivity:** The scanning workflow requires a **USB-to-Ethernet network adapter** (USB-C), 
    enabling connection to a dedicated hardware controller or scanner. This adapter provides the IP-based link between the laptop and Creaform scanning hardware.
- **Operational necessity:** Without USB access, the scanner hardware—using that dedicated network link—would be unable to connect correctly, breaking both licensing authentication and scanning operations.

---

## 5. Access Groups and Controls

**AD Groups Implemented:**
- `grp-modelshopRW` – Read/Write access to network drives
- `grp-modelshopRO` – Read-only access
- `grp-modelshopLAC` – Login access control for shared devices
- `grp-modelshopRDC` – Remote desktop access for designated users when required

**Login Configuration:**
- **Note:** The `grp-modelshopLAC` AD group exists for login access control to shared devices; however, for this account (`shr-modelshop`), 
- the applied method was **direct logon restrictions at the user object level** (Logon tab) where permitted machine names were explicitly listed.

---

## 6. Shared Account Configuration

**Account Name:** `shr-modelshop`  
**Password Policy:** 12-month rotation, stored in Keeper  
**OU Path:** `OU=!Shared Accounts,OU=Factory,OU=Factory.WF1,DC=williams,DC=f1`

**Email Setup:**
- Standard Exchange mailbox: `shr-modelshop@williamsf1.com`

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

The password and MFA credentials for the **`shr-modelshop`** shared account are stored securely in **Keeper**, and are managed in line with the IT Support team's secure vault policies.

Access to the Keeper vault entry is delegated to the following contacts:

- **Mark Peers** – Modelshop Manager
- **Paul Fishwick** – Shift Supervisor
- **Mark Crane** – Shift Supervisor
- **Julian Davies** – Senior Operator (Modelshop Scanning Lead)

These four individuals are responsible for managing the shared account login across shifts and ensuring continuity of access.

---

## 9. Device Administrator

**Local Administrator Context:**  
Julian Davies has a dedicated administrator account (`adminjdavies`) provisioned to support cross-departmental collaboration between **TunnelOps** and **Modelshop** for scanning operations and wind tunnel testing.  
Due to the nature of these activities — particularly **out-of-hours wind tunnel runs** — there are occasions where scanning software or related applications may encounter issues when no IT support is on-site.  
Local administrator rights ensure Julian can perform immediate troubleshooting and resolution to maintain operational continuity during these critical, time-sensitive processes.

---

## 10. Data & Migration Tasks

- Files from old `modelshop` OneDrive and folders migrated to `shr-modelshop` OneDrive
- Team members now save photos directly to M365 storage via configured endpoints
- Any apps tied to legacy paths were reconfigured under the new account

**Modelshop iPhone – OneDrive Photo Integration:**  
The Modelshop operates an iPhone that is enrolled in **Intune** and linked directly to the `shr-modelshop` OneDrive account.  
The device is configured to automatically sync captured photos to the shared OneDrive. 
This setup is used during testing and model photography, ensuring that all images are immediately available under the `shr-modelshop` OneDrive **Photos** directory.  
Any authorised machine logged in with `shr-modelshop` will have automatic access to these synced images, 
enabling seamless viewing and utilisation of captured data across both Modelshop and TunnelOps operations.

**Local File Access Transition:**
On all devices where `shr-modelshop` has replaced `modelshop`:
- `shr-modelshop` has been granted read/write access to the previous `modelshop` local user directory (e.g. `C:\Users\modelshop`)
- A desktop shortcut pointing to this folder has been created on each machine
- This allows users to access and retrieve any files from the previous configuration
- This is intended as a **temporary transition measure only** – if a device is rebuilt, those local files may no longer be available
- Users have been advised to copy any needed files into OneDrive or network locations

---


## 11. Validation Summary

Post-implementation validation was completed jointly by Mark Peers, Julian Davies and Paul Davidson.  
Each device within scope was reviewed and tested to confirm full operational readiness under the **`shr-modelshop`** configuration.

### Validation activities included:
- **Application checks:** Verified Teamcenter NX, Microsoft Teams, and Exchange email functionality on all relevant devices.
- **Licensing confirmation:** Ensured all required applications operated correctly under the new shared account.
- **Drive access:** Confirmed network and local drive access in line with allocated permissions.
- **Login restrictions:** Validated that devices only allow **`shr-modelshop`** login, as scoped.
- **Scanning workflows:** Tested scanning laptops in a live Wind Tunnel environment to confirm hardware, Creaform VX connectivity, and USB/network adapter function.
- **Camera integration:** Verified that the Modelshop iPhone captured images and successfully synced them to the **`shr-modelshop`** OneDrive Photos directory, with access confirmed from all authorised devices.

All tests passed successfully, and the environment is confirmed as production-ready.
---



