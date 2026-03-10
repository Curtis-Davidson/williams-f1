# SUMMARY — SEQ08 TunnelOps

- Purpose: Replace TunnelOps generic login on Fan Control System devices with controlled shared accounts for FCS systems.
- Machines:
    - W9320 — Primary Fan Control System device (WT2 fan control / OPC messaging / PLC interface)
    - W9327 — Backup Fan Control System device (IP swap with W9320 when required)
- Accounts:
    - shr-tunops-fcs01 — standard shared account
    - shr-tunops-fcs01Adm — admin shared account
    - Existing TunnelOps generic retained temporarily for rollback
- Software:
    - Fan Control System bespoke apps (OPC / PLC interface apps)
    - No licensing dependency
    - No internet required
- Key Actions:
    - Create two shared accounts
    - Restrict logon to W9320 / W9327
    - Provide RW access to T:\ATF\03_Maintenance\Facilities\WT2\Jacobs
    - Provide RW access to C:\AWCS
    - Configure admin rights via admin shared account only
    - Configure RDP via project-standard RDP group method
    - Disable internet access for shared accounts
    - Keep TunnelOps generic for rollback until validated
- Final naming to be confirmed with department.

------

# WORKING DOCUMENT — SEQ08

## Scope

- Applies only to Fan Control System devices.
- In scope:
    - W9320
    - W9327
- Out of scope:
    - Other TunnelOps machines
    - OPC software changes (handled by system teams)
    - PLC / machinery configuration

## Implementation Steps (authoritative)

1. Account creation & attributes
    - Create shr-tunops-fcs01
      Description: TunnelOps Fan Control System shared account.
    - Create shr-tunops-fcs01Adm
      Description: TunnelOps Fan Control System admin shared account.
    - Password managed in vault.
    - Restrict logon via User Object → Log On To → add:
        - W9320
        - W9327
2. RDP Access
    - Create security group:
        - RDP_W9320
        - RDP_W9327
          in OU: Shared Accounts RDP
    - Add users:
        - Wind Tunnel Engineers
        - Methodology Engineers
        - Wind Tunnel Systems
        - Named users from BA list
    - On each machine:
        - Add group to local Remote Desktop Users
3. Local Permissions / Vendor Requirements
    - Add grp-tunops-fcs01Adm (or equivalent) to local Administrators
    - Keep DPT admin account
    - Do not remove TunnelOps until validation complete
4. Software / Configuration
    - Verify Fan Control System apps run under shared accounts
    - Verify OPC messaging still works
    - Verify PLC communication
    - Verify path access:
        - T:\ATF\03_Maintenance\Facilities\WT2\Jacobs
        - $$
        - C:\AWCS
    - Disable internet for shared accounts
5. Intune / Compliance
    - Ensure machines aligned with baseline
    - No internet access for shared accounts
6. Validation
    - Logon test on W9320 / W9327
    - App test
    - RW share test
    - Admin rights test
    - RDP test
    - OPC / fan control test
    - Confirm TunnelOps still works

## Open Items

- Confirm final shared account names
- Confirm final user list
- Confirm RDP requirement (BA used RDC groups)
- Confirm if both machines require RDP
- Confirm OPC changes handled by system team
- Confirm internet block method

## Discarded Approaches

- BA proposed login control via AD groups
  → Using project standard: Log On To on user object.
- BA proposed RDC control groups
  → Using project standard RDP_<MACHINE> groups.

## Rollback

- Remove Log On To restriction
- Remove RDP groups
- Remove admin group membership
- Restore TunnelOps login
- Revert local permissions

------

# CAB DOCUMENT — SEQ08

## Change Summary

Implement shared account remediation for Fan Control System devices in TunnelOps.

## Business Justification

Replace generic login with controlled shared accounts, restrict machine access, maintain business continuity.

## Affected Systems

- Machines:
    - W9320
    - W9327
- Accounts:
    - shr-tunops-fcs01
    - shr-tunops-fcs01Adm
- Applications:
    - Fan Control System apps
    - OPC messaging
    - PLC interface

