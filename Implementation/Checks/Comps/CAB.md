# CAB Submission – Shared Account Remediation in Composite Manufacturing

---

## 1. Change Summary

Decommissioning of the non-compliant `Generic Account` **comps**, replacing it with a security-compliant `Shared Account` **shr-comps-mfg** across Composite Manufacturing.  
Impacts **34 retained devices** and a user group of over **70 production staff** operating shared workstation devices.

---

## 2. Business Justification

The `comps` Generic Account violates current IT Security policies by lacking:

- Traceability
- Individual accountability
- MFA compatibility

This change aligns Composite Manufacturing with organisational security standards by implementing a compliant Shared Account:

- `shr-` prefix
- Scoped access
- Principle of Least Privilege (PoLP)

**Key risks mitigated:**

- Security Breach Risk from shared generic credentials
- Compliance Failure (audit trail, MFA, password hygiene)
- Operational Risk from ambiguous device access and unauthorised local admin elevation

**Expected benefits:**

- Secure, role-scoped shared access
- Full audit trail and traceability
- Alignment with enterprise identity and access control policies

---

## 3. Scope & Impact

**Devices impacted:**

- 34 retained production devices under Device Category 8
- Previously used by `comps`, now transitioned to `shr-comps-mfg`

**Systems impacted:**

- Windows authentication
- Access to NX, Mestec, Teamcenter, Tulip, Adobe Reader, and Virtek Iris
- Network drives:
    - `V:\Composites`
    - `L:\VIRTEK LASER PROJECTION FILES`
    - SharePoint ("The Hub")

**User groups impacted:**

- 70+ production team members (see To-Be user list)
- No impact to office-based individual accounts

**Exceptions:**

- Decommissioned devices (Category 1) excluded
- Devices moved to `shr-pattern-mi` shared account handled in a separate CAB

**Dependencies:**

- Completion of `shr-comps-mfg` account creation
- Permissions audit and PoLP application
- Removal of `comps` from Local Admin / Remote Desktop groups

**Impact rating:**  
**Medium** (operationally significant but low-risk with rollback capability)

---

## 4. Implementation Window

**Proposed Schedule:**  
Phased deployment over **5 business days**, targeting shifts where IT Support coverage is available.

**Dependencies:**

- `shr-comps-mfg` account created and verified
- Device policy updates applied via GPO or deployment scripts
- Confirmed user access tested in pre-deployment

---

## 5. Rollback Plan

**Rollback Trigger Conditions:**

- Users unable to access required applications or mapped drives
- Device instability or credential caching issues post-change

**Rollback Steps:**

1. Re-enable `comps` account in Active Directory
2. Restore local permissions to affected devices (if altered)
3. Remove `shr-comps-mfg` from `logonWorkstation` restrictions
4. Notify Composite Manufacturing Manager (Blake Dawe) and IT Support Manager (Mike Smith)

**Estimated Time to Complete Rollback:**  
**Within 1 hour per device**

---

## 6. Testing & Validation

**Pre-change test plan:**

- `shr-comps-mfg` credentials tested on test device
- Access to all key applications verified (NX, Teamcenter, Tulip, etc.)
- Drive mapping and SharePoint access confirmed

**Post-change test plan:**

- On-device login verification across multiple shifts
- App launch tests (Edge, Mestec, Teamcenter)
- Drive access (`V:\`, `L:\`) validated
- No admin/remote desktop privileges persist

**Success criteria:**

- No functional disruption across any shift
- All users able to complete workflows without escalation
- No residual access via `comps` account

---

## 7. Approvals

**Business Owner:**  
Blake Dawe (Composite Manufacturing Manager – Laminating)

**IT Security Approval:**  
Chris Hicks (IT Security Engineer)

**IT Support Approval:**  
Mike Smith (IT Support Manager)

**CAB Approval Required:**  
Yes – required for change tracking and governance compliance.

---
