# Support Summary – Shared Account: `shr-neo-mi`
**Department:** NEO 800  
**Shared Account:** `shr-neo-mi`  
**Cutover Status:** Complete  
**Last Updated:** 01/08/2025  
**Engineer:** Paul Davidson

---

## 1. Purpose of Shared Account

The `shr-neo-mi` shared account is configured for the **NEO 800 display screen**, which presents **live camera feeds** from 3D printers and **real-time BI metrics dashboards**.

Its role is strictly for visual monitoring — no interactive use. The account requires uninterrupted screen access and is considered **read-only** from a support and infrastructure perspective.

---

## 2. Devices Using `shr-neo-mi`

- **W8800** – Display screen workstation located in the NEO 800 viewing zone.

---

## 3. Account Setup & Policy

- **Created in Active Directory** as a generic shared account.
- Password is set to **not expire** and cannot be changed by the user.
- Enabled for login on device **W8800 only**, restricted via `grp-neo-miLAC`.

---

## 4. Intune Lock Screen Exemption

This account is **exempt** from standard lock screen policies.

It has been added to:

- `Intune All Users Lock Screen Exempt`

This ensures the display remains **active at all times**, avoiding screen dimming or locking that would interrupt visual monitoring.

---

## 5. Drive Access

Drive mappings are not required for this display use case. No access to team shares or user directories is provisioned under `shr-neo-mi`.

---

## 6. Keeper Entry & Access Custodians

Account credentials and MFA are securely stored in **Keeper**.

Access has been granted to:

- **Andrew Cripps** – ADM Supervisor
- **Reece Hardy-Jack** – ADM Technician
- **Thomas Wrenn** – ADM Technician

These individuals are responsible for credential access and operational continuity of the display account.

---

## 7. Monitoring & Sentinel Alerts

The account is monitored via Microsoft Defender and Sentinel.

Due to the non-interactive nature of the account:

- **Any keyboard/mouse interaction** outside normal scheduled maintenance hours will raise an alert.
- Defender AV is active but not user-prompted.

---

## 8. Rebuild & Recovery

In the event of failure:

- Reimage device **W8800** using standard base image for Display/NEO 800
- Reapply AD group `grp-neo-miLAC` and Intune exemption
- Restore the Keeper credentials if credential loss occurs

---

## 9. Notes

- The account auto-launches the **SharePoint BI dashboard** (published as an application) and the **D-Link camera monitoring software** at login.
- This is not configured as a kiosk session; the environment retains the default Windows shell but is used passively.
- Physical access to the machine is via locked enclosure with key access held by Engineering.

---