## Risk & Mitigation

- Risk: Loss of fan control functionality
  Mitigation: Keep TunnelOps until validated
- Risk: OPC / PLC communication failure
  Mitigation: Validate before removal
- Risk: RDP access failure
  Mitigation: Create RDP groups first
- Risk: Disk permission failure
  Mitigation: Test RW paths before go-live

## Implementation Plan

Reference Implementation Steps in Working Document.

## Validation Plan

Reference Validation in Working Document.

## Backout Plan

Reference Rollback in Working Document.

## Stakeholders

- Owner: Mich Hackwood
- Implementer: Curtis-Davidson

------

# SUPPORT DOCUMENT — SEQ08

## Purpose

Controls Wind Tunnel Fan Control System.

## Day-to-Day Use

Used by wind tunnel engineers and systems team to monitor and control fan systems.

## Access

Shared accounts:

- shr-tunops-fcs01
- shr-tunops-fcs01Adm

Allowed machines:

- W9320
- W9327

RDP:

- via RDP_W9320 / RDP_W9327 groups

## Software Notes

- Fan Control System apps
- OPC messaging
- PLC interface tools
- No internet required

## Known Paths

- T:\ATF\03_Maintenance\Facilities\WT2\Jacobs
- $$
- C:\AWCS

## Troubleshooting

- Cannot logon → check Log On To
- RDP denied → check RDP group
- App fails → check RW paths
- Fan system not responding → check OPC / PLC connection
- Admin failure → use shr-tunops-fcs01Adm

Produce a implimintation document

Below is a clean **Implementation Document** for **SEQ08 – TunnelOps FCS**, written in the style we’ve been using for F1 remediation.
No fluff, no BA language, no cross-refs, just something you can drop into Confluence / CAB / ticket.

Source: TunnelOps-Seq08-fcs 3

------

# IMPLEMENTATION DOCUMENT — SEQ08 — TunnelOps Fan Control Systems

## 1. Purpose

This change replaces the use of the **TunnelOps generic account** on Fan Control System devices with controlled shared accounts, restricted to the required machines only.

This applies only to the Fan Control System devices:

- W9320 — Primary FCS controller
- W9327 — Backup FCS controller

The change must not interrupt wind tunnel operation.

The TunnelOps generic account will remain available until validation is complete.

------

## 2. Devices in Scope

| Machine | Role                       | Notes                             |
| ------- | -------------------------- | --------------------------------- |
| W9320   | Primary Fan Control System | Sends OPC messages to PLC systems |
| W9327   | Backup Fan Control System  | Can replace W9320 by IP swap      |

Both machines run Windows 10 Enterprise.

Both machines must remain operational 24/7.

------

## 3. Accounts to be Created

| Account             | Purpose                         | Type  |
| ------------------- | ------------------------------- | ----- |
| shr-tunops-fcs01    | Standard shared account for FCS | User  |
| shr-tunops-fcs01Adm | Admin shared account for FCS    | Admin |

Description on AD object must include:

- Owner: Wind Tunnel Systems
- Purpose: Fan Control System login
- Password stored in vault
- Password change yearly

Final naming to be confirmed with department.

------

## 4. Logon Restriction (Project Standard)

Apply on user object.

Set **Log On To**:

```
W9320
W9327
```

Apply to:

- shr-tunops-fcs01
- shr-tunops-fcs01Adm

TunnelOps generic account remains unchanged.

------

## 5. RDP Configuration (Project Standard)

Create groups in OU:

```
OU = Shared Accounts RDP
```

Create:

```
RDP_W9320
RDP_W9327
```

Add required users:

- Wind Tunnel Engineers
- Methodology Engineers
- Wind Tunnel Systems
- Named users supplied by department

On each machine:

Add group to local:

```
Remote Desktop Users
```

------

## 6. Local Administrator Configuration

On both machines:

Add to local Administrators:

```
grp-tunops-fcs01Adm   (or equivalent admin group)
DPT Admin account
```

Do NOT remove TunnelOps yet.

No other business users to remain in Administrators.

