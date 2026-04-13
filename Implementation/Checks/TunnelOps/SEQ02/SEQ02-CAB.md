# SUMMARY — SEQ02 TunnelOps

- Purpose: Replace TunnelOps generic account on Rolling Road and Model Motion systems with controlled shared accounts while maintaining 24/7 operational continuity.
- Machines:
    - M10502 — Rolling Road System primary controller
    - M10501 — Rolling Road System backup (IP swap failover)
    - M10504 — Model Motion System primary controller
    - M10503 — Model Motion System backup (IP swap failover)
    - W9343 — Primary comms relay between control apps and machinery
    - W9309 — Backup comms relay
    - W9321 — Air temperature control system (RDP-only access)
- Accounts:
    - shr-tunops-mts01 — standard access shared account
    - shr-tunops-mts01Adm — admin shared account
    - TunnelOps (legacy) — retained temporarily for rollback
- Software:
    - Bespoke MTS control applications (Rolling Road + Model Motion)
    - Comms/control interfaces to specialist machinery
    - OPC messaging components (critical dependency)
- Key Actions:
    - Create two shared accounts and restrict logon to MTS device list
    - Remove reliance on TunnelOps generic account (soft transition)
    - Apply controlled RDP access via OU-based groups
    - Implement RW access to MTS network and local paths
    - Lock down internet access for shared accounts
    - Standardise local admin via grp-tunops-mts01Adm
- Final naming to be confirmed with department.

------

# WORKING DOCUMENT — SEQ02

## Scope

- In scope:
    - MTS device estate (7 machines listed above)
    - Shared account replacement for TunnelOps usage
    - Disk access, RDP, local admin, login restriction
- Out of scope:
    - OPC codebase changes (requires separate programme)
    - Software redesign or vendor changes
    - Full TunnelOps account decommission

## Implementation Steps (authoritative)

1. Account creation & attributes
    - Create:
        - shr-tunops-mts01 (standard)
        - shr-tunops-mts01Adm (admin)
    - Description:
        - “MTS Rolling Road and Model Motion Systems access”
    - Set password policy:
        - No forced change at first login
        - Annual rotation required
    - Restrict logon via User Object → Log On To:
        - M10501, M10502, M10503, M10504, W9343, W9309, W9321
2. RDP Access
    - Create groups in OU “Shared Accounts RDP”:
        - RDP_M10501
        - RDP_M10502
        - RDP_M10503
        - RDP_M10504
        - RDP_W9343
        - RDP_W9309
        - RDP_W9321
    - Add required users:
        - Wind Tunnel Engineers
        - Methodology Engineers
        - Wind Tunnel Systems team
    - Add groups to local “Remote Desktop Users” on each machine
3. Local Permissions / Vendor Requirements
    - Add to local Administrators:
        - DPT Admin Account
        - grp-tunops-mts01Adm
    - Remove all other business user admin access (retain TunnelOps for rollback)
4. Software / Configuration
    - Verify all MTS apps function under both shared accounts
    - Confirm OPC messaging functionality intact
    - Maintain dual NIC configurations and IP swap failover behaviour
    - Ensure no internet access for shared accounts
5. Disk / Data Access
    - Grant RW access via group:
        - grp-tunops-mts01RW
    - Network path:
        - $$
    - Local paths (where present):
        - C:\MTS
        - C:\MTS_bin
        - C:\MTS_user
        - C:\MTS Geo File
6. Intune / Compliance
    - Not explicitly defined — assume baseline applies
    - Validate machines aligned to corporate standard
7. Validation
    - Logon test:
        - Both shared accounts on all devices
    - Application tests:
        - All control systems operational
    - Failover test:
        - IP swap between primary/backup pairs
    - RDP test:
        - Especially W9321 (RDP-only system)
    - Disk access test:
        - Read/write to network + local paths
    - Internet restriction test:
        - Confirm blocked

## Open Items

- Full OPC dependency mapping not confirmed
- Exact app list per machine not explicitly documented
- Licensing impact not fully assessed
- Confirmation of Intune compliance state
- Final user access list validation before go-live

## Discarded Approaches

- BA approach: Group-based login control (LAC groups)
    - Replaced with: Direct “Log On To” machine restriction (project standard)
- Continue using TunnelOps account
    - Rejected — security risk
- Immediate decommission of TunnelOps
    - Rejected — business continuity risk

## Rollback

- Re-enable TunnelOps account usage
- Remove shared accounts from:
    - Log On To restrictions
    - Local groups
- Remove RDP_* groups from devices
- Restore previous admin memberships
- Revert any config impacting OPC/app behaviour

------

# CAB DOCUMENT — SEQ02

