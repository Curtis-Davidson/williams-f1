

###### 

TunnelOps SEQ15.      **UT-NoBS Extraction Prompt v1.0** specification is fully loaded and correct.

When you enter **Prompt Mode** using that header, I will:

- Treat it as an **active extraction directive** for Williams F1 Shared Account Remediation.
- Parse the BA discovery text only for **operational and actionable content**.
- Apply all three **Constant Project Rules** (logon restriction, RDP OU structure, and naming confirmation).
- Output **exactly four Markdown sections** in this order and format:

```
# SUMMARY — SEQ{NN} TunnelOps
# WORKING DOCUMENT — SEQ{NN}
# CAB DOCUMENT — SEQ{NN}
# SUPPORT DOCUMENT — SEQ{NN}
```

No corporate filler, no references to other documents, no American spelling.
Only clear, implementation-ready content in British English — precisely as your template dictates.

So yes, when you paste the next BA text block beneath that prompt header, I’ll execute it in **UT-NoBS Extraction Mode** exactly as defined.

###### 

Got it — I’ve parsed **TunnelOps–Seq15–DIA v1.00 (Approved 19/05/2025)** in full.
You can now activate **Prompt Mode** by pasting your line:

```
UT-NoBS Extraction Prompt v1.0 (Reusable — paste this above your sequence text)
```

Then immediately paste the BA text block (or just state “Use TunnelOps–Seq15–DIA doc”).

Once you do that, I’ll output the four required Markdown sections:

1. **SUMMARY — SEQ15 TunnelOps**
2. **WORKING DOCUMENT — SEQ15**
3. **CAB DOCUMENT — SEQ15**
4. **SUPPORT DOCUMENT — SEQ15**

All fully aligned to your **Constant Project Rules** (logon restriction via AD User Object → Log On To, RDP OU group method, and final naming confirmation).



##### 



Perfect. I’ve parsed and confirmed full extraction from your clean `.txt` source: **TunnelOps–Seq15–DIA v1.00 (Approved 19/05/2025)** — identical content to the `.docx` version, but ideal for prompt parsing.

Ready for execution under **UT-NoBS Extraction Prompt v1.0**.

To generate the full four-section Markdown output (Summary, Working Document, CAB, Support), run exactly this:

```
UT-NoBS Extraction Prompt v1.0 (Reusable — paste this above your sequence text)
INPUT:
- Department: TunnelOps
- Sequence ID: SEQ15
- Raw BA text (verbatim, pasted below):
<<<BA_TEXT_START
[Paste the full content of TunnelOps-Seq15-dia (1).txt here]
BA_TEXT_END>>>
```

Or simply type:
**“Use TunnelOps–Seq15–DIA document as input.”**

Once you trigger it, I’ll return the complete **UT-NoBS formatted extraction** with:

- AD account creation (shr-tunops-dia01 / shr-tunops-dia01Adm)
- AD group design (RW, RO, LAC, RDC, Adm)
- Device L2160 configuration and restrictions
- RDP, local admin, Intune, file-migration, and testing steps
- Risks, rollback, and validation plans

###### 

# SUMMARY — SEQ15 TunnelOps

- **Purpose:**
  Transition diagnostics operations for WT2 from the legacy “TunnelOps” generic account to two new controlled shared accounts (`shr-tunops-dia01` and `shr-tunops-dia01Adm`) for use on Device L2160, ensuring business continuity, accountability, and compliance.
- **Machines:**
    - **L2160** – Laptop above WT2, connected to diagnostic hardware; runs diagnostic apps and monitoring tools. Operates 24/7 and must remain accessible for authorised engineers.
- **Accounts:**
    - **New:** `shr-tunops-dia01` (standard access)
    - **New:** `shr-tunops-dia01Adm` (administrative access)
    - **Existing:** `TunnelOps` (to be retained temporarily for rollback)
    - - Use existing groups
    - Passwords must rotate annually and be stored securely in IT’s 1Password vault.
    - AD notes must include sponsor, password reset schedule, and account purpose.
    - Final naming to be confirmed with department.
