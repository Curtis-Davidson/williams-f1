# F1 Canteen – Shared Account Remediation Support Document

**Project:** Shared Account Remediation  
**Location:** F1 Canteen  
**Date:** [Insert Date]  
**Prepared by:** Curtis-Davidson  
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
- Migrated all existing local Canteen data into a mapped network directory (`F1 Canteen`).
- Configured a **floating laptop** for Canteen use with all user profiles set up and tested.
- Requested creation of a **SharePoint / Teams shared workspace** for Canteen data and collaboration.
- Migrated Claire Smith’s (Canteen Manager) profile, data, and mailbox to her new account.

---

## 3. Authorised Users – Shared Mailbox Access

- **Claire Smith** (Manager)
- **Kieran Kerby**
- **Rebecca Bradley**
- **Jazmine Brandao** 
- **Charlie Nelson**

---

## 4. Device Configuration

**Floating Canteen Laptop:**

- Configured with all authorised user profiles.
- Mapped `F1 Canteen` network directory for menu templates, documents, and shared operational data.
- Added desktop shortcut for direct access to the shared folder.
- Verified Outlook configuration with primary (personal) and secondary (F1 Canteen) mailboxes.
- Configured OneDrive per user profile.

---

## 5. Data Migration

- All menus and operational Canteen data previously stored on the laptop have been consolidated into the network-based `F1 Canteen` directory.
- Desktop shortcuts provided for easy access.
- Pending migration of this data to the new SharePoint site upon its creation, after which the mapped directory will be decommissioned.

---

## 6. Outstanding Actions

1. **SharePoint / Teams Area Creation** – Awaiting IT provisioning of the shared workspace for F1 Canteen.
2. **Adobe Acrobat Pro Access** – Awaiting return of Duncan Burrow to provide login credentials for Adobe Pro Writer required by Canteen for PDF editing.

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
- `F1 Canteen` network directory mapped and accessible.
- Menus, templates, and operational documents successfully migrated.
- Floating laptop tested for each user profile:
    - Data migration validated.
    - Desktop setup confirmed.
    - Applications operational.
- Canteen Manager profile migration successful.
- Pending actions documented with owners identified.