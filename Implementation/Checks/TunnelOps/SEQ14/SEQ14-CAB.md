# SUMMARY — SEQ14 TunnelOps

- **Purpose:**
  Replace the legacy TunnelOps “Generic Account” on data analytics machines with two new DAN shared accounts for the Data & Analytics (DAN) team, ensuring proper access segregation and business continuity.
- **Machines:**
    - `WT_PC_3` – Primary DAN analytics VM for WT2 data.
    - `ATF-ATLAS` – Analytics workstation for ATF data.
    - `AERO-BUILD03` – Analytics system for Aero Build operations.
    - `AERODEV` – Development and analytics system for Aero engineering.
- **Accounts:**
    - `shr-tunops-dan01` – Standard shared account for analytics use.
    - `shr-tunops-dan01Adm` – Administrative shared account for system management.
    - `grp-tunops-dan01RW`, `grp-tunops-dan01RO`, `grp-tunops-dan01LAC`, `grp-tunops-dan01Adm`, `grp-tunops-dan01RDC` – AD groups to manage RW, RO, login, admin, and RDP control respectively.
    - Both accounts require annual password rotation and storage in the IT password vault.
    - No internet access except approved URLs:
        - https://dev.azure.com/F1Technical/
        - https://miro.com/
- **Software:**
    - Data analytics and development tools including MATLAB Toolbox and Streamlit/Power BI for reporting.
    - Apps must function identically for new accounts as for TunnelOps.
    - Intranet-based apps: `wt2-ssrs/ATFApp`.
- **Key Actions:**
    - Create new shared accounts and all related AD groups.
    - Configure Log On To restriction per device.
    - Grant specific share and database permissions.
    - Add `grp-tunops-dan01Adm` to local Administrators where required.
    - Remove legacy admin users and groups.
    - Lock out internet access for shared accounts except approved URLs.
    - Validate access to databases, local paths, shares, and applications.
    - Retain TunnelOps account for rollback until testing is complete.
- Final naming to be confirmed with department.

------

# WORKING DOCUMENT — SEQ14

## Scope

- Replace the use of TunnelOps generic credentials with two DAN shared accounts (`shr-tunops-dan01`, `shr-tunops-dan01Adm`) across four analytics systems used for WT2, ATF, and Aero operations.
- Maintain full functionality for analytics tools, file shares, and databases during transition.

## Implementation Steps (authoritative)

1. **Account creation & attributes**
    - Create `shr-tunops-dan01` (standard user) and `shr-tunops-dan01Adm` (admin).
    - Description: Shared DAN analytics and development accounts replacing TunnelOps generic usage.
    - Set “User must change password at next logon” = No.
    - Enforce annual password change and store securely in password vault.
    - Restrict logon via User Object → Log On To → add:
        - `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
2. **RDP Access**
    - Create `RDP_WT_PC_3`, `RDP_ATF-ATLAS`, `RDP_AERO-BUILD03`, and `RDP_AERODEV` in OU “Shared Accounts RDP”.
    - Add users: DAN Team (Anna Perry, Neil Hayes, Mitch Hackwood, Edward Ball, Keith Forsythe).
    - On each device, add relevant `RDP_<MACHINE>` group to local “Remote Desktop Users”.
3. **Local Permissions / Vendor Requirements**
    - Add `grp-tunops-dan01Adm` and DPT Admin to local Administrators.
    - Remove legacy local admin users/groups (ATF Local Admins, MHackwood, AeroBuildAdmins, djclark).
4. **Software / Configuration**
    - Verify functionality for all analytics tools including MATLAB, Power BI, Streamlit, and internal apps (`wt2-ssrs/ATFApp`).
    - Validate read/write to:
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
        - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
        - Local: `C:\Licences`, `C:\WilliamsF1`
    - Database: confirm access to `Aeroprodsql, port 59112`.
5. **Intune / Compliance**
    - Ensure all four devices are Intune-enrolled and compliant with E5 security baseline.
    - Disable internet access for both DAN accounts except `dev.azure.com/F1Technical` and `miro.com`.
6. **Validation**
    - Test login with both DAN accounts on all devices.
    - Confirm app launches, file access, and database connectivity.
    - Verify RDP sessions only function for approved users.
    - Confirm TunnelOps generic account still functional (rollback-ready).
    - Conduct business UAT with DAN stakeholders.

## Open Items

- Confirm any remaining bespoke Aero or WT2 app dependencies still hardcoded for TunnelOps.
- Validate database schema updates and AD sync for new accounts.
- Ensure password rotation process integrated into Keeper/1Password workflow.

## Discarded Approaches

- BA proposal to use domain groups or kiosk mode discarded.
- Project uses standard per-machine “Log On To” restriction and OU-based RDP control.

## Rollback

- Remove DAN accounts from “Log On To” and local groups.
- Delete `RDP_` groups if not required.
- Reinstate legacy TunnelOps generic account temporarily for recovery.
- Revert any modified application configs or security permissions.

------

# CAB DOCUMENT — SEQ14

## Change Summary

Implement new shared DAN accounts on four analytics systems in TunnelOps to replace legacy generic login, while ensuring continuity for software development and data analytics operations.

## Business Justification

Improves accountability, reduces shared credential risk, and aligns with security compliance while maintaining uninterrupted analytics processing.

## Affected Systems

- **Machines:** `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`
- **Accounts:** `shr-tunops-dan01`, `shr-tunops-dan01Adm`, associated `grp-tunops-*` groups
- **Applications:** MATLAB, Power BI, Streamlit, `wt2-ssrs/ATFApp`, internal Aero/WT2 analytics tools

## Risk & Mitigation (practical)

- **Risk:** Application failures when switching from TunnelOps account.
    - *Mitigation:* Retain TunnelOps account until post-validation.
- **Risk:** RDP failures for non-admin users.
    - *Mitigation:* Validate `RDP_` groups before policy application.
- **Risk:** Missed dependencies in hardcoded app credentials.
    - *Mitigation:* Review PowerApps, codebases, and database user mappings before rollout.

## Implementation Plan

See “Implementation Steps” in Working Document.

## Validation Plan

See “Validation” in Working Document.

## Backout Plan

See “Rollback” in Working Document.

## Stakeholders (minimal)

- **Requestor/Owner:** Anna Perry – Lead Wind Tunnel Methodology Engineer
- **Implementer:** Curtis-Davidson – Shared Account Remediation

------

# SUPPORT DOCUMENT — SEQ14

## Purpose

Provide DAN team members with shared access to WT2, ATF, and Aero data analytics systems through secure shared accounts, replacing the old TunnelOps login.

## Day-to-Day Use

Used by the Data & Analytics team (Anna Perry, Calum Maciver, Conor Crickmore, Neil Hayes, etc.) to perform WT2 analytics, Aero development, and data processing activities on four workstations/VMs.

## Access

- Log in using `shr-tunops-dan01` (standard) or `shr-tunops-dan01Adm` (admin).
- Physical login permitted only on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`.
- RDP allowed only for users in the corresponding `RDP_<MACHINE>` group.
- Passwords rotated annually and stored securely.

