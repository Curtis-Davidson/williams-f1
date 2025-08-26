# Support Summary – Shared Account: `shr-neo-mi`
**Department:** Additive Digital Manufacturing (ADM) 
**Shared Account:** `shr-neo-mi`  
**Cutover Status:** Complete  
**Last Updated:** 08/08/2025  
**Engineer:** Paul Davidson

---

## 1. Purpose of Shared Account

The **`shr-neo-mi`** shared account is configured for the **NEO 800 display screen**, which presents **live camera feeds** from 3D printers and **real-time BI metrics dashboards**.

Its role is strictly for visual monitoring — no interactive use. The account requires uninterrupted screen access and is considered **read-only** from a support and infrastructure perspective.

---

## 2. Devices Using **`shr-neo-mi`**

- **W10103** – Display screen workstation located in the NEO 800 viewing zone.

---

# 3. Shared Account Configuration

**Account Name:** `shr-neo-mi`  
**Password Policy:** stored in Keeper  
**OU Path:** `OU=!Shared Accounts,OU=Factory,OU=Factory.WF1,DC=williams,DC=f1`

---

## 4. Account Setup & Policy

- **Created in Active Directory** as a shared account.
- Password is set to **not expire** and cannot be changed by the user.
- Enabled for login on device **W10103 only**, restricted via `shr-neo-mi`.
- All new shared accounts **must** be added to the Intune group: `intune_all_user_generic_account`

---

## 5. Intune Lock Screen Exemption

This account is **exempt** from standard lock screen policies.

It has been added to:

- `Intune All Users Lock Screen Exempt`

This ensures the display remains **active at all times**, avoiding screen dimming or locking that would interrupt visual monitoring.

---

## 6. Drive Access

Drive mappings are not required for this display use case. No access to team shares or user directories is provisioned under **`shr-neo-mi`**.

---

## 7. Keeper Entry & Access Custodians

Account credentials and MFA are securely stored in **Keeper**.

Access has been granted to:

- **Andrew Cripps** – ADM Supervisor
- **Reece Hardy-Jack** – ADM Technician
- **Thomas Wrenn** – ADM Technician

These individuals are responsible for credential access and operational continuity of the display account.

---

## 8. Monitoring & Sentinel Alerts

The account is monitored via Microsoft Defender and Sentinel.

Due to the non-interactive nature of the account:
- Defender AV is active but not user-prompted.

---

## 9. Machine Active Tasks

### W10103 (Kiosk PC)
- **Dual Display Configuration:**
    - **TV1:** D-Link D-ViewCam live stream from Neo800 IP cameras
    - **TV2:** Excel machine utilisation report
- **Default Excel Startup File:**  
  `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation\ADM Machine Utilisation Tracker.xlsx`

---

## 9. Notes

- The account auto-launches the **SharePoint BI dashboard** (published as an application) and the **D-Link camera monitoring software** at login.

---
## 10. Validation Summary

**Business Owner:** Andrew Cripps – ADM Supervisor

All validation activities have been completed.  

### Validation Activities Included:
- Logged in as **`firstname.lastname`** and confirmed:
    - Full access to Titanium Apps.
    - Email notifications sent to all recipients in `Neo800_notifications@williamsf1.com` upon trigger events.
    - Ability to write reports to the network share during the print cycle.
    - Ability to view and open generated report files.
- Logged in as an **Individual Account ID** and confirmed:
    - Ability to view and open generated report files.

- Logged in as the **shr-neo-mi** on W10103 and confirmed:
    - **TV1:** Live video feed from Neo800 IP cameras via D-Link D-ViewCam.
    - **TV2:** Excel machine utilisation report displayed from the default path:
      `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation\ADM Machine Utilisation Tracker.xlsx`
- Confirmed account logon restrictions prevent access from unauthorised devices.
- Confirmed internet access is blocked for `Neo800-01` 

All tests passed successfully, and the environment is confirmed as production-ready.

---