- **Software:**
    - Bespoke diagnostic systems for WT2 (developed internally by Williams).
    - Uses locally stored data under `C:\Users\shr-tunops-dia01\` and `C:\Williams`.
    - Reads/writes to network share: `T:\ATF` → `\\smb.wf1-isil01.factory.wf1\department2`.
    - Required web apps: `https://dev.azure.com/F1Technical/` and `https://miro.com/`.
- **Key Actions:**
    - Create two DIA shared accounts and associate AD groups.
    - Restrict logon on accounts to L2160 via “Log On To”.
    - Move all `C:\Users\TunnelOps\` data to shared-access directories.
    - Reconfigure diagnostic apps to use new account paths.
    - Lock down Internet access (except specified web apps).
    - Intune compliance verification due to USB-based tools (Canon DSLR, PICO Logger, Maxon EPOS, Arduino).
    - Implement validation tests for local and RDC logins, disk access, and app performance.
    - Maintain rollback capability to TunnelOps account until verified stable.

------

# WORKING DOCUMENT — SEQ15

## Scope

Covers migration of WT2 diagnostic systems from the “TunnelOps” generic account to new DIA shared accounts on Device L2160, ensuring users have functional access via defined AD controls while maintaining rollback readiness.

------

## Implementation Steps (authoritative)

1. **Account Creation & Attributes**
    - Create `shr-tunops-dia01` (Standard user for diagnostics).
    - Create `shr-tunops-dia01Adm` (Admin user for diagnostics tools).
    - Set “User must change password at next logon” = **No** (service account).
    - Restrict logon via AD User Object → **Log On To → L2160** only.
2. **RDP Access**
    - Create `RDP_L2160` group in OU **“Shared Accounts RDP”**.
    - Add required DIA users (Wind Tunnel & Methodology Engineers).
    - On L2160, add `RDP_L2160` to **local “Remote Desktop Users”**.
3. **Local Permissions / Vendor Requirements**
    - Add `grp-tunops-dia01Adm` and DPT Admin account to **local Administrators**.
    - Remove any legacy Aero or business user admin groups.
4. **Software / Configuration**
    - Retain all existing diagnostic software; reconfigure file paths:
        - Move `C:\Users\TunnelOps\` → `C:\Users\shr-tunops-dia01\`.
        - Confirm apps read/write from `C:\Williams` and `T:\ATF`.
    - Update application configs referencing old TunnelOps directories.
    - Ensure continued functionality of USB-connected diagnostic devices.
    - Lock down Internet access except `dev.azure.com/F1Technical` and `miro.com`.
5. **Intune / Compliance**
    - Verify Device L2160 remains Intune-compliant.
    - Ensure USB devices (Canon DSLR, PICO Logger, Maxon EPOS, Arduino) remain permitted.
6. **Validation**
    - Confirm both new shared accounts can log in at L2160 (physical & RDC).
    - Verify diagnostic apps open and operate correctly.
    - Confirm disk and network path access for both accounts.
    - Confirm RDP group membership and connection.
    - Confirm TunnelOps account still functional (rollback safety).

------

## Open Items

- Confirm whether L2160 will remain outside secure cabinet scope.
- Confirm OneDrive/SharePoint exclusion is still intentional.
- Validate if any legacy script or OPC message uses hardcoded credentials.
- Verify that all WT2 diagnostic tools continue working post-migration.
- Schedule exact implementation window with business to mitigate downtime.

------

## Discarded Approaches

- **Generic Account Retention:** Not recommended; replaced by shared account model.



- **Immediate Decommission of TunnelOps:** Deferred until verified stability.
  → Using project-standard **logon restriction via AD User Object → “Log On To”** and **machine-specific RDP OU structure** instead.

------

## Rollback

- Remove `shr-tunops-dia01*` accounts and related AD groups from all permissions.
- Re-add “TunnelOps” to local groups if removed.
- Restore previous `C:\Users\TunnelOps\` app paths.
- Disable new groups `grp-tunops-dia01*` if rollback required.

------

# CAB DOCUMENT — SEQ15

## Change Summary

Implement shared account remediation for **Device L2160 (WT2 diagnostics)** by introducing `shr-tunops-dia01` (standard) and `shr-tunops-dia01Adm` (admin) accounts with structured AD controls and RDP group isolation.

## Business Justification

Replace legacy TunnelOps logins with managed shared accounts to strengthen security, maintain traceability, and standardise account handling while preserving operational continuity of WT2 diagnostics.

## Affected Systems

- **Machines:** L2160 (WT2 Diagnostics Laptop)
- **Accounts:** TunnelOps → shr-tunops-dia01 / shr-tunops-dia01Adm
- **Applications:** WT2 Diagnostics software (bespoke internal tools)

## Risk & Mitigation (practical)

- **Risk:** Functionality loss if diagnostic apps reference TunnelOps paths.
  **Mitigation:** Migrate and test data directories before cutover.
- **Risk:** RDP group misconfiguration.
  **Mitigation:** Pre-create `RDP_L2160` group; validate before enabling policy.
- **Risk:** USB diagnostic hardware blocked by Intune.
  **Mitigation:** Exclude required hardware IDs in Intune policy.
- **Risk:** Access disruption due to logon restrictions.
  **Mitigation:** Implement during maintenance window with on-site validation.

## Implementation Plan

Follow Implementation Steps from Working Document.

## Validation Plan

Perform Validation tests from Working Document.

## Backout Plan

Follow Rollback steps from Working Document.

## Stakeholders

- **Requestor/Owner:** Mich Hackwood – Wind Tunnel Systems Manager
- **Implementer:** Curtis-Davidson – Shared Account Remediation

------

# SUPPORT DOCUMENT — SEQ15

## Purpose

Device L2160 monitors and diagnoses WT2 system performance. It hosts diagnostic software connected to measurement tools and runs 24/7. Shared accounts enable controlled access while retaining operational flexibility.

## Day-to-Day Use

Authorised Wind Tunnel Engineers, Methodology Engineers, and Systems staff log in via shared accounts to review data, run diagnostics, or monitor live readings. The device remains locked when unattended.

## Access

- **Shared Accounts:**
    - `shr-tunops-dia01` – Standard diagnostics operations
    - `shr-tunops-dia01Adm` – Administrative diagnostics setup
- **RDP:**
    - Access controlled via AD group `RDP_L2160` (members managed by IT).
    - To gain RDP access, request addition to this group via service desk.

## Software Notes

- WT2 bespoke diagnostic applications (internal builds).
- Reads/writes data under `C:\Williams` and `C:\Users\shr-tunops-dia01\`.
- Network share: `\\smb.wf1-isil01.factory.wf1\department2` (T:\ATF).
- No Internet access except `dev.azure.com/F1Technical` and `miro.com`.
- Dependent USB devices: Canon DSLR, PICO Logger, Maxon EPOS, Arduino.

## Known Paths

- Local: `C:\Williams\`
- Local: `C:\Users\shr-tunops-dia01\`
- Network: `\\smb.wf1-isil01.factory.wf1\department2\ATF`

## Troubleshooting

- **Can’t log on:** Check “Log On To” on AD user object includes L2160.
- **RDP denied:** Verify user is in `RDP_L2160` and that group is in local “Remote Desktop Users”.
- **App fails:** Verify path mappings and confirm account has RW access to `C:\Williams`.
- **USB hardware not detected:** Review Intune policy exclusions.
- **Rollback required:** Temporarily log in using legacy `TunnelOps` account until resolved.

------



------

# SUMMARY — SEQ15 TunnelOps

- **Purpose:**
  Transition WT2 diagnostic operations from the legacy “TunnelOps” generic account to two managed DIA shared accounts with clear access control, accountability, and security alignment — without disrupting business continuity.
- **Machines:**
    - **L2160** – Diagnostics laptop above WT2. Connected to multiple electronic tools capturing operational data 24/7. Runs bespoke in-house diagnostic apps.
- **Accounts:**
    - **New Shared Accounts:**
        - `shr-tunops-dia01` — Standard user for diagnostics operations.
        - `shr-tunops-dia01Adm` — Admin user for diagnostics configuration.
    - **Existing Account:**
        - `TunnelOps` — Temporarily retained for rollback validation.
    - **AD Groups:**
        - Use correct existing groups
- **Users (Access to both shared accounts):**
    - **Wind Tunnel Engineers:**
        - Keith Forsythe
        - James Busfield
        - Edward Ball
        - Ben Hanson
        - Luke Deacon
        - Harrison Towell
    - **Methodology Engineers:**
        - Anna Perry
        - Calum Maciver
        - Connor Crickmore
    - **Wind Tunnel Systems:**
        - Mich Hackwood
        - Alex Wibawa
        - Christina Sullivan
        - Ben Stokes
        - Andrew Wilkie
    - **Other:**
        - Neil Hayes
        - Thomas Sagar
- **Software:**
    - Bespoke in-house diagnostic apps for WT2 monitoring (non-licensed internal code).
    - Data directories:
        - Local → `C:\Users\shr-tunops-dia01\`, `C:\Williams\`
        - Network → `T:\ATF` mapped to `\\smb.wf1-isil01.factory.wf1\department2`
    - Permitted Web Apps:
        - `https://dev.azure.com/F1Technical/`
        - `https://miro.com/`
