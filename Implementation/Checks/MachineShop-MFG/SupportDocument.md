# Machine Shop Shared Account Transition – Support Summary
**Project:** Shared Account Remediation  
**Location:** Machine Shop, WF1 Campus  
**Date:** 01/08/2025  
**Prepared by:** Paul Davidson  
**Account ID:** `shr-machine-mfg`  
**Status:** Implemented and Active

---

## Key Contacts

- **Conner Murphy** – Metallic Manufacturing Manager
- **Simon Bunce** – Team Leader (Turning), point of contact for implementation support

These individuals supported, approved, and coordinated the transition to the `shr-machine-mfg` shared account.

---

## 1. Purpose of Change

Establish a secure shared account (`shr-machine-mfg`) for the Machine Shop to support shift-based collaborative access across designated terminals.  
This replaces legacy generic or personal logins with a single, access-controlled, auditable identity.

---

## 2. Devices Using `shr-machine-mfg` (Category 8)

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

- Configured for exclusive login by `shr-machine-mfg`
- Machine login lockdown applied on the AD user object itself (not via GPO or device OU)
- Group Policy enforced to restrict local user or domain user access
- Enrolled in the `grp-machine-mfgLAC` (Login Access Control) group
- Assigned the correct drive mappings and application permissions
- Under monitoring as part of the account remediation rollout

Legacy user directories remain temporarily accessible via desktop shortcut for document recovery and transition purposes.

---

## 3. Access Groups and Controls

**Active Directory Groups:**

- `grp-machine-mfgLAC` – Controls which devices `shr-machine-mfg` may log into
- `grp-machine-mfgRW` – Provides mapped drive read/write access
- `grp-machine-mfgRDC` – Optional remote access group (if required later)

These are used to ensure minimal access surface, strict scope enforcement, and scalable management.

---

## 4. Keeper Access & Account Custodians

Password and MFA credentials for `shr-machine-mfg` are stored securely in **Keeper**, following IT security policy.

Access has been granted to the following team leaders across the full shift rotation:

- **Bleddyn Davies** – Team Leader, Milling (Mon–Thurs)
- **Simon Bunce** – Team Leader, Turning (Mon–Thurs)
- **Carl Smith** – Team Leader, Prototype Machine Shop (Mon–Thurs)
- **Ewan Divine** – Team Leader, Night Shift (Mon–Thurs)
- **Jon Othen** – Team Leader, Weekend Shift (Fri–Sun)
- **Steve Green** – Weekday Supervisor, Metallic Production

These custodians manage login issues, credential resets, and access control within their respective shifts.

---

## 5. Email and Teams Access

- `shr-machine-mfg` has **no mailbox or Teams access**
- All comms are handled by team leads or personal accounts
- Shared mailbox can be provisioned later if required for workflow

---

## 6. Application and Drive Access

**Mapped Drives:**

- `T:\ → \\factory.wf1\DFS2\MachineShop`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\shr-machine-mfg`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\cae_common`

**Applications:**

- Relevant CAD tools, CNC interfaces, and shopfloor utilities
- Access tested across all 8 machines under the shared context

---

## 7. Canon uniFLOW – Delegated Print Job Access Overview

Canon uniFLOW has been implemented to support secure printing across the **Milling** and **Turning** divisions of the Machine Shop, both of which use `shr-machine-mfg`.

Two dedicated Canon printers have been provisioned, with release access controlled via AD-integrated card readers.

**Delegation Mechanism:**

- Print jobs sent from `shr-machine-mfg` can be accessed by users in the approved AD group
- Users retrieve print jobs securely using their individual access cards
- Supports over 40 users across shifts

This setup ensures:

- Secure print release per user
- Seamless operation across teams
- No exposure of sensitive prints to unauthorised users

**Canon uniFLOW supports delegation to:**

- Individual AD users
- AD groups (used here for shift-based efficiency)

Authorised users can:

- View
- Release
- Optionally delete

print jobs submitted by another user or shared account.

---

## 8. User Communication & Support

- Machines labelled and documented on-site
- Shortcuts placed on desktops to:
    - Access legacy `machineshop` user data
    - Launch Keeper login and help guide

Team leads have been briefed and are monitoring login workflows during transition.  
All users aware that local data will not persist if machine is re-imaged.

---

## 9. Admin Rights and Policy Cleanup

- Local admin rights removed for all users except IT
- Legacy `machineshop` user account disabled
- Confirmed removal from Local Admins group
- GPO enforced: screensaver lock, password complexity, inactivity timeout

---

## 10. Reversion Plan

If issues arise:

- `machineshop` legacy account can be temporarily re-enabled (with IT approval)
- Local admin elevation available on emergency basis (tracked by service desk)
- Credentials recoverable from Keeper at all times

---

## 11. Audit & Documentation

- Entry created in Shared Account Register
- Confluence page updated with:
    - Keeper custodian list
    - Device allocation
    - Group memberships
    - Drive mappings
- Account tagged with Project ID: **P-135901**

---