## Software Notes

- All analytics tools and development environments as previously available.
- Confirm licensing valid for DAN accounts.
- Apps must work identically as with TunnelOps.
- Key app: `wt2-ssrs/ATFApp`.
- Approved internet sites: `https://dev.azure.com/F1Technical/`, `https://miro.com/`.

## Known Paths

- Network:
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
    - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
- Local:
    - `C:\Licences`
    - `C:\WilliamsF1`
- Database:
    - `Aeroprodsql:59112`

## Troubleshooting

- **Can’t log on:** Check “Log On To” list for device name.
- **RDP denied:** Verify membership in `RDP_<MACHINE>` and local “Remote Desktop Users”.
- **App fails:** Check licensing and ensure app config matches DAN account.
- **Internet blocked:** Only `dev.azure.com/F1Technical` and `miro.com` permitted.
- **Database issue:** Confirm `Aeroprodsql` access and credentials mapped.

###### 

# SUMMARY — SEQ14 TunnelOps

- **Purpose:**
  Replace the legacy TunnelOps “Generic Account” on data analytics machines with two new DAN shared accounts, enforcing per-machine logon control and standardised RDP, without any `grp-tunops-*` groups.
- **Machines:**
    - `WT_PC_3` – Primary DAN analytics VM for WT2 data.
    - `ATF-ATLAS` – Analytics workstation for ATF data.
    - `AERO-BUILD03` – Analytics system for Aero Build operations.
    - `AERODEV` – Development and analytics system for Aero engineering.
- **Accounts:**
    - `shr-tunops-dan` – Standard shared account for analytics use.
    - `shr-tunops-danAdm` – Administrative shared account for system management.
    - Annual password rotation; store in the IT password vault.
    - No general internet access; only allow:
        - https://dev.azure.com/F1Technical/
        - https://miro.com/
- **Software:**
    - Data analytics/dev tools (incl. MATLAB Toolbox, Power BI/Streamlit).
    - Intranet app: `wt2-ssrs/ATFApp`.
    - All apps must work identically to historic TunnelOps usage.
- **Key Actions:**
    - Create `shr-tunops-dan` and `shr-tunops-danAdm`.
    - Apply **User Object → Log On To** restrictions to the four machines.
    - Use **`RDP_<MACHINE>`** groups (only) for RDP permit; no `grp-tunops-*` groups anywhere.
    - Grant share, local path and DB access **directly** to the DAN shared accounts (no `grp-tunops-*`).
    - Add `shr-tunops-danAdm` (and DPT Admin) to local Administrators where required; remove legacy business admins.
    - Enforce internet block for these two accounts except the two approved URLs.
    - Validate login, RDP, apps, shares and DB access; retain TunnelOps for rollback until sign-off.