------

## 7. Disk / Share Access

Grant RW access to:

```
T:\ATF\03_Maintenance\Facilities\WT2\Jacobs
```

Mapped from:

```
\\smb.wf1-isil01.factory.wf1\department2
```

Grant RW access to local path if present:

```
C:\AWCS
```

Apply to both shared accounts.

------

## 8. Application Validation

Fan Control System applications must run under new accounts.

Verify:

- Fan control interface starts
- OPC messaging works
- PLC communication works
- No licensing errors
- No permission errors

These systems are bespoke control interfaces.

No internet access required.

------

## 9. Internet Restriction

Shared accounts must not have internet access.

Apply restriction to:

```
shr-tunops-fcs01
shr-tunops-fcs01Adm
```

Local admin accounts may retain internet.

------

## 10. Validation Tests

Perform on both machines.

### Logon test

- Login using shr-tunops-fcs01
- Login using shr-tunops-fcs01Adm

### Share test

- Access T:\
- Access C:\AWCS

### Admin test

- Standard account cannot admin
- Admin account can admin

### RDP test

- RDP allowed for users in RDP group
- RDP denied for others

### App test

- Fan control app runs
- OPC works
- PLC messages work

### Continuity test

- TunnelOps generic still works

------

## 11. Rollback Plan

If any issue occurs:

- Remove Log On To restriction
- Remove RDP groups
- Remove admin group membership
- Revert disk permissions
- Use TunnelOps generic account

No machine rebuild required.

------

## 12. Risk Notes

Fan Control System is critical to tunnel operation.

Risk areas:

- OPC messaging
- PLC communication
- Admin permissions
- Disk permissions

Mitigation:

- Keep TunnelOps until validated
- Test with engineering present
- Implement during agreed window

------

## 13. Implementation Owner

Shared Account Remediation
Curtis-Davidson

Stakeholder
Wind Tunnel Systems Manager
Mich Hackwood

------

## 14. Status

SEQ08 ready for implementation once approved.

can we do our implimentation plan tighter and rember this system controls the wind tunnel turbines

Yes — and for this one we **should** tighten it.
Anything touching **Fan Control / OPC / PLC / turbines** must read like a **controlled engineering change**, not a normal AD tidy-up.
This system literally drives the wind tunnel fans, so the plan must show:

- staged change
- live rollback
- no lockout risk
- no service interruption
- validation with tunnel running state known

Below is a **tightened Implementation Plan v2** for SEQ08, written as if it will go in CAB / Confluence / audit.

------

# IMPLEMENTATION PLAN — SEQ08 — TunnelOps Fan Control System (FCS)

## 1. Change Purpose

Replace use of the TunnelOps generic account on Fan Control System devices with controlled shared accounts, without affecting operation of the wind tunnel fan control system.

This system controls turbine / fan infrastructure via OPC messaging to PLC systems.

Any interruption may stop tunnel operation.

Implementation must allow immediate rollback.

Machines in scope:

```
W9320 — Primary FCS controller
W9327 — Backup FCS controller
```

------

## 2. Change Safety Principles

This change must follow these rules:

- No change while tunnel running unless approved
- TunnelOps account must remain usable until final validation
- No removal of admin rights until confirmed safe
- No login restriction until shared account tested
- No reboot unless agreed
- No service restart unless approved
- Rollback must be possible in < 2 minutes

------

## 3. Pre-Implementation Checks

Confirm with Wind Tunnel Systems:

- Tunnel not running OR change window approved
- Engineering present or on call
- OPC / PLC system stable
- No active test cycle

Confirm machines online:

```
ping W9320
ping W9327
```

Confirm TunnelOps login works on both.

Confirm apps open.

Confirm share access works.

Confirm admin rights exist.

------

## 4. Create Shared Accounts

Create:

```
shr-tunops-fcs01
shr-tunops-fcs01Adm
```

Set:

- Password strong
- Password stored in vault
- Description = Fan Control System shared account
- Owner = Wind Tunnel Systems

Do NOT restrict logon yet.

------

## 5. Test Login Without Restriction