## Change Summary

- Implement shared account remediation for MTS Rolling Road and Model Motion systems using controlled AD accounts and restricted access.

## Business Justification

- Removes unmanaged generic account usage
- Introduces controlled, auditable access
- Maintains operational continuity for critical wind tunnel systems

## Affected Systems

- Machines:
    - M10501, M10502, M10503, M10504, W9343, W9309, W9321
- Accounts:
    - shr-tunops-mts01
    - shr-tunops-mts01Adm
    - TunnelOps (temporary fallback)
- Applications:
    - MTS control systems (RRS + MMS)
    - OPC messaging components

## Risk & Mitigation (practical)

- Risk: Loss of control system functionality
    - Mitigation: Keep TunnelOps account active for rollback
- Risk: OPC communication failure
    - Mitigation: Pre/post testing and staged rollout
- Risk: Failover (IP swap) misconfiguration
    - Mitigation: Validate backup systems before cutover
- Risk: Admin rights misconfiguration
    - Mitigation: Limit to grp-tunops-mts01Adm + DPT admins

## Implementation Plan

- Steps: Reference “Implementation Steps” in Working Document

## Validation Plan

- Steps: Reference “Validation” in Working Document

## Backout Plan

- Steps: Reference “Rollback” in Working Document

## Stakeholders (minimal)

- Requestor/Owner: Mich Hackwood (Wind Tunnel Systems Manager)
- Implementer: Curtis-Davidson (Shared Account Remediation)

------

# SUPPORT DOCUMENT — SEQ02

## Purpose

- Controls and monitors wind tunnel Rolling Road and Model Motion systems, including machinery communication and environmental control.

## Day-to-Day Use

- Used by:
    - Wind Tunnel Engineers
    - Methodology Engineers
    - Wind Tunnel Systems team
- Continuous operation (24/7 critical systems)
- Multiple users may monitor/control simultaneously

## Access

- Shared accounts:
    - shr-tunops-mts01 (standard)
    - shr-tunops-mts01Adm (admin)
- RDP:
    - Controlled via RDP_<MACHINE> group membership
    - W9321 is RDP-only (no physical access)

## Software Notes

- Bespoke MTS applications (no standard install packages)
- OPC messaging critical for system operation
- No internet access required or allowed
- Licensing tied to machinery, not software

## Known Paths

- Network:
    - $$
- Local:
    - C:\MTS
    - C:\MTS_bin
    - C:\MTS_user
    - C:\MTS Geo File

## Troubleshooting

- Can’t log on:
    - Check “Log On To” includes correct machine
- RDP denied:
    - Check RDP_<MACHINE> group membership
- App failure:
    - Check OPC comms + local paths
- System failure:
    - Switch to backup device (IP swap model)
- Critical issue:
    - Revert to TunnelOps account immediately

Accounts: shr-tunops-mts01 — standard access shared account account name needs to be the following = shr-tunops-mts and no admin account, Prepare CAB with implimentation plan

Understood — stripping it back properly.
Single account only, no admin variant, aligned to project standard.

------

# CAB DOCUMENT — SEQ02

## Change Summary

- Implement shared account remediation for MTS Rolling Road and Model Motion systems using a single controlled shared account.

## Business Justification

- Replace unmanaged TunnelOps generic account with a controlled shared account
- Reduce risk while maintaining full operational continuity across critical wind tunnel systems

## Affected Systems

- Machines:
    - M10501, M10502, M10503, M10504, W9343, W9309, W9321
- Accounts:
    - shr-tunops-mts (new shared account)
    - TunnelOps (temporary fallback)
- Applications:
    - MTS Rolling Road System control applications
    - Model Motion System applications
    - OPC messaging and control interfaces

## Risk & Mitigation (practical)

- Risk: Loss of system functionality under new account
    - Mitigation: Retain TunnelOps account for immediate rollback
- Risk: OPC messaging failure
    - Mitigation: Validate all comms paths during testing before cutover
- Risk: Failover systems (IP swap) not functioning
    - Mitigation: Test primary/backup switching before and after change
- Risk: Access issues due to logon restriction
    - Mitigation: Validate “Log On To” configuration before enforcement

------

## Implementation Plan

### 1. Account Creation

- Create AD account:
    - shr-tunops-mts
    - Description: “MTS Rolling Road and Model Motion Systems access”
- Password:
    - Set strong password in line with policy
    - Store in approved password vault
- Do NOT create admin account

### 2. Logon Restriction (MANDATORY PROJECT STANDARD)

- Configure on AD User Object → “Log On To”
- Add explicit machine names:
    - M10501
    - M10502
    - M10503
    - M10504
    - W9343
    - W9309
    - W9321