- Final naming to be confirmed with department.

------

# WORKING DOCUMENT — SEQ14

## Scope

- Migrate from TunnelOps generic usage to `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin) on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
- Maintain full functionality (apps, shares, DB) during transition.
- **No use of any `grp-tunops-\*` groups.**

## Implementation Steps (authoritative)

1. **Account creation & attributes**
    - Create `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin).
      Description: DAN shared accounts replacing TunnelOps generic usage on analytics systems.
    - “User must change password at next logon” = No.
    - Enforce annual password rotation; store in password vault.
    - Restrict logon via **User Object → Log On To** → add:
      `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
2. **RDP Access (only if applicable)**
    - Create security groups in OU **“Shared Accounts RDP”**:
      `RDP_WT_PC_3`, `RDP_ATF-ATLAS`, `RDP_AERO-BUILD03`, `RDP_AERODEV`.
    - Add required users (e.g., Anna Perry, Neil Hayes, Mitch Hackwood, Edward Ball, Keith Forsythe, etc.).
    - On each machine, add its `RDP_<MACHINE>` to local **“Remote Desktop Users”**.
3. **Local Permissions / Vendor Requirements**
    - Add `shr-tunops-danAdm` and **DPT Admin Account** to local **Administrators** on each device.
    - Remove legacy business admin entries as stated (ATF Local Admins, MHackwood, AeroBuildAdmins, djclark).
4. **Software / Configuration**
    - Verify/enable for both DAN accounts:
        - Apps incl. MATLAB Toolbox, Power BI/Streamlit; intranet: `wt2-ssrs/ATFApp`.
        - Shares:
          `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
          `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
          `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
          `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
        - Local paths: `C:\Licences`, `C:\WilliamsF1` (where present).
        - Database: `Aeroprodsql` port `59112`.
    - Grant access **directly to `shr-tunops-dan` and `shr-tunops-danAdm`** (no `grp-tunops-*`).
5. **Intune / Compliance**
    - Ensure devices are Intune-enrolled and compliant.
    - Block general internet for both DAN accounts; allow only:
      `https://dev.azure.com/F1Technical/`, `https://miro.com/`.
6. **Validation**
    - Logon tests (physical + RDP) with both accounts on all four devices.
    - App open/close; share R/W tokens; DB connectivity.
    - RDP works only via `RDP_<MACHINE>` groups.
    - Confirm TunnelOps generic still functional for rollback until sign-off.
    - Business UAT with DAN stakeholders.

## Open Items

- Confirm any app code/PowerApps/Power BI config not hardcoded to TunnelOps.
- Confirm database/AD user mappings updated for both DAN accounts.
- Confirm internet allow-list enforcement method for **user-based** restriction.

## Discarded Approaches

- Any `grp-tunops-*` model for RW/RO/LAC/RDC/Adm → **Discarded.**
  Using per-machine **Log On To** and `RDP_<MACHINE>` only, with **direct** ACLs for the two DAN accounts.

## Rollback

- Remove `shr-tunops-dan*` from **Log On To** and local groups.
- Remove `RDP_<MACHINE>` memberships if unused.
- Re-enable TunnelOps generic usage temporarily.
- Revert any app/config/security permissions changed.

------

# CAB DOCUMENT — SEQ14

## Change Summary

Enable `shr-tunops-dan` and `shr-tunops-danAdm` on four analytics systems, retire day-to-day use of TunnelOps generic login, and standardise RDP via `RDP_<MACHINE>` groups only.

## Business Justification

Eliminates shared generic credential risk; enforces accountable access with minimal operational disruption.

## Affected Systems

- **Machines:** `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`
- **Accounts:** `shr-tunops-dan`, `shr-tunops-danAdm`
- **Applications:** MATLAB Toolbox, internal analytics, `wt2-ssrs/ATFApp`, Power BI/Streamlit

## Risk & Mitigation (practical)

- **Risk:** App/licence or path mapping misses.
    - *Mitigation:* Parallel run; token tests on shares/paths; DB connectivity checks.
- **Risk:** RDP access gaps.
    - *Mitigation:* Pre-create/validate `RDP_<MACHINE>` groups and memberships.
- **Risk:** Hidden hardcoded credentials.
    - *Mitigation:* Pre-deployment review of PowerApps/BI/codebases; targeted fixes.

## Implementation Plan

- Follow **Implementation Steps** in Working Document (above).

## Validation Plan

- Follow **Validation** in Working Document (above).

## Backout Plan

- Follow **Rollback** in Working Document (above).

## Stakeholders (minimal)

- **Requestor/Owner:** Anna Perry – Lead Wind Tunnel Methodology Engineer
- **Implementer:** Curtis-Davidson – Shared Account Remediation

