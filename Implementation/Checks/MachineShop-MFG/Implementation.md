# Implementation Plan – Shared Account Rollout: `shr-machine-mfg`
**Project ID:** P-135901  
**Location:** Machine Shop  
**Date:** 01/08/2025  
**Engineer:** Paul Davidson

---

## 1. Account Creation

- [x] Created AD account: `shr-machine-mfg`
- [x] Set `cannot change password`, `password never expires`
- [x] Disabled interactive login from all machines by default
- [x] Enabled only on approved machines via AD login lockdown (see section 4)

---

## 2. AD Groups Created

- [x] `grp-machine-mfgLAC` – Controls login access scope
- [x] `grp-machine-mfgRW` – File server read/write permissions
- [x] `grp-machine-mfgRDC` – (Optional) RDP group, not enabled yet

Assigned `shr-machine-mfg` to:

- `grp-machine-mfgRW`

Added all authorised machines to:

- `grp-machine-mfgLAC`

---

## 3. Device Assignment

Shared account is permitted to log in ONLY on the following 8 machines:

- **SEIKI21**
- **M8687**
- **W8841**
- **M3147**
- **M3104**
- **M1909**
- **M8662**
- **W9474**

 **Machine login lockdown applied on the AD user object itself (not via GPO or device OU)**

---

## 4. Login Experience Setup

- [x] Local user data from old accounts made accessible via desktop shortcut
- [x] Desktop background standardised with Williams F1 wallpaper
- [x] Login tested with `shr-machine-mfg` and validated across all 8 machines

---

## 5. Keeper Integration

- [x] Created Keeper entry: `Shared Account – shr-machine-mfg`
- [x] Enabled MFA
- [x] Shared securely with:

    - **Bleddyn Davies** – Milling
    - **Simon Bunce** – Turning
    - **Carl Smith** – Prototype Machine Shop
    - **Ewan Divine** – Night Shift
    - **Jon Othen** – Weekend Shift
    - **Steve Green** – Weekday Supervisor, Metallic Production

---

## 6. Drive Mapping Configuration

Mapped drives verified across all machines:

- `T:\ → \\factory.wf1\DFS2\MachineShop`
- `X:\ → \\factory.wf1\wf1\user_cae_files2\shr-machine-mfg`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\cae_common`

---

## 7. Print Queue Delegation

- [x] Two dedicated Canon printers added for Milling and Turning teams
- [x] Configured Canon uniFLOW with AD group delegation
- [x] Confirmed users can release `shr-machine-mfg` print jobs using personal cards
- [x] Setup verified with sample prints from both teams

---

## 8. Communication with End Users

- [x] Support Summary published to Confluence
- [x] Email sent to team leads with credentials and scope
- [x] Printed handout placed in Machine Shop
- [x] Users advised that local desktop data is temporary and not backed up

---

## 9. Security Policies Enforced

- [x] Account: `shr-machine-mfg`
    - No mailbox
    - No Teams
    - Password stored only in Keeper
- [x] Devices:
    - Screensaver enforced after 5 min idle
    - BitLocker verified
    - Windows Hello disabled
- [x] Group Policy:
    - Interactive logon message
    - Inactivity lock
    - Admin access restricted to IT only

---

## 10. Post-Implementation Validation

- [x] Successful login test on all 8 machines
- [x] Drive access confirmed
- [x] Applications tested (CAD, CNC interfaces)
- [x] Keeper access validated by all shift leads
- [x] Print job release tested by at least 3 users

---

## 11. Final Documentation

- [x] Shared Account Register updated
- [x] Keeper record documented
- [x] Audit trail included in Service Desk ticket
- [x] Confluence page published (linked from JIRA ticket)

---

## 12. Reversion Strategy

In case of failure or access issues:

- Re-enable legacy `machineshop` account (if required)
- Reassign Keeper credentials (admin rights reserved)
- Restore mapped drives via standard login scripts
- Rebuild affected machines with previous image (fallback ISO available)

---

## 13. Additional Notes

- Machine lockdown was applied via **AD user object restrictions**
- Devices are monitored via Defender and Sentinel
- Any account misuse will trigger Sentinel alerts via login anomaly rules

---