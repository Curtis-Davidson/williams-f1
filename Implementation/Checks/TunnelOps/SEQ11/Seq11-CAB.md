# Support Handover Document

**TunnelOps – Sequence 11 – WTM Shared Account Remediation**

---

## 1. Overview

This document provides the formal support handover for the implementation of the shared account **shr-tunops-wtm**, delivered as part of **Sequence 11 of the Shared Accounts Remediation Project**.

The purpose of this change is to remove reliance on insecure generic accounts and reduce associated security vulnerabilities by implementing a controlled, auditable shared account aligned with Williams Formula One security standards.

This workstation forms part of the **Wind Tunnel Planner Countdown Machine** and supports critical wind tunnel operations.

---

## 2. Scope

### In Scope

- Shared account creation and configuration:
    - `shr-tunops-wtm`
- Replacement of TunnelOps generic account usage for WTM activities
- WTM workstation configuration
- Android business phone used for wind tunnel model photography
- OneDrive photo synchronisation to the WTM workstation
- Application validation and data migration
- MFA enforcement and Intune compliance
- Post-implementation hypercare and sign-off

### Out of Scope

- Decommissioning of TunnelOps generic account (covered in later remediation sequence)
- Application redesign or redevelopment
- Network or VLAN changes
- Licensing model changes outside E5 assignment

---

## 3. Business Context

- The WTM workstation is used for **Wind Tunnel Test Planning and Monitoring activities**.
- The Android business phone is used to **photograph Formula 1 wind tunnel models**.
- Images captured must synchronise automatically to the WTM workstation under the shared account profile.
- System availability is operationally critical.

---

## 4. Shared Account Details

**Account Name:**

- `shr-tunops-wtm`

**Account Type:**

- Standard shared account (no admin shared account)

**Usage:**

- Login to WTM workstation only
- Access Wind Tunnel Planner tools and supporting applications

**Security Controls:**

- MFA enforced via Keeper
- Microsoft Authenticator configured on Android business phone
- Login restricted using AD **logonWorkstations** attribute

---

## 5. Device Information

### WTM Workstation

- Recently replaced during shutdown
- Intune-enrolled
- Assigned Microsoft E5 licence
- Login restricted to:
    - `shr-tunops-wtm`
    - Standard IT administrative accounts only

### Android Business Phone

- Dedicated device for wind tunnel model photography
- Intune-enrolled
- OneDrive configured to sync photos directly to:
    - `shr-tunops-wtm` user profile on WTM workstation
- Authenticator installed for MFA

---

## 6. Applications Supported

The following applications are installed and validated for the shared account:

- NX
- TeamCenter (web-based)
- Microsoft Office (E5)
- MPart
- Microsoft Teams
- Wind Tunnel Planner application
- VLC Player
- Two SharePoint sites (access confirmed and pinned as desktop/browser apps)

### Application Notes

- During cut-over, all application paths were validated.
- Application data and configuration mappings were verified.
- No application functionality relies on the legacy TunnelOps generic profile.

---

## 7. Data & Storage

### Data Migration

- Desktop data
- Documents
- Application-related data
- Configuration files

All migrated from:

- TunnelOps generic account

To:

- `shr-tunops-wtm`

### Validation Performed

- Mapped drives confirmed
- SharePoint shortcuts validated
- OneDrive sync confirmed
- Application data paths verified

---

## 8. Access Model

### Login Method

- Physical login at WTM workstation only
- Restricted via AD user object → logonWorkstations

### Group Membership

- Account added to appropriate AD groups in line with WF1 standards
- No bespoke or non-standard permissions applied

---

## 9. MFA & Security

- Keeper used as primary credential vault
- MFA mandatory for shared account
- Microsoft Authenticator installed on Android business phone
- Account compliant with Intune and conditional access policies

---

## 10. Operational Support

### Password Management

- Password managed via Keeper
- Annual rotation enforced
- Any password change must be updated in Keeper immediately

### MFA Reset

- Managed by IT Security / Service Desk
- Authenticator re-registration may be required if device is replaced

### OneDrive Sync Issues

- Confirm Android device is:
    - Intune compliant
    - Signed into correct account
    - OneDrive camera upload enabled
- Confirm workstation OneDrive client is signed in as `shr-tunops-wtm`

---

## 11. Hypercare & Sign-Off

### Hypercare Phase

- One (1) week hypercare period provided post go-live
- Monitoring focused on:
    - Login stability
    - Application behaviour
    - OneDrive photo sync
    - Wind Tunnel Planner operation

### Sign-Off

- Stakeholder sign-off obtained following successful hypercare period
- No outstanding operational issues identified

---

## 12. Support Ownership

### Business Owner

- Wind Tunnel Systems Management

### IT Ownership

- IT Support / DPT Team

### Security Oversight

- IT Security Team

---

## 13. Ongoing Monitoring

- AD login auditing
- Intune compliance reporting
- Keeper audit logs
- Service Desk incident trend monitoring

---

## 14. Final Handover Statement

Following successful implementation, testing, and completion of the hypercare period, ownership of this service has been formally handed over to **IT Support**.

This document represents the authoritative reference for ongoing support of the WTM shared account and associated devices.

---