Login locally on:

```
W9320
W9327
```

Using:

```
shr-tunops-fcs01
shr-tunops-fcs01Adm
```

Verify:

- Desktop loads
- Apps open
- No permission errors

Do not continue until confirmed.

------

## 6. Configure Disk Access

Grant RW:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\Jacobs
```

Grant RW local:

```
C:\AWCS
```

Test read/write.

------

## 7. Configure Admin Rights

Add to local Administrators:

```
grp-tunops-fcs01Adm
DPT Admin
```

Do NOT remove TunnelOps.

Test admin action.

------

## 8. Application Validation (CRITICAL)

On W9320 and W9327:

Login with shared account.

Verify:

- Fan control app starts
- OPC messages sending
- PLC status visible
- No alarms
- No permission errors

Confirm with engineer.

Do not continue until confirmed.

------

## 9. Configure RDP (Project Standard)

Create:

```
RDP_W9320
RDP_W9327
```

OU:

```
Shared Accounts RDP
```

Add users.

Add group to:

```
Remote Desktop Users
```

Test RDP.

------

## 10. Apply Logon Restriction (FINAL STEP)

On shared accounts:

Set Log On To:

```
W9320
W9327
```

Test login again.

Test app again.

Test OPC again.

Test with engineer present.

------

## 11. Internet Restriction

Disable internet for:

```
shr-tunops-fcs01
shr-tunops-fcs01Adm
```

Do not block admin accounts.

Test app again.

------

## 12. TunnelOps Account

Do NOT disable.

Leave available for rollback.

Removal will be separate sequence.

------

## 13. Rollback Plan (Immediate)

If any issue:

Remove logon restriction

Remove admin group

Remove shared account from machine

Use TunnelOps

No reboot required.

------

## 14. Risk Statement

This system controls wind tunnel fan / turbine infrastructure.

Risk areas:

- OPC messaging
- PLC communication
- Admin rights
- Disk permissions
- Login restriction

Mitigation:

- staged change
- engineer present
- TunnelOps retained
- no service restart
- rollback ready

------

## 15. Implementation Owner

Paul Davidson
Shared Account Remediation

Stakeholder
Mich Hackwood
Wind Tunnel Systems







# SEQ08 — Change Summary

## What this change affects

This change affects the **Fan Control System (FCS)** used in the Wind Tunnel environment.

The change replaces use of the legacy **TunnelOps generic account** with controlled shared accounts on the machines that control the fan / turbine systems.

Systems affected:

- W9320 — Primary Fan Control System controller
- W9327 — Backup Fan Control System controller

These machines run specialist control software which communicates with PLC and control hardware using OPC messaging.

These machines are part of the operational control path for the wind tunnel turbine / fan systems.

------

## What SEQ08 controls

SEQ08 covers the systems responsible for:

- Wind tunnel fan / turbine control
- Fan speed / airflow control processes
- OPC messaging to PLC control systems
- Monitoring and interaction with fan control hardware
- Primary / backup control workstation switching

W9320 is the primary controller.

W9327 is a hot backup and can take over by IP swap.

These machines must remain available 24/7.

Failure or misconfiguration could interrupt wind tunnel operation.

------

## What the change is doing

The change introduces two new shared accounts:

```
shr-tunops-fcs01
shr-tunops-fcs01Adm
```

These will replace the TunnelOps generic login on the FCS machines.

The change includes:

- Restricting login to the FCS machines only
- Maintaining admin access for support
- Preserving all existing application functionality
- Ensuring OPC / PLC communication is not affected
- Keeping the TunnelOps account available until validation complete

No software changes are being made to the fan control system.

No changes are being made to PLC / OPC configuration.

No changes are being made to turbine control logic.

Only authentication / access method is changing.

------

## Why this change is sensitive

These machines are directly involved in controlling wind tunnel turbine systems.

Incorrect permissions, login restriction, or admin changes could:

- Stop fan control software
- Break OPC messaging
- Prevent engineers controlling tunnel systems
- Interrupt wind tunnel operation

For this reason the change is being done in stages with rollback available.

------

## Risk level

Medium technical change
High operational sensitivity
Low functional change
High impact if incorrect



Below is the **final clean Implementation Plan for CAB**, updated with:

- new machine list
- single shared account `shr-tunops-fcs`
- wind tunnel / turbine control context
- controlled change window
- staged work over two weeks
- change window midnight–05:30

Written in proper CAB / engineering change style.

------

# IMPLEMENTATION PLAN — SEQ08 — Fan Control System Shared Account Remediation

## 1. Change Purpose

This change replaces the use of the **TunnelOps generic account** on the Fan Control System (FCS) machines with a controlled shared account.

These machines form part of the **Wind Tunnel WT2 Fan / Turbine Control System**, which communicates with PLC hardware using OPC messaging and specialist control software.

Incorrect configuration could affect the ability to monitor or control wind tunnel fan systems.

No changes are being made to control software, PLC configuration, or turbine logic.
This change only affects authentication and access control.

------

## 2. Change Window

Work will be carried out in controlled maintenance windows:

```
00:00 – 05:30
```

Implementation will be staged over approximately:

```
2 weeks
```

Changes will only be performed when the wind tunnel is not running or when confirmed safe by Wind Tunnel Systems.

------

## 3. Machines in Scope

The following Fan Control System machines are included:

```
W9320  — FCS AWCS Control — Live
W9330  — FCS Facility Control System — Spare
M11343 — FCS Facility Control System (New Live)
M11365 — FCS Facility Control System (New Spare)
```

All machines are located in the WT2 FCS PLC room / cabinet environment.

These machines must remain operational at all times.

------

## 4. Account to be Implemented

New shared account:

```
shr-tunops-fcs
```

This account will replace use of the TunnelOps generic login on FCS machines.

The account will:

- be restricted to FCS machines only
- have required disk / application permissions
- have admin rights via group membership
- have no internet access
- remain compatible with existing FCS software

The TunnelOps account will remain available until validation is complete.

------

## 5. Safety Rules

The following rules must be followed during implementation:

- No changes during active tunnel run unless approved
- TunnelOps account must remain usable
- No reboot without approval
- No service restart without approval
- Login restriction applied last
- Fan control software must be tested before restriction
- Rollback must be immediate

------

## 6. Pre-Implementation Checks

Before each session:

Confirm with Wind Tunnel Systems:

- Change window approved
- Tunnel in safe state
- No active test cycle

Confirm machines reachable:

```
W9320
W9330
M11343
M11365
```

Confirm:

- TunnelOps login works
- Fan control software runs
- No alarms present
- Shares accessible
- Admin rights working

------

## 7. Create Shared Account

Create:

```
shr-tunops-fcs
```

Set:

- strong password
- password stored in vault
- description = Fan Control System shared account
- owner = Wind Tunnel Systems

Do not apply logon restriction yet.

------

## 8. Test Login With New Account

On each machine:

```
W9320
W9330
M11343
M11365
```

Login using:

```
shr-tunops-fcs
```

Verify:

- desktop loads
- no profile errors
- FCS software opens

Do not continue until confirmed.

------

## 9. Configure Disk Permissions

Grant required access to:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\Jacobs
```