------

# SUPPORT DOCUMENT — SEQ14

## Purpose

Provide DAN team with secure shared access to analytics/dev systems using `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin), replacing TunnelOps generic logins.

## Day-to-Day Use

DAN users (e.g., Anna Perry, Calum Maciver, Conor Crickmore, Neil Hayes, etc.) log on to the four systems for WT2/Aero analytics and development tasks.

## Access

- Log in at: `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
- RDP requires membership in the relevant `RDP_<MACHINE>` group (request via IT).
- Passwords rotate annually; stored in the IT vault.

## Software Notes

- Tools as before (incl. MATLAB Toolbox).
- Intranet app: `wt2-ssrs/ATFApp`.
- Apps must behave identically to historical TunnelOps usage.
- Internet blocked for these two accounts except: `dev.azure.com/F1Technical/`, `miro.com/`.

## Known Paths

- Network:
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
    - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
    - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
- Local (where present): `C:\Licences`, `C:\WilliamsF1`
- Database: `Aeroprodsql:59112`

## Troubleshooting

- **Can’t log on:** Confirm machine is listed under the account’s **Log On To**.
- **RDP denied:** Check membership of the correct `RDP_<MACHINE>` and local **Remote Desktop Users**.
- **App fails:** Check licensing/path mappings; compare with legacy TunnelOps config.
- **Internet blocked:** Only two URLs permitted for these accounts.
- **DB errors:** Verify `Aeroprodsql:59112` connectivity and permissions for `shr-tunops-dan`/`shr-tunops-danAdm`.



You can replace the existing rollback section in the SEQ14 Working Document and CAB with this exact version:

------

## Rollback (Final – SEQ14)

- A **full clone** of the system disk (M2 drive) will be taken prior to the start of works.
- All migration activities (Application, Profile, and Registry Migration scripts) will be executed **against the cloned environment**, not the live system.
- The clone serves as the **pre-change validation platform** for verifying `shr-tunops-dan` and `shr-tunops-danAdm` functionality before the live switch.
- The original production disk will be **retained unmodified** and held as the **primary rollback mechanism**.
- In the event of an issue during or after change (functional regression, access failure, or application mis-binding):
    1. Power down the affected machine.
    2. Swap in the **original system disk**.
    3. Boot to confirm restored functionality.
    4. Analyse root cause in the cloned environment.
    5. Re-run the migration scripts once corrected during the **next available maintenance window (01:00–06:00)**.
- This ensures immediate recovery, full traceability, and zero risk to operational continuity.

------

Would you like me to slot this updated rollback wording **into all four sections** (Working Document, CAB, Support Document, and Summary) so you have the complete unified version ready to commit?

##### You said:

Yes, you need to add, well certainly in the implementation, that this is part of the method, the cloning and running against the clone, to assure that it's correct.

###### ChatGPT said:

Excellent — that’s the right call. Below is the **final unified SEQ14 version** with your rollback process formally integrated into both the **Implementation Steps** and the **Rollback** section, ensuring full procedural clarity and audit traceability.

All references to `shr-tunops-dan` / `shr-tunops-danAdm` remain correct, and no `grp-tunops-*` groups are used.

------

# WORKING DOCUMENT — SEQ14 (Finalised)

## Scope

Migrate from TunnelOps generic usage to `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin) on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`.
Maintain full functionality (apps, shares, DB) during transition.
**No `grp-tunops-\*` groups will be used.**

------

## Implementation Steps (authoritative)

1. **Pre-Implementation Preparation (Cloning & Validation Stage)**
    - Create a **full clone of the M2 system disk** prior to any live changes.
    - The clone will be used to run **Application, Profile, and Registry Migration scripts** to transfer environment and configuration data from the TunnelOps generic profile to the new `shr-tunops-dan` and `shr-tunops-danAdm` accounts.
    - All verification and testing of these migration scripts will occur **on the clone only**, not the live system.
    - The **original disk remains untouched** and serves as a full rollback baseline.
    - Once confirmed stable, proceed with the production change in the **early-morning window (01:00–06:00)**.
2. **Account Creation & Attributes**
    - Create `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin).
      Description: DAN shared accounts replacing TunnelOps generic usage.
    - “User must change password at next logon” = No.
    - Enforce annual password rotation; store in password vault.
    - Restrict logon via **User Object → Log On To** →
      `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
3. **RDP Access**
    - Create RDP security groups in OU **Shared Accounts RDP**:
      `RDP_WT_PC_3`, `RDP_ATF-ATLAS`, `RDP_AERO-BUILD03`, `RDP_AERODEV`.
    - Add required DAN users (Anna Perry, Neil Hayes, Mitch Hackwood, Edward Ball, Keith Forsythe, etc.).
    - On each machine, add the relevant `RDP_<MACHINE>` to the local **Remote Desktop Users** group.