### 3. RDP Access Configuration

- Create security groups in OU “Shared Accounts RDP”:
    - RDP_M10501
    - RDP_M10502
    - RDP_M10503
    - RDP_M10504
    - RDP_W9343
    - RDP_W9309
    - RDP_W9321
- Add required users:
    - Wind Tunnel Engineers
    - Methodology Engineers
    - Wind Tunnel Systems team
- On each machine:
    - Add corresponding RDP_<MACHINE> group to:
        - Local “Remote Desktop Users”

### 4. Local Permissions

- Add to local Administrators on each device:
    - DPT Admin Account ONLY
- Do NOT grant local admin to:
    - shr-tunops-mts

### 5. Disk Access Configuration

- Grant RW access via AD group (existing or created per standard):
    - grp-tunops-mtsRW
- Network path:
    - $$
- Local paths (where present):
    - C:\MTS
    - C:\MTS_bin
    - C:\MTS_user
    - C:\MTS Geo File

### 6. Application Validation

- Log in using shr-tunops-mts on all devices
- Confirm:
    - Rolling Road System fully operational
    - Model Motion System fully operational
    - Communication systems (W9343/W9309) functioning
    - Temperature control system (W9321) functioning
- Validate OPC messaging flows

### 7. Internet Restriction

- Configure policy:
    - shr-tunops-mts has NO internet access

### 8. Business Transition

- Instruct users:
    - Use shr-tunops-mts instead of TunnelOps
- Maintain TunnelOps account during transition phase

------

## Validation Plan

- Login test:
    - shr-tunops-mts on all listed machines
- Application test:
    - Full operational check of:
        - Rolling Road System
        - Model Motion System
- RDP test:
    - Access via RDP groups
    - Confirm W9321 accessible via RDP only
- Disk access:
    - Read/write test:
        - Network path
        - Local MTS directories
- Failover test:
    - Validate IP swap between:
        - M10502 ↔ M10501
        - M10504 ↔ M10503
        - W9343 ↔ W9309
- Internet test:
    - Confirm no outbound internet access
- Continuity test:
    - Confirm TunnelOps account still works (fallback)

------

## Backout Plan

- Revert users to:
    - TunnelOps generic account
- Remove:
    - shr-tunops-mts from:
        - Log On To restrictions
        - Any applied permissions
- Remove RDP_<MACHINE> groups from:
    - Local “Remote Desktop Users”
- Restore previous access model if required

------

## Stakeholders (minimal)

- Requestor/Owner: Mich Hackwood (Wind Tunnel Systems Manager)
- Implementer: Curtis-Davidson (Shared Account Remediation)

you did not capture wind tunnel engineers and all the engineers please be more complete with extracting and organising relevant data

Thought for a few seconds

Correct. I trimmed too hard and dropped operational detail that matters. The access population and role split are part of the implementation, not decoration. Source:

Below is the corrected CAB with the engineer groups and named users properly captured and organised.

# CAB DOCUMENT — SEQ02

## Change Summary

Implement shared account remediation for the MTS estate within TunnelOps using a single standard shared account, `shr-tunops-mts`, across the Rolling Road System, Model Motion System, associated communications systems, and the rolling-road air temperature control device. The legacy `TunnelOps` generic account will remain temporarily for rollback and business continuity.

## Business Justification

Replace broad generic account usage with a controlled shared account limited to the specific MTS devices required for operation. This reduces risk, narrows access scope, preserves 24x7 wind tunnel continuity, and supports a staged transition without immediate removal of the existing TunnelOps account.

## Scope

### In scope

The following devices are in scope for this change: M10501, M10502, M10503, M10504, W9343, W9309, and W9321. These cover the Rolling Road System, Model Motion System, control/comms relay systems, and the air temperature control system for the rolling road.

### Out of scope

Immediate decommission of the legacy `TunnelOps` account is out of scope. Full software licensing review and any required OPC or wider software-development changes are also out of scope for this implementation window and must be handled through separate follow-on work if needed.

## Affected Systems

### Devices

- **M10502** — Primary device for the Rolling Road System. 24/7 critical. Located in a locked cabinet.
- **M10501** — Backup device for M10502. Remains network-connected for updates. Primary/backup achieved by IP swap with M10502.
- **M10504** — Primary device for the Model Motion System. 24/7 critical. Located in a locked cabinet.
- **M10503** — Backup device for M10504. Remains network-connected for updates. Primary/backup achieved by IP swap with M10504.
- **W9343** — Primary communications/control relay device between applications and specialist machinery for Rolling Road and Model Motion systems. Located in a locked cabinet.
- **W9309** — Backup device for W9343. Remains network-connected for updates. Primary/backup achieved by IP swap with W9343.
- **W9321** — Device used to control temperature of the air supply to the rolling road. Located in a secure space in Wind Tunnel 2. No keyboard, mouse, or screen connected. Access is via RDP only.