Grant access to local path if present:

```
C:\AWCS
```

Verify read / write access.

------

## 10. Configure Local Administrator Access

Create / use admin group:

```
grp-tunops-fcs-admin
```

Add group to local Administrators on:

```
W9320
W9330
M11343
M11365
```

Add required engineers to group.

Do not remove TunnelOps yet.

Test admin action.

------

## 11. Application Validation (Critical Step)

On each machine, login using:

```
shr-tunops-fcs
```

Verify:

- Fan / facility control software runs
- OPC communication active
- PLC status visible
- No alarms
- No permission errors

Confirm with Wind Tunnel Systems if required.

Do not continue until confirmed.

------

## 12. Configure RDP Access (Project Standard)

Create groups:

```
RDP_W9320
RDP_W9330
RDP_M11343
RDP_M11365
```

Location:

```
OU = Shared Accounts RDP
```

Add users as required.

Add group to:

```
Remote Desktop Users
```

Test RDP.

------

## 13. Apply Logon Restriction (Final Step)

On account:

```
shr-tunops-fcs
```

Set Log On To:

```
W9320
W9330
M11343
M11365
```

Test:

- login works on listed machines
- login blocked elsewhere
- FCS software still works

------

## 14. Restrict Internet Access

Block internet access for:

```
shr-tunops-fcs
```