4. **Local Permissions / Vendor Requirements**
    - Add `shr-tunops-danAdm` and **DPT Admin** to local **Administrators**.
    - Remove all legacy business admin entries (ATF Local Admins, MHackwood, AeroBuildAdmins, djclark).
5. **Software / Configuration**
    - Validate and configure:
        - Apps: MATLAB Toolbox, Power BI/Streamlit, and intranet `wt2-ssrs/ATFApp`.
        - Shares:
            - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
            - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
            - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
            - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
        - Local: `C:\Licences`, `C:\WilliamsF1` (if present).
        - Database: `Aeroprodsql`, port `59112`.
    - Grant access **directly** to the two DAN accounts (no intermediary groups).
6. **Intune / Compliance**
    - Confirm all devices are Intune-enrolled and compliant.
    - Block general internet for both DAN accounts except:
        - `https://dev.azure.com/F1Technical/`
        - `https://miro.com/`
7. **Validation**
    - Test logon (physical + RDP) for both DAN accounts.
    - Validate app operation, file share R/W, and DB access.
    - Confirm TunnelOps generic remains functional until post-UAT.
    - Conduct UAT with DAN stakeholders.

------

## Rollback

- A **full M2 disk clone** will be retained before the live cut-over.
- Migration scripts are tested and executed against the clone to verify profile and application binding integrity.
- In the event of any fault during or after implementation:
    1. Power down the affected machine.
    2. Re-insert the **original production disk**.
    3. Boot and confirm full restoration of the previous environment.
    4. Investigate the failure on the cloned disk.
    5. Correct the issue and re-run the migration during the **next 01:00–06:00 maintenance window**.
- This ensures immediate rollback capability and zero impact to operational continuity.

------

# CAB DOCUMENT — SEQ14 (Updated Rollback Reference)

## Change Summary

Implement `shr-tunops-dan` and `shr-tunops-danAdm` across four analytics systems, replacing TunnelOps generic account usage with secure, account-based access control.

## Business Justification

Improves traceability, aligns with security standards, and allows safe rollback via disk cloning.

## Implementation Plan

- **Pre-clone each system disk (M2).**
- Execute migration scripts and validation on cloned systems first.
- Apply live change only after clone validation.
- Perform migration, permissions, and RDP setup during the 01:00–06:00 change window.

## Validation Plan

- Perform application, RDP, and database access checks.
- Confirm equivalence with legacy TunnelOps behaviour.
- Maintain TunnelOps account for immediate fallback.

## Backout Plan

- Revert to original disk image.
- Restore original environment and re-attempt on subsequent window.
- No dependency on domain rollback required.

------

# SUPPORT DOCUMENT — SEQ14 (Amended Access & Recovery Notes)

## Access

- Log in using `shr-tunops-dan` (standard) or `shr-tunops-danAdm` (admin).
- Physical access: `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
- RDP access via membership in the `RDP_<MACHINE>` group.
- Passwords rotate annually; securely held in IT vault.
- **In case of fault:** system can be reverted by re-inserting the original disk clone and rebooting — recovery is immediate.

------

Would you like me to now produce the **Summary** and **Support Document** with the cloning steps cross-referenced (“Pre-clone stage per Implementation Step 1”) so that every section (Summary, Working, CAB, Support) aligns in full operational order for upload into the Confluence runbook?

###### 

**Change Title:**
Implementation of new DAN Shared Accounts on TunnelOps Analytics Systems (SEQ14)

**Description of Change:**
Create two new shared accounts — `shr-tunops-dan` and `shr-tunops-danAdm` — to replace the legacy TunnelOps generic account across analytics machines (`WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`).
The process includes full M2 disk cloning before change, migration of profiles and registry via controlled scripts on the clone, and validation prior to production cut-over within the 01:00–06:00 change window.
All access (logon, RDP, admin, shares, and database connectivity) will be configured directly to these two accounts.
Rollback is immediate by restoring the original disk if any post-change issue occurs.

**One-Line Summary:**
Create `shr-tunops-dan` and `shr-tunops-danAdm` accounts on TunnelOps analytics systems to replace the generic TunnelOps login using a validated clone-first migration and full rollback safety.



**Change Title:**
Sequence 14 – Remediation: Shared Account – TunnelOps Analytic Systems

**Description of Change:**
Implement two new shared accounts (`shr-tunops-dan` and `shr-tunops-danAdm`) to replace the legacy TunnelOps generic account across analytic systems (`WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`).
A full M2 disk clone will be taken before any change. Application, Profile, and Registry Migration scripts will be run on the clone to validate configuration before live implementation during the early-morning change window (01:00–06:00).
All permissions, RDP access, and local admin roles will be reassigned directly to the new accounts.
Rollback is achieved instantly by re-inserting the original disk and booting the system if an issue arises.

**One-Line Summary:**
Deploy `shr-tunops-dan` and `shr-tunops-danAdm` on TunnelOps analytic systems to replace the generic account with clone-verified migration and full rollback assurance.



**Option A (Balanced and formal – best for CAB/change control):**
Deploy `shr-tunops-dan` and `shr-tunops-danAdm` across TunnelOps analytic systems, replacing the legacy generic account through a validated clone-based migration process with full rollback capability.

**Option B (Sharper, operational tone):**
Implement `shr-tunops-dan` and `shr-tunops-danAdm` on TunnelOps analytic systems, replacing the generic account via clone-tested migration with immediate rollback assurance.

**Option C (Concise executive summary):**
Replace the TunnelOps generic account with `shr-tunops-dan` and `shr-tunops-danAdm` using a clone-validated migration and guaranteed rollback path.

If you want one definitive line for CAB and service ticket use, **Option A** is the clean, professional choice.

###### 

Got it — here’s a polished and precise version of the **Description of Change**, written in your project tone (straightforward, professional, no fluff):

------

**Description of Change:**
Implement two new shared accounts across the TunnelOps analytic systems to replace the existing generic TunnelOps login. The new accounts — `shr-tunops-dan` and `shr-tunops-danAdm` — will provide controlled access for data analytics and administrative functions on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`.

