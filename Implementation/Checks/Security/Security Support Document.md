# Security – Shared Account Transition – Support Summary

**Project:** Shared Account Remediation  
**Location:** Security Gatehouse / Factory Campus  
**Date:** 16/09/2025  
**Prepared by:** Paul Davidson  
**Account ID:** `security`  
**Status:** Implemented and Active

---

## 1. Purpose of Change

The legacy **security** generic account has been retired to align with audit, compliance, and security requirements.

The account has been migrated to the **Shared Accounts OU**:  

OU=!Shared Accounts,OU=Factory,DC=williamsf1,DC=com

This provides **secure, auditable access** for designated security functions, while ensuring all staff have named logins for accountability.

This account covers **CCTV, badge printing, and access control systems** required for **24/7 site security**.

---

## 2. Overview of Changes

- Moved **security** generic account into Shared Accounts OU
- Maintained mailbox **security@williamsf1.com**
- Applied OU policies and login restrictions (scoped to Security Gatehouse devices)
- Rolled out individual AD accounts to all security staff
- ANPR system outsourced to third party; no longer supported in-house
- Removed legacy local administrators (non-IT) from Security Gatehouse machines  

---

## 3. Devices Using `security`

- **fact-avg01** – Dedicated CCTV workstation
- **W9442** – Gatehouse admin PC (CCTV, Easy Badge, Teams, Office Apps)
- **W9443** – Gatehouse admin PC (Teams, Office Apps, Email, Salto, Envoy)
- **iPads (x2)** – Envoy app access (unchanged)
- **iPhone** – MS Teams, dedicated security line

> **Note:** ANPRPC (Automatic Number Plate Recognition system) is now **outsourced** and no longer under IT support.

---

## 4. Shared Account Configuration

- **Account Name:** `security`
- **Password Policy:** 2MFA enforced
- **OU Path:**  

OU=!Shared Accounts,OU=Factory,DC=williamsf1,DC=com

- **Email/Teams:** Mailbox maintained (**security@williamsf1.com**), Teams tag created for **“Security”**

---

## 5. Access Controls

- **MFA:** All access requires 2MFA approval
- **Device Scope:** Account restricted to **fact-avg01**, **W9442**, and **W9443** only
- **Implementation:** Lockdown applied directly on the **security** AD object
- **Support Note:**
- If new security PCs are rolled out, device IDs must be **added as approved logon devices** within the account object
- Failure to add them will **block `security` logins** on new machines

---

## 6. Drive and Application Access

**Mapped Drives:**
- `T:\ → \\factory.wf1\DFS2\SecurityShare`
- `Y:\ → \\factory.wf1\wf1\pdmfiles\common`

**Applications Verified:**
- **ANPR App** – *Out of scope (outsourced)*
- **CCTV App** – Working
- **Easy Badge** – Working
- **Salto (browser)** – Working
- **Envoy (browser/iPad)** – Working
- **MS Teams, Outlook, Office** – Working

---

## 7. Exceptions / Special Cases

- USB and printing exemptions applied for badge printer
- Two iPads for Envoy and the iPhone for Teams remain unchanged

---

## 8. Policy & Admin Notes

- **security** migrated to Shared Accounts OU (removed from Generic Accounts OU)
- All security staff issued with **individual AD accounts** (`firstname.lastname`)
- Dedicated **admin PC** available for `firstname.lastname` logins when required
- Local admin rights removed (except IT)

---

## 9. Validation Summary

**Validation Performed by:**
- Claire Silvey – Security Supervisor
- Paul Davidson – Infrastructure Engineer

**Activities:**
- Verified login on scoped devices (**W9442, W9443, fact-avg01**)
- Tested mapped drives and SharePoint repository migration
- Confirmed CCTV, Easy Badge, Salto, Envoy operation
- Verified badge printing and scanning functions
- Confirmed Teams “Security” tag communication working
- Validated mailbox migration and delegated access
- Verified **firstname.lastname** user accounts working with dedicated admin PC

**Result:** All tests passed. The **security** account is live, scoped to approved devices, and production-ready.

---

## 10. User Accounts

**Existing Users with AD Accounts:**
- Claire Silvey – Security Supervisor
- Marcus Begley – Security Team
- Graham Neal – Security Team
- Jordan Davies – Security Team
- Jacob Osborne – Security Team

**New AD Accounts Created:**
- Janet Penny – Security Team
- Alan Penny – Security Team
- Mark Howard – Security Team
- Stephen Williams – Security Team
- Kristina Striogaite – Security Team
- Graham Gibson – Security Team
- Jeremy Parson – Security Team  
