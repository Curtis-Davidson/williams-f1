# F1 Canteen – Shared Account Remediation Support Document

**Project:** Shared Account Remediation  
**Location:** F1 Canteen  
**Date:** 14 August 2025  
**Prepared by:** Paul Davidson  
**Account ID:** F1-CANTEEN  
**Status:** Implemented and Active

---

## 1. Purpose of Change

As part of the Shared Account Remediation Project, the `F1-CANTEEN` generic account has been retired to align with security, compliance, and audit requirements. All Canteen operations now use named **firstname.lastname** Active Directory accounts.  
The `canteen@williamsf1.com` email address has been retained as a **shared mailbox** for ongoing operational use by authorised staff.

---

## 2. Overview of Changes

- Disabled the legacy `F1-CANTEEN` generic account.
- Converted `canteen@williamsf1.com` to a shared mailbox in Exchange/Entra ID.
- Assigned shared mailbox access to all authorised Canteen staff.
- Created individual **firstname.lastname** AD accounts for each staff member.
- Configured the shared mailbox as a **secondary mailbox** for all authorised users.
- Completed. All F1 Canteen data has been migrated .
- Configured a **floating laptop** for Canteen use with all user profiles set up and tested.
- Fully migrated the **Canteen Manager’s office desktop** in Claire’s office, including data, applications, and mailbox, to her new firstname.lastname account.
- Requested creation of a **SharePoint / Teams shared workspace** for Canteen data and collaboration (Request Ref: WF1SD-27289). (**Completed**)
- Migrated Claire Smith’s (Canteen Manager) profile, data, and mailbox to her new account.

---

## 3. Authorised Users – Shared Mailbox Access

- **Claire Smith** (Manager)
- **Kieran Kerby**
- **Rebecca Bradley**
- **Jazmine Brandao**
- **Charlie Nelson** (Head Chef)

---

## 4. Device Configuration

**Floating Canteen Laptop:**

- Configured with all authorised user profiles.
- F1 Canteen: Access is now via dedicated SharePoint site (replacing old local share):
  https://williamsf1.sharepoint.com/sites/F1Canteen.
- Added F1 Canteen SharePoint application pinned on desktop and taskbar.
- Verified Outlook configuration with primary (personal) and secondary (F1 Canteen) mailboxes.
- Configured OneDrive per user profile.
- **F1 Canteen Manager’s Workstation:** `W9438`
- **Canteen Staff Floating Laptop:** `L2260`

**Canteen Manager’s Office Desktop (Claire Smith):**

- Migrated fully to firstname.lastname account.
- Data, applications, and mailbox migrated and tested.
- Desktop and OneDrive configuration completed.

---

## 5. Data Migration

- All menus and operational Canteen data previously stored on the laptop have been consolidated into the new F1 Canteen SharePoint site  `https://williamsf1.sharepoint.com/sites/F1Canteen`.
- Completed Pending migration of this data to the new SharePoint site upon its creation (WF1SD-27289), the mapped directory has been decommissioned.
- **F1 Canteen: Dedicated SharePoint site:**
  https://williamsf1.sharepoint.com/sites/F1Canteen

---

## 6. Outstanding Actions

- **Adobe Acrobat Pro Access** – Awaiting return of Duncan Burrow to provide login credentials for Adobe Pro Writer required by Canteen for PDF editing.

---

## 7. Operational Notes

- Canteen shared mailbox configured as a **secondary mailbox** for all users for quick access to shared communications.
- Claire Smith’s migration to her firstname.lastname account has been fully completed and tested.
- All users now operate solely from named accounts; no generic logins remain in use.

---

## 8. Validation Summary

All of the following were confirmed:

- Shared mailbox access tested for all users.
- Outlook configured with both primary and secondary mailboxes.
- OneDrive configured and synced for all user profiles.
- Menus, templates, and operational documents successfully migrated.
- Floating laptop tested for each user profile:
    - Data migration validated.
    - Desktop setup confirmed.
    - Applications operational.
- **Canteen Manager’s office desktop migration** validated, with data and applications confirmed operational.
- Canteen Manager profile migration successful.
- Pending actions documented with owners identified.