Each system will first be cloned to create a validated test environment. Application data, user profiles, and registry settings will then be migrated from the generic account to the new accounts using migration scripts executed against the clone. Once verified, the change will be applied to the live systems during the early-morning maintenance window (01:00–06:00).

A full disk backup ensures that if any issue arises, the original disk can be reinserted to restore the system instantly and allow reattempt during the next window.

------

Would you like me to tighten it further into a CAB entry-style 3-paragraph version (Title, Description, One-Liner all together)?

###### 

Perfect. Here’s the **complete, clean CAB entry** — written in your project language and ready to paste straight into the change log or CAB register:

------

**Change Title:**
Sequence 14 – Remediation: Shared Account – TunnelOps Analytic Systems

**Description of Change:**
Implement two new shared accounts across the TunnelOps analytic systems to replace the existing generic TunnelOps login. The new accounts — `shr-tunops-dan` and `shr-tunops-danAdm` — will provide controlled access for data analytics and administrative functions on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, and `AERODEV`.

Each system will be cloned in advance to create a validated test environment. Application data, user profiles, and registry configurations will be migrated from the generic account to the new accounts using migration scripts executed against the clone. Once functionality is confirmed, the changes will be implemented on live systems during the early-morning maintenance window (01:00–06:00).

A full disk backup ensures immediate rollback by reinstating the original disk if any issue arises.

**Justification for Change:**
This work forms part of the Shared Account Remediation Project to replace legacy generic accounts with secure, auditable shared accounts, reducing operational risk and improving accountability.

**One-Line Summary:**
Deploy `shr-tunops-dan` and `shr-tunops-danAdm` on TunnelOps analytic systems to replace the generic account via clone-verified migration with full rollback assurance.

###### 

Got you. Here’s a tight, no-fluff **Test Plan (SEQ14 – TunnelOps Analytic Systems)** that you can paste into CAB/Confluence and run as-is. It follows your clone-first method, proves every dependency, and gives exact commands, paths, and expected results.

# 1) Overview

- **Objective:** Prove `shr-tunops-dan` (standard) and `shr-tunops-danAdm` (admin) fully replace the legacy TunnelOps login on `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV` without loss of function.
- **Window:** 01:00–06:00 (live), clone validation beforehand.
- **Rollback:** Reinsert original M2 disk; boot; resume operations; reattempt next window.

# 2) Scope & Environments

- **Devices:** `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`
- **Accounts:** `shr-tunops-dan`, `shr-tunops-danAdm` (passwords in IT vault; annual rotation)
- **Apps/Paths/DB:**
    - Intranet: `wt2-ssrs/ATFApp`
    - Shares:
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
        - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
    - Local paths: `C:\Licences`, `C:\WilliamsF1`
    - DB: `Aeroprodsql:59112`
- **Internet policy:** Blocked for both DAN accounts except:
    - `https://dev.azure.com/F1Technical/`
    - `https://miro.com/`

# 3) Pre-Change Validation (Clone)

1. **Exact command**
   Disk clone per your standard tool (document run ID in change log).
2. **Purpose**
   Run migration scripts (Application/Profile/Registry) **on the clone**; prove config binds to `shr-tunops-dan*`.
3. **Expected**
   All tests in sections 4–8 pass on the clone. If any fail → fix on clone; do **not** touch production disk.

# 4) Authentication & Logon Control

Run on **each device** for both accounts.

1. **Local logon allowed only on 4 devices**

- **Command**
    - Attempt interactive sign-in on in-scope device with `shr-tunops-dan`, then `shr-tunops-danAdm`.
    - Attempt on a known **out-of-scope** device.
