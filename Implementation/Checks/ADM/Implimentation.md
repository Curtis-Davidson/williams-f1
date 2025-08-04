# Implementation Plan – Shared Account: `shr-neo-mi`
**Department:** ADM – Additive Digital Manufacturing  
**Account:** `shr-neo-mi`  
**Engineer:** Paul Davidson  
**Date Completed:** 01/08/2025

---

## 1. Purpose

Deploy a secured, read-only shared account (`shr-neo-mi`) for the **NEO 800 display workstation** in the ADM department.  
Primary use case: Run live SharePoint BI dashboards and D-Link camera feeds, with no session timeout or lock screen interruptions.

---

## 2. Account Creation & Configuration

**Active Directory Setup:**

- Account: `shr-neo-mi`
- OU Path: `WAF1\SharedAccounts\NEO800`
- Description: "ADM Display Station – BI Metrics + Camera Feed"
- Set password to never expire
- User cannot change password
- Smartcard logon not required

**Group Assignment:**

- Add to security group: `grp-neo-miLAC`
- Restricts login to **W8800** only

---

## 3. Lock Screen Exemption (Intune Policy)

To prevent disruption of camera feeds and BI dashboards, this account must be excluded from inactivity lockouts.

**Azure AD Group:**
- `Intune All Users Lock Screen Exempt`

Account `shr-neo-mi` added to this group to bypass default lock screen policy.

---

## 4. Keeper Vault Entry & Custodians

The credentials for `shr-neo-mi` have been securely stored in **Keeper**, with access delegated to:

- **Andrew Cripps** – ADM Supervisor
- **Reece Hardy-Jack** – ADM Technician
- **Thomas Wrenn** – ADM Technician

Access includes:
- Username
- Complex password
- 2FA metadata (if required)
- Role-based notes

---

## 5. Device Preparation (W8800)

**Device:** `W8800` – NEO 800 Display Station

Steps completed:

- Confirmed Intune registration
- Defender and Sentinel policy active
- Logged in as admin to configure environment

---

## 6. Software Deployment & Auto-Launch

### BI Metrics:

- SharePoint BI dashboard added as Chrome PWA app shortcut
- Shortcut configured to launch on user login
- Runs fullscreen in kiosk-like presentation

### Camera Monitoring:

- D-Link Viewer installed
- Configured with saved profiles for live stream
- Set to auto-launch on login

### Startup Folder Path:
`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`  
Contains:
- `BI-Dashboard.url`
- `DLinkView.lnk`

---

## 7. Logon Validation & Testing

Validation checklist:

- `shr-neo-mi` logs in successfully on W8800
- SharePoint BI dashboard launches cleanly
- D-Link camera software auto-starts with correct feeds
- No Windows Explorer, no mapped drives
- Inactivity lock screen does not trigger

---

## 8. Monitoring & Security Baseline

- Account protected by Defender endpoint baselines
- Sentinel monitors for unexpected interactive usage
- No email or web browsing permitted
- No access to network shares or OneDrive

---

## 9. Documentation & Visibility

- Support Summary published in Confluence
- Keeper permissions validated with custodians
- Intune exemption reflected in device policy status
- AD account labelled: "BI Monitoring Only – Non-Interactive"

---

## 10. Rebuild Procedure (Disaster Recovery)

If W8800 is lost or reimaged:

1. Rebuild from ADM Display Workstation image
2. Rejoin to domain
3. Add to `grp-neo-miLAC`
4. Install Chrome, SharePoint shortcut, and D-Link Viewer
5. Place both launch items in user Startup folder
6. Confirm Intune, Defender, Sentinel, and exemption policies
7. Test login and BI/camera operation end-to-end

---

## 11. Completed By

Paul Davidson  
 – Williams F1  
Date: 01 August 2025