### Shared account

- `shr-tunops-mts` — standard access shared account for these MTS systems. This replaces the earlier extracted `shr-tunops-mts01` naming and is to be implemented using the corrected final account name supplied by the department. Final naming to be confirmed with department.

### Legacy account retained for continuity

- `TunnelOps` generic account — retained during transition and rollback period.

### Applications and services

- Bespoke MTS applications for:
    - Rolling Road System
    - Model Motion System
    - Control systems
    - Monitoring systems
    - Communications systems
    - Air supply temperature control for the rolling road

### Dependencies

- OPC messaging and related control/comms behaviour may require separate review or change outside this CAB if issues are found.

## User Population Requiring Access

The following users were identified in the source material as requiring access to the MTS shared-account function. I am listing them here because they are part of implementation reality, UAT, RDP control, and support ownership.

### Wind Tunnel Engineers

- Keith Forsythe
- James Busfield
- Edward Ball
- Kyle Harrison
- Luke Deacon
- Harrison Towell

### Methodology Engineers

- Anna Perry — point of contact
- Calum Maciver

### Wind Tunnel Systems

- Mich Hackwood
- Alex Wibawa
- Christina Sullivan
- Ben Stokes
- Andrew Wilkie

### Other identified users

- Neil Hayes
- Thomas Sagar

## Stakeholders

- **Business owner / key stakeholder:** Mich Hackwood, Wind Tunnel Systems Manager
- **Additional stakeholder relevant to W9321:** Edward Ball
- **Implementer:** Curtis-Davidson, Shared Account Remediation

## Access Model

### Logon restriction

Project standard applies. Configure `shr-tunops-mts` directly on the AD user object using **Log On To** with explicit machine names:

- M10501
- M10502
- M10503
- M10504
- W9343
- W9309
- W9321

No group-based indirection is to be used for workstation logon restriction. That part of the BA design is discarded in favour of project standard.

### RDP access

Project standard applies. For any device requiring RDP, create a machine-specific security group in the **Shared Accounts RDP** OU, add approved users, and add that group to local **Remote Desktop Users** on the relevant machine.

Required groups:

- `RDP_M10501`
- `RDP_M10502`
- `RDP_M10503`
- `RDP_M10504`
- `RDP_W9343`
- `RDP_W9309`
- `RDP_W9321`

Approved users to be added where operationally required:

- Keith Forsythe
- James Busfield
- Edward Ball
- Kyle Harrison
- Luke Deacon
- Harrison Towell
- Anna Perry
- Calum Maciver
- Mich Hackwood
- Alex Wibawa
- Christina Sullivan
- Ben Stokes
- Andrew Wilkie
- Neil Hayes
- Thomas Sagar

W9321 is explicitly RDP-only.

## Permission Requirements

### Standard shared account access

`shr-tunops-mts` must be able to run the same required applications and operational functions previously available to `TunnelOps` on the in-scope devices.

### Network access

Grant RW access as required to:

- `T:\ATF\03_Maintenance\Facilities\WT2\MTS`