- **Expected**
    - In-scope: logon succeeds.
    - Out-of-scope: blocked (Log On To restriction).

1. **Identity & group sanity**

- **Command (elevated PowerShell)**
  `whoami /user & whoami /groups`
  `hostname`
- **Expected**
  Correct account; groups reflect local “Remote Desktop Users” only when testing RDP; `shr-tunops-danAdm` shows local admin when required.

# 5) RDP Path (Per-Machine)

Run from a normal user workstation (approved tester) to each target.

1. **RDP permitted for authorised users**

- **Command (target device, elevated)**
  `net localgroup "Remote Desktop Users"`
- **Expected**
  Contains `RDP_<MACHINE>`.
- **Command (source)**
  Connect via RDP to each machine; at Windows credential prompt choose **Other user** and enter:
    - `.\shr-tunops-dan`
    - `.\shr-tunops-danAdm`
- **Expected**
    - Connection succeeds if tester is in `RDP_<MACHINE>`.
    - Non-members get RDP denied.

1. **Port & reachability (optional quick check)**

- **Command (source PowerShell)**
  `Test-NetConnection <target> -Port 3389`
- **Expected**
  `TcpTestSucceeded : True`

# 6) File Shares & Local Paths

Run for both accounts on each device (interactive or RDP).

1. **Map and token test (T: and P:)**

- **Command (PowerShell)**

  ```
  net use T: "\\smb.wf1isil01.factory.wf1\department2"
  net use P: "\\factory.wf1\DFS2"
  Test-Path "T:\ATF\02_Development"
  Test-Path "T:\ATF\09_Temp"
  Test-Path "T:\ATF\10_Perso"
  Test-Path "P:\Software\TrackAeroSoftware\MATLAB Toolbox\Data"
  New-Item "T:\ATF\09_Temp\_token_<MACHINE>_<USER>.txt" -ItemType File -Value (Get-Date) | Out-Null
  Remove-Item "T:\ATF\09_Temp\_token_<MACHINE>_<USER>.txt"
  ```

- **Expected**
  Paths exist; create/delete succeeds for RW locations.

1. **Local path access**

- **Command (PowerShell)**

  ```
  foreach ($p in "C:\Licences","C:\WilliamsF1") {
    if (Test-Path $p) {
      New-Item "$p\_token_<USER>.txt" -ItemType File -Value (Get-Date) | Out-Null
      Remove-Item "$p\_token_<USER>.txt"
    }
  }
  ```

- **Expected**
  Succeeds where folders exist. `shr-tunops-dan` must **not** need admin.

# 7) Database Connectivity (Aeroprodsql:59112)

1. **Port reachability**

- **Command**
  `Test-NetConnection Aeroprodsql -Port 59112`
- **Expected**
  `TcpTestSucceeded : True`

1. **Logical access (if sql tools available)**

- **Command (example)**
  `sqlcmd -S Aeroprodsql,59112 -Q "SELECT 1"`
  (or run the app that uses this DB and perform a known read/write action)
- **Expected**
  Query returns `1` (or app operation succeeds). Repeat with both accounts.

# 8) Applications

Run on each device for both accounts.

1. **Intranet app**

- **Step**
  Open browser → navigate `http://wt2-ssrs/ATFApp`.
- **Expected**
  App loads; user can execute the standard report/action used under TunnelOps.

1. **MATLAB Toolbox data path**

- **Step**
  Open MATLAB (if installed) or the dependent app; confirm it resolves `P:\Software\TrackAeroSoftware\MATLAB Toolbox\Data`.
- **Expected**
  No missing-path/licensing prompts.

1. **Power BI / Streamlit (if applicable)**

- **Step**
  Open existing DAN report/process; refresh once.
- **Expected**
  Loads without TunnelOps-hardcoded credential issues.

1. **General app launch regression**

- **Step**
  Launch/close all listed analytics tools previously used by TunnelOps on that device.
- **Expected**
  No errors; same behaviour as before.

# 9) Internet Restrictions

Run on each device for both accounts.

- **Allowed**
    - Navigate to `https://dev.azure.com/F1Technical/` and `https://miro.com/`.
- **Denied (pick any well-known site, e.g. `https://example.com/`)**
- **Expected**
    - Allowed sites load; other sites blocked by policy (browser or network control).

# 10) Local Admin & Least Privilege

- **Command (elevated on target)**
  `net localgroup administrators`
- **Expected**
    - Contains **DPT Admin** and (where required) `shr-tunops-danAdm`.
    - **Removed**: ATF Local Admins, `MHackwood`, `AeroBuildAdmins`, `djclark`.
- **Negative test:**
  `shr-tunops-dan` must **not** perform admin actions (e.g., services.msc stop/start fails).

# 11) Intune / Compliance

- **Command**
  `dsregcmd /status` (device join state)
  Company Portal / Intune console check (record compliance stamp)
- **Expected**
  Device shows compliant; no policy drift flagged.

