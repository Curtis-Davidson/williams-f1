# Machine Shop Shared Account Transition – Support Summary
**Project:** Shared Account Remediation  
**Location:** Machine Shop, WF1 Campus  
**Date:** 01/08/2025  
**Prepared by:** Paul Davidson  
**Account ID:** **`shr-machine-mfg`**  
**Status:** Implemented and Active

---

## Key Contacts

- **Conner Murphy** – Metallic Manufacturing Manager
- **Simon Bunce** – Team Leader (Turning), point of contact for implementation support

These individuals supported, approved, and coordinated the transition to the **`shr-machine-mfg`** shared account.

---

## 1. Purpose of Change

Establish a secure shared account (**`shr-machine-mfg`**) for the Machine Shop to support shift-based collaborative access across designated terminals.  
This replaces legacy generic **CellA / CellB**, with **`shr-machine-mfg`** access-controlled, auditable identity.

---

## 2. Shared Account Configuration

**Account Name:** `shr-machine-mfg`  
**Password Policy:** 12-month rotation, stored in Keeper  
**OU Path:** `OU=!Shared Accounts,OU=Factory,OU=Factory.WF1,DC=williams,DC=f1`

**Email Setup:**
- Standard Exchange mailbox: **`shr-machine-mfg@williamsf1.com`**

## 3. Devices Using **`shr-machine-mfg`** 

The following eight machines are explicitly assigned to the shared Machine Shop account:

- **SEIKI21**
- **M8687**
- **W8841**
- **M3147**
- **M3104**
- **M1909**
- **M8662**
- **W9474**

Each device is:

- Configured for exclusive login by **`shr-machine-mfg`**
- Machine login lockdown applied on the AD user object itself (not via GPO or device OU)
- Group Policy enforced to restrict local user or domain user access
- Enrolled in the `grp-machine-mfgLAC` (Login Access Control) group
- Assigned the correct drive mappings and application permissions
- Under monitoring as part of the account remediation rollout

Legacy user directories remain temporarily accessible via desktop shortcut for document recovery and transition purposes.

---

## 4. Access Groups and Controls

**Active Directory Groups:**

- `grp-machine-mfgLAC` – Controls which devices **`shr-machine-mfg`** Please note: **lockdown applied on the AD user object**
- `grp-machine-mfgRW` – Provides mapped drive read/write access
- `grp-machine-mfgRDC` – Optional remote access group (if required later)

These are used to ensure minimal access surface, strict scope enforcement, and scalable management.

---

## 5. Keeper Access & Account Custodians

Password and MFA credentials for **`shr-machine-mfg`** are stored securely in **Keeper**, following IT security policy.

Access has been granted to the following team leaders across the full shift rotation:

- **Bleddyn Davies** – Team Leader, Milling (Mon–Thurs)
- **Simon Bunce** – Team Leader, Turning (Mon–Thurs)
- **Carl Smith** – Team Leader, Prototype Machine Shop (Mon–Thurs)
- **Ewan Divine** – Team Leader, Night Shift (Mon–Thurs)
- **Jon Othen** – Team Leader, Weekend Shift (Fri–Sun)
- **Steve Green** – Weekday Supervisor, Metallic Production

These custodians manage login issues, credential resets, and access control within their respective shifts.

---

## 6. Email and Teams Access

- **`shr-machine-mfg`** has **mailbox and Teams access**
- All comms are handled by team leads or personal accounts
- Shared mailbox can be provisioned later if required for workflow

---

## 7. Application and Drive Access

**Mapped Drives:**

- `T:\ → \\factory.wf1\DFS2\MachineShop`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\shr-machine-mfg`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\cae_common`

**Applications:**

- Relevant CAD tools, CNC interfaces, and shopfloor utilities
- Access tested across all 8 machines under the shared context

---

## 8. Canon uniFLOW – Multiple Card Support for `shr-machine-mfg`

Canon uniFLOW has been implemented to support secure printing across the **Milling** and **Turning** divisions of the Machine Shop, both of which use `shr-machine-mfg`.

Canon uniFLOW On-Premises has been configured to allow **multiple access cards** to be linked to the same AD account (`shr-machine-mfg`), enabling flexible, secure printer access across the **Milling** and **Turning** divisions.

Two dedicated Canon printers have been provisioned, with release access controlled via AD-integrated card readers.  
In the uniFLOW server database, the Card Registration Table stores multiple card IDs against the `shr-machine-mfg` account, so that any authorised card can release jobs without requiring separate logins.

**Configuration Highlights:**
- Multiple card IDs registered against a single user object in uniFLOW.
- Cards can be added via the **Authentication/Identification** tab in the uniFLOW Management Console (UMC).
- For versions supporting only one card in the main field, the **Additional Identification Numbers** feature is used to store the extra ID.
- No “session link” between cards — logging in with one does not log out another.
- Works across mixed card environments.

**Operational Benefits:**
- Supports over 40 users across shifts using their own cards.
- Eliminates card sharing while keeping print job access tied to the shared account.
- Reduces admin overhead for adding/removing user access.

Authorised cards can:
- View
- Release
- Optionally delete  
  print jobs submitted under the **`shr-machine-mfg`** account.

---

## 9. User Communication & Support

- Machines labelled and documented on-site
- Shortcuts placed on desktops to:
    - Access legacy `machineshop` user data
    - Launch Keeper login and help guide

Team leads have been briefed and are monitoring login workflows during transition.  
All users aware that local data will not persist if machine is re-imaged.

---

## 10. Admin Rights and Policy Cleanup

- Local admin rights removed for all users except IT
- Legacy `machineshop` user account disabled
- Confirmed removal from Local Admins group
- GPO enforced: screensaver lock, password complexity, inactivity timeout

---

## 11. Data & Migration Tasks

`shr-machine-mfg` has been granted read/write access to the previous `CellA / CellB` local user directory (e.g. `C:\Users\`)
- A desktop shortcut pointing to this folder has been created on each machine
- This allows users to access and retrieve any files from the previous configuration
- This is intended as a **temporary transition measure only** – if a device is rebuilt, those local files may no longer be available
- As part of the data migration, each machine locked down to `shr-machine-mfg` was configured so that the new profile desktop matched the layout of the previous account. 
  All data, icons, and shortcuts were placed in the same locations under the new shared account to ensure a seamless transition for users.

---

## 12. Validation Summary

Post-implementation validation was completed jointly by **Simon Bunce** (Machine Shop Supervisor) and **Paul Davidson**.  
Each device within scope was reviewed and tested to confirm full operational readiness under the **`shr-machine-mfg`** configuration.

### Validation activities included:
- **Application checks:** Verified operation of all required production applications, including **Mastercam**, **Autodesk Fusion 360**, and **Machine Shop CNC control software** on all relevant devices.
- **Licensing confirmation:** Ensured all required applications operated correctly under the new shared account with no licensing errors.
- **Drive access:** Confirmed access to network shares and local storage in line with allocated permissions.
- **Login restrictions:** Validated that devices only allow **`shr-machine-mfg`** login, as scoped.
- **Printer and uniFLOW integration:** Confirmed secure print release via individual user cards on Canon devices for all approved Machine Shop staff.
- **Data migration checks:** Verified that the desktop layout, data, icons, and shortcuts under the new profile matched the previous configuration for a seamless user experience.

All tests passed successfully, and the environment is confirmed as production-ready.
---