Where `T:\` maps to:

- `\\smb.wf1-isil01.factory.wf1\department2`

### Local access

Grant required access where present to:

- `C:\MTS`
- `C:\MTS_bin`
- `C:\MTS_user`
- `C:\MTS Geo File`

### Local admin

Per your correction, there is **no admin shared account** in this implementation. Therefore:

- `shr-tunops-mts` is **not** to be granted local administrator permissions.
- DPT Admin accounts remain able to perform administrative support tasks.
- Existing TunnelOps account is retained temporarily for fallback while validation is completed.

That is the clean version. No pretending a non-existent admin account still exists.

### Internet access

`shr-tunops-mts` must not have internet access on the MTS devices.

## Device Notes Relevant to Implementation

### Rolling Road pair

- **M10502** primary, IP `10.100.3.2`
- **M10501** backup, IP `10.100.3.58`
- M10501 additional NICs:
    - `192.168.1.100`
    - `192.168.0.102`
- Primary/backup achieved by IP swap between M10502 and M10501.

### Model Motion pair

- **M10504** primary, IP `10.100.3.1`
- **M10503** backup, IP `10.100.3.54`
- M10503 additional NIC:
    - `192.168.0.101`
- Primary/backup achieved by IP swap between M10504 and M10503.

### Comms relay pair

- **W9343** primary, IP `10.100.3.7`
- **W9343** second NIC: `10.100.1.10`
- **W9309** backup, IP `10.100.3.52`
- Primary/backup achieved by IP swap between W9343 and W9309.

### Temperature control device

- **W9321** IP `10.100.3.3`
- **W9321** second NIC: `10.100.1.10`
- Remote access via RDC/RDP only
- Secure location inside WT2

## Risk and Mitigation

### Risk: Function works under TunnelOps but not under `shr-tunops-mts`

Mitigation: Retain `TunnelOps` during transition. Do not remove fallback until business validation is complete.

### Risk: Some applications or services have not been fully tested on every device

Mitigation: Full UAT with business users across all in-scope devices before final sign-off.

### Risk: OPC-related behaviour or bespoke messaging requires code/config changes

Mitigation: Validate comms during test window. Escalate any defect into separate tracked workstream rather than bodging around it.

### Risk: User list or operational requirements may have changed since discovery

Mitigation: Reconfirm named access population with Mich Hackwood and Anna Perry before implementation.

### Risk: Business continuity impact due to critical 24x7 operation

Mitigation: Controlled implementation window, staged testing, immediate rollback route, and no early decommission of TunnelOps.

## Implementation Plan

1. Create AD shared account `shr-tunops-mts`.
2. Add account description documenting purpose, business owner, and password-handling notes.
3. Set strong password in line with policy and store securely in approved vault.
4. Configure AD user object **Log On To** for:
    - M10501
    - M10502
    - M10503
    - M10504
    - W9343
    - W9309
    - W9321
5. Create required RW access group for storage access if not already present and grant access to:
    - `\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS`
    - Local MTS paths where present
6. Create machine-specific RDP groups in OU **Shared Accounts RDP**.
7. Add approved named users to relevant `RDP_<MACHINE>` groups.
8. Add each `RDP_<MACHINE>` group to local **Remote Desktop Users** on the corresponding device.
9. Confirm `shr-tunops-mts` has no internet access.
10. Log on to each in-scope machine with `shr-tunops-mts` and verify:
    - application launch
    - application function
    - storage access
    - RDP where required
    - system communications
11. Run business-led UAT with representatives from:
    - Wind Tunnel Engineers
    - Methodology Engineers
    - Wind Tunnel Systems
12. Leave `TunnelOps` account in place during hypercare/validation phase.
13. Record issues requiring separate OPC/software remediation if found.

## Validation Plan

Validate the following on all in-scope devices:

- `shr-tunops-mts` can log on locally where physical login applies
- `shr-tunops-mts` can log on via RDP where required
- required MTS apps launch and operate normally
- network path and local MTS paths are readable/writable as required
- no internet access is available to `shr-tunops-mts`
- primary/backup operational model remains unaffected
- `TunnelOps` still works as fallback until sign-off is complete

UAT participants should include at minimum:

- Mich Hackwood
- Anna Perry
- one or more Wind Tunnel Engineers
- one or more Wind Tunnel Systems users
- Edward Ball for W9321-related validation if required

## Backout Plan

If any functional issue impacts operations:

1. Instruct users to revert immediately to `TunnelOps`.
2. Stop further rollout/testing.
3. Remove or disable newly applied access tied to `shr-tunops-mts` if necessary.
4. Preserve evidence of failure for diagnosis.
5. Escalate application, OPC, permissions, or configuration defects to the responsible support or engineering team.
6. Resume remediation only after issue is understood and retested.

## Discarded Approaches

- BA proposal to rely on login access control groups for device logon restriction
    - Replaced with direct AD user-object **Log On To** restriction per project standard.
- Immediate prevention of `TunnelOps` logon
    - Rejected because the source document itself flags business continuity and embedded admin dependencies.
- Immediate decommission of `TunnelOps`
    - Rejected because that would be reckless, not remediation.

If you want, I’ll now turn this into a tighter CAB-ready version with the usual sections you use internally: one-line summary, justification, implementation window wording, and a short backout statement.

give me a more complete implementation document for cab with test plan

Good — this is where it actually matters. Clean, complete, CAB-ready, no gaps.

------

# IMPLEMENTATION DOCUMENT — SEQ02 TunnelOps (MTS Systems)

## Scope

### In Scope

- Replacement of TunnelOps generic account with:
    - `shr-tunops-mts`
- Devices:
    - M10501, M10502, M10503, M10504, W9343, W9309, W9321
- Systems:
    - Rolling Road System (RRS)
    - Model Motion System (MMS)
    - Comms relay systems
    - Air temperature control system
- Access control:
    - Logon restriction (AD User Object)
    - RDP access (OU-based groups)
    - Disk access (network + local)

### Out of Scope

- Decommission of TunnelOps account
- OPC code/config changes (tracked separately if issues arise)
- Software/vendor changes

------

## Implementation Steps (authoritative)

### 1. Account Creation

- Create AD user:
    - `shr-tunops-mts`
- Description:
    - “MTS Rolling Road & Model Motion Systems access”
- Password:
    - Set strong password per policy
    - Store in secure vault (e.g. 1Password)
    - Annual rotation required
- Account type:
    - Standard user (NO admin rights)

------

### 2. Logon Restriction (CRITICAL — PROJECT STANDARD)

Configure on AD User Object → **Log On To**:

- M10501
- M10502
- M10503
- M10504
- W9343
- W9309
- W9321

No group-based login control. Direct machine binding only.

------

### 3. RDP Configuration

Create security groups in OU: **Shared Accounts RDP**

- RDP_M10501
- RDP_M10502
- RDP_M10503
- RDP_M10504
- RDP_W9343
- RDP_W9309
- RDP_W9321

Add users:

#### Wind Tunnel Engineers

- Keith Forsythe
- James Busfield
- Edward Ball
- Kyle Harrison
- Luke Deacon
- Harrison Towell

#### Methodology Engineers

- Anna Perry
- Calum Maciver

#### Wind Tunnel Systems

- Mich Hackwood
- Alex Wibawa
- Christina Sullivan
- Ben Stokes
- Andrew Wilkie

#### Other

- Neil Hayes
- Thomas Sagar

Apply on each machine:

- Add corresponding `RDP_<MACHINE>` group to:
    - Local **Remote Desktop Users**

Special case:

- **W9321 = RDP ONLY DEVICE**

------

### 4. Local Permissions

On all devices:

- Ensure local Administrators contains:
    - DPT Admin Account ONLY
- Do NOT add:
    - `shr-tunops-mts`
- Leave TunnelOps account unchanged for rollback

------

### 5. Disk Access Configuration

#### Network Access

Grant RW access to:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS
```