# 12) Out-of-Scope Denial Tests

- Attempt logon with `shr-tunops-dan*` on a **non-listed** device.
- **Expected:** logon denied (Log On To constraint).

# 13) UAT & Sign-off

- **Actors:** Anna Perry (owner) + named DAN users.
- **Flow:** Run sections 4–9 on live after clone validation.
- **Deliverable:** UAT sheet signed; defects logged with repro steps and screenshots.

# 14) Defect Handling

- **Triage:** Capture device, account, timestamp, exact error text, and last successful TunnelOps behaviour.
- **Fix path:** Reproduce on clone → patch migration/config → re-run failing test(s) → reattempt in next 01:00–06:00 window.

# 15) Pass/Fail Criteria (Go/No-Go)

- **Go:** 100% pass on clone; on live, no Sev-1/2 failures; UAT signed by owner.
- **No-Go:** Any Sev-1 (logon blocked, RDP blocked for all, share/DB unusable, key app fails). Trigger **rollback** (swap original disk), log incident, and schedule reattempt.

------

If you want this in a **copy-paste checklist** per device/account, say the word and I’ll spit out a two-page printable sheet with tick-boxes and command blocks for each of the four machines.



------

### Database Reference Cross-Check

In section **10.1 Summary of Recommended Options & Implementation Decisions**, the document explicitly states:

> “Members of the grp-tunops-dan01RW AD Group must be able to read / write (as appropriate) to the following databases:
>
> **2. Databases**
>
> **2.1. Aeroprodsql, 59112**
>
> Decision Meeting 19/05/2025 – implement as above. [tunnelops-dan01-FR0064-01]”

That means **`Aeroprodsql` on port `59112` is indeed part of the SEQ14 scope** — it’s the database the DAN shared accounts must reach once the migration is complete.

So yes, your test plan is correct to include:
`Aeroprodsql:59112` as a validation step under **Database Connectivity** for both `shr-tunops-dan` and `shr-tunops-danAdm`.

No need to upload again — it’s verified directly from the original SEQ14 source.

##### You said:

Just write me a test plan for after implementation and I can copy underneath, just to list the steps of a test plan.

###### ChatGPT said:

Here’s a clean, concise **Post-Implementation Test Plan – SEQ14 (TunnelOps Analytic Systems)** that you can copy and expand beneath. It’s written for direct inclusion in your CAB or change record.

------

## Post-Implementation Test Plan

**Purpose:**
To verify that `shr-tunops-dan` and `shr-tunops-danAdm` operate correctly on all TunnelOps analytic systems following deployment, and that all functions previously available to the generic TunnelOps account remain intact.

------

### Test Steps

1. **Logon Verification**
    - Confirm both new shared accounts can log on locally to each system: `WT_PC_3`, `ATF-ATLAS`, `AERO-BUILD03`, `AERODEV`.
    - Confirm logon is denied on any system not listed in scope (Log On To restriction check).
2. **RDP Access**
    - From an authorised workstation, connect via RDP using each account.
    - Confirm RDP works only for users in the relevant `RDP_<MACHINE>` group.
3. **Application Launch**
    - Log in with each new account and open all installed analytic and development applications.
    - Confirm that every application opens, authenticates, and runs normally.
    - Key apps: `wt2-ssrs/ATFApp`, MATLAB Toolbox, Power BI reports, Streamlit tools.
4. **Network Share Access**
    - Verify access to:
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\02_Development`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\09_Temp`
        - `\\smb.wf1isil01.factory.wf1\department2\ATF\10_Perso`
        - `\\factory.wf1\DFS2\Software\TrackAeroSoftware\MATLAB Toolbox\Data`
    - Test read/write by creating and deleting a small token file.
5. **Local Path Access**
    - Confirm the accounts can read/write to `C:\Licences` and `C:\WilliamsF1` (if present).
6. **Database Connectivity**
    - Using the relevant app or `sqlcmd`, verify successful connection to
      `Aeroprodsql` (port 59112).
    - Confirm read/write operations where applicable.
7. **Internet Access Restriction**
    - Test that both accounts can access only:
        - `https://dev.azure.com/F1Technical/`
        - `https://miro.com/`
    - Confirm all other sites are blocked.
8. **Administrative Privilege Separation**
    - Confirm `shr-tunops-danAdm` has required local admin rights.
    - Confirm `shr-tunops-dan` cannot perform admin functions.
9. **Intune / Compliance Check**
    - Verify each device remains Intune-enrolled and compliant with E5 baseline.
10. **UAT Sign-off**
    - Business owner (Anna Perry) and nominated DAN users confirm all functionality and data flows operate normally.
11. **Rollback Readiness**
    - Retain cloned disk and verify it can boot if rollback is required.

------

**Expected Outcome:**
All applications, shares, and databases function as before under the new accounts, with access correctly restricted and no operational regressions.

------



