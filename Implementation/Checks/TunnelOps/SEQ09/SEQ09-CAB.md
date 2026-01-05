### Canonical Account Names (effective immediately)

- **shr-tunops-tdp01 → shr-tunops-tdp**
- **shr-tunops-tdp01Adm → shr-tunops-tdpAdm**

### Scope of Change

This applies to **all document sections**, including but not limited to:

- CAB DOCUMENT — SEQ09
- WORKING DOCUMENT — SEQ09
- Implementation Plan
- Validation Plan
- Rollback / Backout Plan
- Support Document
- Any future CABs, Jira, AD descriptions, and operational notes

### What I will do going forward

- Use **only**:
    - `shr-tunops-tdp`
    - `shr-tunops-tdpAdm`
- No mixed naming.
- No legacy `01` references left behind.
- Language stays implementation-focused and consistent with project standards.

If you want, next step I can:

- Re-emit a **clean, final CAB + Implementation Plan** with the corrected names baked in everywhere, or
- Produce a **diff-style change note** explicitly showing what was renamed for audit clarity.

Your call.

Re-emit a clean, final CAB + Implementation Plan with the corrected names baked in everywhere

TunnelOps-Seq09-tdp

------

# CAB DOCUMENT — SEQ09

## Change Summary

Implement TDP shared account remediation for TunnelOps database devices using the project-standard method: explicit machine-based logon restrictions and machine-specific RDP handling, with corrected shared account naming.

## Business Justification

This change reduces the security and audit risk associated with long-standing use of a generic account while preserving 24/7 database operations. It introduces tightly scoped shared accounts, aligned with actual operational need, and retains a clear and immediate rollback path to protect business continuity.

## Affected Systems

- **Machines:**
    - WT2-Atlas
    - WT2-Replication
    - W9418
    - W9423
    - AERO-BUILD03
- **Accounts:**
    - `shr-tunops-tdp`
    - `shr-tunops-tdpAdm`
- **Applications:**
    - Database management applications (SQL / SQL-Race)
    - Related Williams bespoke applications dependent on database and AD authentication

## Risk & Mitigation (practical)

- **Risk:** Required application permissions are missing under the new shared accounts.
  **Mitigation:** Validate all required applications using the shared accounts before reducing reliance on the TunnelOps generic account.
- **Risk:** RDP access failure for users who require remote access.
  **Mitigation:** Pre-create machine-specific RDP security groups and add them to local “Remote Desktop Users” on each target machine before enforcement.

## Implementation Plan

Execute the steps defined in the **Implementation Plan — SEQ09** (below).

## Validation Plan

Execute the validation steps defined in the **Implementation Plan — SEQ09**, Section 9 (Validation).

## Backout Plan

Execute the rollback steps defined in the **Implementation Plan — SEQ09**, Section 10 (Rollback).

## Stakeholders (minimal)

- **Requestor / Owner:** Mich Hackwood (TDP)
- **Implementer:** Curtis-Davidson (Shared Account Remediation)

------

# IMPLEMENTATION PLAN — SEQ09

This plan executes the approved remediation for **TunnelOps – TDP (SEQ09)** using the corrected shared account names and the agreed project-standard controls.

## 1. Preparation

- Confirm implementation window with TunnelOps / TDP to avoid disruption to live database operations.
- Confirm target machines:
    - WT2-Atlas
    - WT2-Replication
    - W9418
    - W9423
    - AERO-BUILD03
- Confirm named users requiring access (Mich Hackwood, Richard Sinclair).
- Confirm rollback readiness: TunnelOps generic account remains unchanged and usable.

## 2. Shared Account Creation

- Create AD user **`shr-tunops-tdp`**.
  Description: TDP shared account for non-admin database-related access.
- Create AD user **`shr-tunops-tdpAdm`**.
  Description: TDP shared account for admin-level database and system tasks where required.
- Update AD notes on both accounts:
    - Business owner: Mich Hackwood.
    - Purpose of account.
    - Annual password rotation requirement.
    - Password must be stored in IT Support password vault.
- Set “User must change password at next logon” = **No**.

## 3. Logon Restriction (Authoritative)

- On each shared account object (**shr-tunops-tdp** and **shr-tunops-tdpAdm**):
    - Configure **User Object → Log On To**.
    - Explicitly allow logon only to:
        - WT2-Atlas
        - WT2-Replication
        - W9418
        - W9423
        - AERO-BUILD03
- Verify shared accounts cannot log on to any other machines.

## 4. RDP Configuration

- For each target machine where RDP access is required:
    - Create security group **`RDP_<MACHINE_NAME>`** in OU **Shared Accounts RDP**.
    - Add required users (Mich Hackwood, Richard Sinclair).
    - Add **`RDP_<MACHINE_NAME>`** to the local **Remote Desktop Users** group on the machine.
- Confirm no shared or cross-machine RDP groups exist.

## 5. Local Administration Alignment

- On each device:
    - Leave Database Management Services admin accounts unchanged.
    - Add **`sqlthirdpartyadmins`** to local **Administrators** on:
        - WT2-Atlas
        - WT2-Replication
    - Ensure **`shr-tunops-tdpAdm`** has required admin capability via local group membership.
    - Remove legacy or non-required business users and groups from local **Administrators** as documented.
- Do **not** modify TunnelOps generic account permissions at this stage.

## 6. Application Enablement

- Verify all database management and bespoke applications previously available under the TunnelOps generic account are accessible using:
    - `shr-tunops-tdp`
    - `shr-tunops-tdpAdm`
- Apply required database, AD, or application updates so shared accounts are recognised where authentication records are required.
- Ensure changes are aligned across Dev / Test / Prod where applicable.

## 7. Internet Access Controls

- Enforce no general Internet access for:
    - `shr-tunops-tdp`
    - `shr-tunops-tdpAdm`
- Allow access only to approved sites:
    - https://dev.azure.com/F1Technical/
    - https://miro.com/
- Confirm admin accounts retain Internet access where operationally required.

## 8. Decommissioning Action

- Decommission **WT2-Atlas02** as agreed, coordinated by the Database Management Services team.

## 9. Validation

- Perform validation checks:
    - Local logon tests with both shared accounts on all permitted machines.
    - RDP tests using machine-specific RDP groups.
    - Confirm `shr-tunops-tdp` cannot perform admin-only actions.
    - Confirm `shr-tunops-tdpAdm` can perform required admin actions.
    - Application launch and functional sanity checks.
    - Confirm TunnelOps generic account still operates normally (rollback safety).

## 10. Rollback

- Remove **`shr-tunops-tdp`** and **`shr-tunops-tdpAdm`** from **Log On To** restrictions.
- Remove `RDP_<MACHINE_NAME>` groups from local **Remote Desktop Users**.
- Revert any local admin group changes made during implementation.
- Instruct users to revert temporarily to the TunnelOps generic account while issues are investigated.

------

This is now the **clean, final, name-corrected CAB + Implementation Plan** f