(Drive T:\ mapping)

#### Local Paths (where present)

```
C:\MTS
C:\MTS_bin
C:\MTS_user
C:\MTS Geo File
```

------

### 6. Internet Restriction

- Apply policy:
    - `shr-tunops-mts` → NO internet access
- Confirm DPT admin accounts still have access where required

------

### 7. Application & System Validation Setup

- Ensure all MTS apps are accessible under:
    - `shr-tunops-mts`
- Validate:
    - Rolling Road System
    - Model Motion System
    - Comms relay systems
    - Temperature control system (W9321)
- Confirm:
    - OPC messaging remains operational

------

### 8. Business Transition

- Instruct users:
    - Use `shr-tunops-mts`
    - Stop using TunnelOps for normal operations
- Keep TunnelOps available during validation period

------

# TEST PLAN — SEQ02

## Test Approach

- Execute per device
- Validate BOTH:
    - Functionality
    - Access control
- Do NOT proceed to next stage if failure occurs

------

## Phase 1 — Login Validation

### Test 1.1 — Local Login

On each device:

- Login using:
    - `shr-tunops-mts`

Expected:

- Login successful
- Profile loads correctly

------

### Test 1.2 — Logon Restriction

Attempt login to:

- Non-MTS devices

Expected:

- Access denied

------

## Phase 2 — Application Validation

### Test 2.1 — Core Systems

On each device:

Validate:

- Rolling Road System operates normally
- Model Motion System operates normally
- Control/monitoring apps function correctly

Expected:

- No functional difference vs TunnelOps

------

### Test 2.2 — Comms Systems

Devices:

- W9343 (primary)
- W9309 (backup)

Validate:

- Communication between apps and machinery

Expected:

- No loss of signalling or control

------

### Test 2.3 — Temperature Control

Device:

- W9321

Validate:

- Air temperature control apps operate correctly
- RDP session stable

------

## Phase 3 — Disk Access

### Test 3.1 — Network Access