Do not block admin accounts.

Retest FCS software.

------

## 15. TunnelOps Account

TunnelOps generic account will remain available.

Removal will be performed in a separate change once confirmed safe.

------

## 16. Validation Checklist

- Login successful
- Admin rights correct
- Disk access correct
- RDP works
- FCS software works
- OPC communication working
- PLC communication working
- TunnelOps still usable

------

## 17. Rollback Plan

If any issue occurs:

- Remove logon restriction
- Remove admin group
- Remove RDP group
- Restore permissions
- Use TunnelOps account

No reboot required.

Rollback must be immediate.

------

## 18. Risk Statement

These machines control the WT2 wind tunnel fan / turbine system.

Risk areas:

- login restriction
- permissions
- OPC messaging
- PLC communication
- admin rights

Mitigation:

- staged implementation
- overnight windows
- tunnel safe state
- TunnelOps retained
- rollback ready

------

## 19. Owner

Implementation
Curtis-Davidson
Shared Account Remediation

System Owner
Wind Tunnel Systems
Mich Hackwood







# 11A. Configuration, Application Paths and Permissions

The following configuration locations and paths are required for correct operation of the Fan Control System (FCS) software.
Permissions must be verified for the shared account before login restriction is applied.

These paths are used by FCS / AWCS / PLC interface software and must remain accessible.

------

## 11A.1 Network Share Access

Grant read / write access for account:

```
shr-tunops-fcs
```

Required network location:

```
\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\Jacobs
```

Mapped drive may appear as:

```
T:\
```

Permissions required:

- Read
- Write
- Modify (if currently used)
- No change to existing ACLs except adding required access

Verify:

- File open
- File create
- File modify
- File delete (if applicable)

------

## 11A.2 Local Application Data Paths

Some FCS / AWCS software stores configuration locally.

Check and grant access if present:

```
C:\AWCS
```

If additional folders exist, verify access to:

```
C:\ProgramData
C:\Program Files
C:\Program Files (x86)
C:\Users\Public
```

Do NOT change permissions globally.
Only confirm existing permissions allow correct operation.

------

## 11A.3 Application Configuration Files

Fan Control / Facility Control / AWCS / OPC software may store configuration in:

```
C:\AWCS
C:\ProgramData\*
C:\Users\*\AppData\Local
C:\Users\*\AppData\Roaming
```

Verify that the shared account can:

- start the application
- read configuration
- write logs / runtime files
- communicate with PLC / OPC services

No configuration files should be modified during this change.





# Reversion / Rollback Plan

A staged migration approach will be used to ensure that wind tunnel fan / turbine control remains available at all times.

The Fan Control System environment contains live and failover controllers, allowing the change to be performed safely without interrupting operation.

Machines involved:

```
W9320  — FCS AWCS Control — Live
W9330  — FCS Facility Control System — Failover

M11343 — FCS Facility Control System (New Live)
M11365 — FCS Facility Control System (New Failover)
```

------

## 17.1 Rollback Strategy

The migration will be performed on the failover systems first.

The live controller will remain unchanged until:

- shared account tested
- permissions verified
- application confirmed working
- PLC / OPC communication confirmed
- system validated in production

Only after successful validation will the primary controller be updated.

This ensures a working control system is always available.

------

## 17.2 Migration Order

Order of change:

1. Update failover system
2. Validate operation
3. Switch control to failover if required
4. Update primary system
5. Validate again
6. Confirm normal operation

Expected order:

```
W9330   (Failover)
M11365  (New Failover)

W9320   (Live)
M11343  (New Live)
```