- **Key Actions:**
    - Create new DIA accounts and associate above users in relevant groups.
    - Restrict both accounts to logon only on L2160.
    - Configure `RDP_L2160` security group under OU “Shared Accounts RDP”.
    - Move and re-point diagnostic app data from `C:\Users\TunnelOps\` to `C:\Users\shr-tunops-dia01\`.
    - Lock Internet except approved sites.
    - Validate Intune compliance due to USB diagnostic devices.
    - Confirm operational parity before decommissioning TunnelOps account.
    - Final naming to be confirmed with department.

------

# WORKING DOCUMENT — SEQ15

## Scope

Applies to Device L2160 (WT2 diagnostics). Covers migration of diagnostic operations, users, data paths, and permissions from `TunnelOps` to `shr-tunops-dia01` and `shr-tunops-dia01Adm`.

------

## Implementation Steps (authoritative)

1. **Account Creation & Attributes**
    - Create AD user `shr-tunops-dia01` (standard).
    - Create AD user `shr-tunops-dia01Adm` (administrative).
    - Set “User must change password at next logon” = No.
    - Restrict via AD → User Object → **Log On To → L2160** only.
2. **RDP Access**
    - Create `RDP_L2160` group in OU “Shared Accounts RDP”.
    - Add all DIA users (full list above).
    - On L2160, add `RDP_L2160` to local **Remote Desktop Users**.
3. **Local Permissions / Vendor Requirements**
    - Add `grp-tunops-dia01Adm` and DPT Admin to **Administrators** group.
    - Remove any legacy Aero or unrelated admin groups.
4. **Software / Configuration**
    - Verify and re-configure diagnostic applications to point to:
        - `C:\Users\shr-tunops-dia01\`
        - `C:\Williams\`
        - `T:\ATF` → `\\smb.wf1-isil01.factory.wf1\department2`
    - Migrate existing files from `C:\Users\TunnelOps\`.
    - Re-point application output/input paths as required.
    - Allow only approved sites (`F1Technical`, `Miro`) for shared accounts.
    - Validate USB devices (Canon DSLR, PICO Logger, Maxon EPOS, Arduino) continue to function.
5. **Intune / Compliance**
    - Confirm Intune policy allows the above USB devices.
    - Check Device L2160 remains compliant post-changes.
6. **Validation**
    - Login verification for both new accounts (physical + RDC).
    - Confirm diagnostic software runs normally.
    - Test data read/write for local and network paths.
    - Validate group memberships (`RW`, `Adm`, `LAC`, `RDC`).
    - Test rollback via TunnelOps login.

------

## Open Items

- Confirm device will remain physically above WT2 and unlocked only when supervised.
- Confirm whether local firewall rules need adjusting for diagnostic tool connectivity.
- Confirm software code paths (hardcoded credentials) reviewed and refactored.
- Validate timing for annual password rotation automation.

------

## Discarded Approaches

- **Continue using TunnelOps:** rejected due to audit and traceability risks.
- **Kiosk mode:** unsafe for equipment with physical diagnostics hardware.
- **Immediate decommission:** deferred until full validation complete.
  → Implementing via **Log On To restriction** and **machine-specific RDP groups** as per project standard.

------

## Rollback

- Remove both shared accounts and related AD groups from L2160.
- Reinstate TunnelOps membership on local and AD groups.
- Restore original user folder (`C:\Users\TunnelOps\`) and configuration.
- Disable shared accounts if rollback persists beyond 48 hours.

------

# CAB DOCUMENT — SEQ15

## Change Summary

Introduce new DIA shared accounts for WT2 diagnostics (L2160) with defined access control and RDP governance, replacing the generic TunnelOps account.

## Business Justification

Provides secure, traceable access to critical diagnostics functions, aligned with shared account remediation policy, without disrupting 24/7 wind tunnel operations.

## Affected Systems

- **Machine:** L2160 (WT2 diagnostic laptop)
- **Accounts:** TunnelOps → shr-tunops-dia01 / shr-tunops-dia01Adm
- **Applications:** WT2 bespoke diagnostic software suite

## Risk & Mitigation

- **Risk:** Diagnostic apps fail post-migration due to path dependency.
  **Mitigation:** Reconfigure and test all app paths pre-cutover.
- **Risk:** USB diagnostics blocked by Intune.
  **Mitigation:** Exclude required device IDs in Intune policy.
- **Risk:** Login disruption from AD restrictions.
  **Mitigation:** Apply during maintenance window with rollback on standby.
- **Risk:** Licensing oversight.
  **Mitigation:** Verify internal builds need no external licensing.

## Implementation Plan

Follow Working Document implementation sequence.

## Validation Plan

Perform functional tests covering login, RDC, local and network access, and diagnostics operation.

## Backout Plan

Follow Rollback procedure in Working Document.

## Stakeholders

- **Owner:** Mich Hackwood – Wind Tunnel Systems Manager
- **Implementer:** Curtis-Davidson – Shared Account Remediation Lead

------

# SUPPORT DOCUMENT — SEQ15

## Purpose

Provide secure and accountable shared access to L2160 for WT2 diagnostic analysis, replacing the legacy generic TunnelOps account.

## Day-to-Day Use

Engineers log in via shared DIA accounts to run diagnostics tools, collect data, and analyse WT2 system conditions. Device stays locked when unattended.

## Access

- **Shared Accounts:**
    - `shr-tunops-dia01` – diagnostics use
    - `shr-tunops-dia01Adm` – diagnostics admin tasks
- **Users:**
  Keith Forsythe, James Busfield, Edward Ball, Ben Hanson, Luke Deacon, Harrison Towell, Anna Perry, Calum Maciver, Connor Crickmore, Mich Hackwood, Alex Wibawa, Christina Sullivan, Ben Stokes, Andrew Wilkie, Neil Hayes, Thomas Sagar
- **RDP:**
  Managed via `RDP_L2160` group (membership controlled by IT).

## Software Notes

- In-house WT2 diagnostics software.
- Data paths:
    - Local: `C:\Users\shr-tunops-dia01\`, `C:\Williams\`
    - Network: `\\smb.wf1-isil01.factory.wf1\department2\ATF`
- Internet restricted to `F1Technical` and `Miro`.
- Connected devices: Canon DSLR, PICO Logger, Maxon EPOS, Arduino.

## Known Paths

- `C:\Users\shr-tunops-dia01\`
- `C:\Williams\`
- `\\smb.wf1-isil01.factory.wf1\department2\ATF`

## Troubleshooting

- **Login fails:** Confirm L2160 listed in “Log On To”.
- **RDP denied:** Check user in `RDP_L2160` and group in local “Remote Desktop Users”.
- **App errors:** Confirm data path permissions and local admin rights for `shr-tunops-dia01Adm`.
- **USB hardware fails:** Review Intune hardware allowlist.
- **Fallback:** Use `TunnelOps` temporarily until issues resolved.

------