Path:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS
```

Validate:

- Read
- Write
- Modify

------

### Test 3.2 — Local Access

On each device:

Validate access to:

```
C:\MTS
C:\MTS_bin
C:\MTS_user
C:\MTS Geo File
```

------

## Phase 4 — RDP Validation

### Test 4.1 — RDP Access

From user workstation:

- Connect to each device using RDP

Expected:

- Access allowed only if in correct `RDP_<MACHINE>` group

------

### Test 4.2 — RDP Denial

Attempt RDP from:

- User NOT in group

Expected:

- Access denied

------

## Phase 5 — Internet Restriction

### Test 5.1 — Internet Block

While logged in as `shr-tunops-mts`:

- Attempt web access

Expected:

- Blocked

------

## Phase 6 — Failover Validation

### Test 6.1 — Rolling Road Failover

- Swap IP between:
    - M10502 ↔ M10501

Expected:

- Backup becomes active
- No loss of function

------

### Test 6.2 — Model Motion Failover

- Swap IP between:
    - M10504 ↔ M10503

Expected:

- Backup becomes active

------

### Test 6.3 — Comms Failover

- Swap IP between:
    - W9343 ↔ W9309

Expected:

- Communications remain intact

------

## Phase 7 — Admin Boundary

### Test 7.1 — Standard Account Restriction

Using `shr-tunops-mts`:

- Attempt admin task

Expected:

- Denied

------

## Phase 8 — Business Continuity

### Test 8.1 — Fallback

Login using:

- TunnelOps

Expected:

- Full functionality retained

------

## Exit Criteria (MANDATORY)

All must pass:

- Login works on all MTS devices
- Login blocked on non-MTS devices
- All systems fully operational
- RDP working and controlled
- Disk access confirmed
- Internet blocked
- Failover validated
- No loss of function vs TunnelOps

------

## Rollback Plan (Immediate)

If ANY failure:

1. Stop implementation
2. Instruct users:
    - Use TunnelOps immediately
3. Remove:
    - `shr-tunops-mts` from active use
4. Preserve state for investigation
5. Escalate:
    - App / OPC / permissions issue

------

## Implementation Reality Check (Straight Truth)

- These systems are **critical path wind tunnel control**
- You are not “deploying accounts” — you are touching live control systems
- If something breaks:
    - It’s not inconvenience
    - It’s operational impact

That’s why:

- TunnelOps stays
- Failover is tested
- No admin rights are casually given
- No assumptions are made

------

If you want next step, I can:

- Convert this into your exact CAB submission format (tight 1-page version)
- Or build the **Support + Hypercare document** ready for Confluence handover

Just say.

remove internet block, that should not be present. there also is OPC test and configuration check documentation,

Good catch — both are wrong for this sequence.

- **Internet block**: remove entirely (not required here)
- **OPC**: must be explicitly tested and validated, not treated as “nice to have”

Here is the corrected, CAB-ready implementation + test plan.

------

# IMPLEMENTATION DOCUMENT — SEQ02 TunnelOps (MTS Systems)

## Scope

### In Scope

- Replace TunnelOps generic account with:
    - `shr-tunops-mts`
- Devices:
    - M10501, M10502, M10503, M10504, W9343, W9309, W9321
- Systems:
    - Rolling Road System (RRS)
    - Model Motion System (MMS)
    - Comms relay systems
    - Air temperature control (W9321)
- Access:
    - Logon restriction (AD User Object)
    - RDP via OU groups
    - Disk access
    - OPC validation

### Out of Scope

- Decommission of TunnelOps
- OPC code/config changes (only validation in scope)
- Vendor/software redesign

------

## Implementation Steps (authoritative)

### 1. Account Creation

- Create AD user:
    - `shr-tunops-mts`
- Description:
    - “MTS Rolling Road & Model Motion Systems access”
- Password:
    - Strong password (policy compliant)
    - Stored in secure vault
    - Annual rotation
- Permissions:
    - Standard user only (no admin rights)

------

### 2. Logon Restriction (MANDATORY)

Configure AD User Object → **Log On To**

- M10501
- M10502
- M10503
- M10504
- W9343
- W9309
- W9321

No AD group-based login control.

------

### 3. RDP Configuration

Create in OU **Shared Accounts RDP**

- RDP_M10501
- RDP_M10502
- RDP_M10503
- RDP_M10504
- RDP_W9343
- RDP_W9309
- RDP_W9321

Add users:

#### Wind Tunnel Engineers

- Keith Forsythe
- James Busfield
- Edward Ball
- Kyle Harrison
- Luke Deacon
- Harrison Towell

#### Methodology Engineers

- Anna Perry
- Calum Maciver

#### Wind Tunnel Systems

- Mich Hackwood
- Alex Wibawa
- Christina Sullivan
- Ben Stokes
- Andrew Wilkie

#### Other

- Neil Hayes
- Thomas Sagar

Apply:

- Add each `RDP_<MACHINE>` group to local **Remote Desktop Users**

Special case:

- **W9321 = RDP-only device**

------

### 4. Local Permissions

On all devices:

- Local Administrators:
    - DPT Admin Account ONLY
- Do NOT add:
    - `shr-tunops-mts`
- Leave:
    - TunnelOps account unchanged (rollback)

------

### 5. Disk Access

#### Network

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS
```

#### Local (where present)

```
C:\MTS
C:\MTS_bin
C:\MTS_user
C:\MTS Geo File
```

------

### 6. Application & OPC Preparation

- Ensure all MTS applications are available under:
    - `shr-tunops-mts`
- Identify:
    - OPC clients
    - OPC servers
    - Data sources per device
- Confirm:
    - No service is hard-bound to TunnelOps account
    - No credential dependency exists

------

### 7. Business Transition

- Users move to:
    - `shr-tunops-mts`
- TunnelOps remains:
    - Active for fallback

------

# TEST PLAN — SEQ02 (INCLUDING OPC VALIDATION)

## Test Control Rules

- Execute per device
- Stop on failure
- Validate BOTH:
    - functionality
    - system behaviour

------

## Phase 1 — Login & Restriction

### Test 1.1 — Local Login

- Login as `shr-tunops-mts`

Expected:

- Successful login on all MTS devices

------

### Test 1.2 — Restriction

- Attempt login on non-MTS device

Expected:

- Denied

------

## Phase 2 — Core Application Validation

### Test 2.1 — RRS / MMS

Validate on:

- M10502 / M10501
- M10504 / M10503

Expected:

- Systems fully operational
- No degradation vs TunnelOps

------

### Test 2.2 — Comms Systems

Validate on:

- W9343 / W9309

Expected:

- Control signals pass correctly
- Monitoring systems update in real time

------

### Test 2.3 — Temperature Control

Validate on:

- W9321 (via RDP)

Expected:

- Stable session
- Control functions operational

------

## Phase 3 — OPC VALIDATION (CRITICAL)

### Test 3.1 — OPC Client Connectivity

- Launch OPC test client (e.g. OPC DA test client)
- Connect to all known OPC servers

Expected:

- Successful connection
- No access denied

------

### Test 3.2 — OPC Data Read

- Browse tags
- Read live values

Expected:

- Data returns correctly
- No “inactive” or null responses

------

### Test 3.3 — OPC Data Write (if applicable)

- Write test value to non-critical tag

Expected:

- Write accepted
- System responds correctly

------

### Test 3.4 — Cross-System Messaging

- Validate communication:
    - Apps → OPC → Machinery
    - Machinery → OPC → Apps

Expected:

- No message loss
- No delay or failure

------

### Test 3.5 — TestSlate / Integration Check (if used)

- Run TestSlate or equivalent system

Expected:

- No OPC inactive errors
- Data streams correctly

------

## Phase 4 — Disk Access

### Test 4.1 — Network

Validate RW access:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS
```

------

### Test 4.2 — Local

Validate RW access:

```
C:\MTS
C:\MTS_bin
C:\MTS_user
C:\MTS Geo File
```

------

## Phase 5 — RDP Validation

### Test 5.1 — Allowed Access

- RDP using authorised user

Expected:

- Success

------

### Test 5.2 — Denied Access

- RDP using unauthorised user

Expected:

- Denied

------

## Phase 6 — Failover

### Test 6.1 — Rolling Road

- Swap IP:
    - M10502 ↔ M10501

Expected:

- Backup takes over seamlessly

------

### Test 6.2 — Model Motion

- Swap IP:
    - M10504 ↔ M10503

Expected:

- Backup takes over

------

### Test 6.3 — Comms

- Swap IP:
    - W9343 ↔ W9309

Expected:

- Messaging uninterrupted

------

## Phase 7 — Admin Boundary

### Test 7.1 — Privilege Check

Using `shr-tunops-mts`:

- Attempt admin task

Expected:

- Denied

------

## Phase 8 — Business Continuity

### Test 8.1 — Fallback

Login:

- TunnelOps

Expected:

- Full system operation

------

## Exit Criteria

ALL must pass:

- Login works on all MTS devices
- Login blocked elsewhere
- All systems operational
- OPC fully functional (no inactive states)
- RDP working and controlled
- Disk access confirmed
- Failover validated
- No regression vs TunnelOps

------

## Rollback Plan

If failure occurs:

1. Stop immediately
2. Switch users back to:
    - TunnelOps
3. Do NOT continue rollout
4. Capture failure:
    - OPC / app / permission issue
5. Escalate to:
    - Appropriate technical owner
6. Resume only after fix + re-test

------

## Critical Reality (No BS)

- OPC is the real risk here — not AD
- If OPC breaks:
    - tunnel stops behaving correctly
- That’s why:
    - You test OPC properly
    - You don’t rush decommission
    - You keep TunnelOps alive

------

If you want next level:
I can map **exact OPC components (DCOM, CLSIDs, identity, launch permissions)** per device so you don’t get hit with the classic “OPC inactive” nonsense again.