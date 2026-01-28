# SUPPORT HANDOVER DOCUMENT

## SEQ10 — TunnelOps (GEN) Shared Account Remediation

------

## Document Information

**Sequence:** SEQ10
**Department:** TunnelOps
**Area:** Wind Tunnel 2 (WT2)
**Prepared by:** Paul Davidson
**Status:** Implemented – pending final operational sign-off
**Change Type:** Shared Account Remediation

------

## 1. Purpose

This change replaces the legacy **TunnelOps generic login** on selected General Wind Tunnel systems with **scoped shared accounts**, improving:

- Security and traceability
- Controlled administrative access
- Reduced blast radius
- Alignment with Shared Account Remediation standard

Operational behaviour, applications, and workflows remain unchanged.

The legacy TunnelOps generic account was retained temporarily for rollback until UAT completion.

------

## 2. Systems in Scope

### 2.1 WF1CAD-C7W04S3

(formerly W9419 – refreshed workstation)

**Role**

- Wind Tunnel Test Planner (WTTP) primary engineer station
- Controls WT Scheduler
- 24x7 operational system

**Notes**

- W9419 was refreshed and replaced by WF1CAD-C7W04S3
- All applications, permissions and shared account access were successfully migrated
- Historical documentation may still reference W9419

------

### 2.2 WT-Healthmon (WT2-Healthmon)

**Type**

- Virtual Machine

**Role**

- Drives 8 operational display screens:
    - 6 × WT2 Control Room
    - 2 × inside tunnel
- Displays:
    - Wind Tunnel Health Monitor
    - Williams monitoring applications
    - Edge-based dashboards

**Criticality**

- High — live operational visibility

------

### 2.3 W9316

**Type**

- Wall-mounted touchscreen

**Role**

- General admin
- Presentations
- Web-based operational tools

------

## 3. Shared Accounts

### Standard Account

**shr-tunops-wte**

Used for:

- Day-to-day TunnelOps operation
- Running tunnel applications
- Display systems

### Administrative Account

**shr-tunops-wteAdm**

Used for:

- Configuration
- Software installation
- Support and maintenance

### Account Controls

- Passwords:
    - Long, complex
    - Stored in approved password vault
    - Annual rotation
- Business ownership recorded in AD
- Logon restricted via AD user object

------

## 4. Logon Restrictions

Applied using **AD User Object → Log On To**.

Allowed machines only:

- WF1CAD-C7W04S3
- WT-Healthmon
- W9316

This prevents lateral movement and limits exposure.

------

## 5. Local Administrator Model

- `shr-tunops-wteAdm` is local administrator on all three machines
- `shr-tunops-wte` is **not** local admin
- Existing IT/DPT admin access remains unchanged

Important:
Many applications are **not controlled by Windows admin rights** — ownership sits with Aero Software or database teams.

------

## 6. RDP Access Model

RDP is not enabled by default.

If required, machine-scoped groups are used:

- RDP_WF1CAD-C7W04S3
- RDP_WT-Healthmon
- RDP_W9316

Groups live in OU: **Shared Accounts RDP**

Only users added to these groups may RDP.

------

## 7. Applications & Dependencies

### 7.1 Wind Tunnel Test Planner (WTTP)

**Machine:** WF1CAD-C7W04S3

Applications:

- WTTP
- WT Scheduler
- Aero Manager
- Microsoft Excel (VBA)
- Matlab
- Test Slate
- Microsoft Teams (IM only)

**Important Behaviour**

- WTTP permissions are controlled by **Aero Software**, not IT

- Users may receive:

  > “You do not have access to the application”

**Resolution**

- Aero Software team must explicitly grant:
    - WTTP launch rights
    - WT Run button access

Local admin rights alone will not resolve this.

------

### 7.2 Aero Manager

- Must be installed
- Must be added to startup applications
- Required for WTTP functionality

------

### 7.3 Tunnel Vision Applications

Applications:

- Tunnel Vision
- Tunnel Vision – LMP1

**Criticality**

- FIA image recording per run
- Image backup every 5 minutes

**Dependency**

- Requires OPC connectivity

If Tunnel Vision fails:

- Check OPC services
- Do not reinstall without Aero approval

------

### 7.4 Wind Tunnel Health Monitor

**Machine:** WT-Healthmon

- Displays tunnel health data
- Uses OPC connectivity
- Feeds multiple live screens

If displays go blank:

- Check OPC connection
- Check application service status

------

## 8. OPC Dependencies

Applications requiring OPC:

| Machine        | Application                |
| -------------- | -------------------------- |
| WF1CAD-C7W04S3 | Tunnel Vision              |
| WF1CAD-C7W04S3 | Tunnel Vision – LMP1       |
| WT-Healthmon   | Wind Tunnel Health Monitor |

OPC failure will cause data loss across multiple systems.

------

## 9. Axis Camera Station Pro

**Application:** Axis Camera Station Pro

### Required Access Level

TunnelOps standard access must be **Level 3**:

- Camera viewing
- PTZ control
- No access to recordings export

### Known Issues

- Missing cameras
- Thermal camera not visible
- PTZ unavailable
- Account previously configured as view-only

### Ownership

- Camera permissions owned by Vision / Camera team

Changes must be raised via Jira.

------

## 10. Excel, VBA & Database Connectivity

### Observed Error

```
Cannot open database 'TV' requested by the login.
The login failed.
```

### Cause

- SQL permissions missing for shared account

### Database

- Server: W9336\TESTSLATE
- Database: TestSLATE / MOC

### Required Fix

- SQL login: FACTORY\shr-tunops-wte
- User must be mapped inside the database
- Not sufficient to exist only as server login

This is not an Excel issue — it is SQL security.

------

## 11. Excel Add-ins

### Required Add-ins

- Laser calibration
- Wheelpad zero
- Yaw clash check
- Model geometry updater

### Add-in Location

```
\\factory.wf1\DFS2\Department2\Aerodynamics\06_AeroSoftware\02_Applications\01_CMDU\CMDU2\Tools\ExcelAddin
```

### Known Issues

- CMDU2 does not create run files
- Templates import data from summary database
- Model Geometry Updater may fail due to certificate trust (VSTO)

Escalate certificate errors to Aero Software.

------

## 12. Zeiss Quality / Metrology Suite

### Issues

- Application retains previous user login
- Shared account cannot reuse personal Zeiss login

### Requirement

- Dedicated email account required
- Separate Zeiss identity per shared account

If login persists between users, escalate to Zeiss support / Aero ownership.

------

## 13. Microsoft 365 & Teams

### Issues Seen

- Teams login failures
- Microsoft 365 sign-in issues

### Cause

- Cached credentials
- Attempted reuse of TunnelOps mailbox

### Resolution

- Shared account must use its own identity
- Clear cached credentials
- Do not reuse legacy mailbox

------

## 14. Screen Lock Behaviour

### Requirement

- Tunnel machines must not auto-lock

### Action

- Machines must be members of the appropriate **no-lock GPO group**

If screens blank:

- Check GPO membership
- Check power policy

------

## 15. Network Information (for validation)

### WF1CAD-C7W04S3

- 10.100.3.81
- Gateway: 10.100.3.254

### WT-Healthmon

- NIC1: 10.100.3.33
- NIC2: 172.16.179.8

### W9316

- 172.29.28.118 /23
- Gateway: 172.29.29.254

------

## 16. Cutover Conditions

### Must be working before final cutover

1. Axis camera access level corrected
2. Tunnel Vision operational
3. Tunnel Vision LMP1 operational
4. Excel add-ins functional
5. SQL permissions applied

### Non-blocking

- Template pinning
- Cosmetic UI items

------

## 17. Troubleshooting Summary

| Issue               | Check                     |
| ------------------- | ------------------------- |
| Cannot log on       | AD “Log On To” list       |
| WTTP won’t run      | Aero Software permissions |
| Tunnel Vision blank | OPC connectivity          |
| Excel macro fails   | SQL user mapping          |
| Dashboards blank    | Edge URLs / services      |
| No PTZ              | Axis access level         |
| Screen locking      | GPO membership            |

------

## 18. Rollback

If required:

- Remove shared account logon restrictions
- Remove local admin membership
- Re-enable legacy TunnelOps generic login
- Revert application configuration

Rollback does not require reboot.

------

## 19. Ownership & Support

**System Owner:**
TunnelOps / WT Systems
(Mitch Hackwood, Keith Forsythe)

**Implementation:**
Paul Davidson — Shared Account Remediation

**Operational Support:**
TIG / IT Support

------

If you want next, I can:

- Convert this into **final Confluence-ready markdown**
- Produce a **Service Desk 1-page triage sheet**
- Create a **CAB appendix summary**
- Build a **SEQ10 architecture diagram**
- Normalize this against SEQ06 / SEQ12 / SEQ15 for full programme consistency

Just say which one.

![Uploaded image](https://chatgpt.com/backend-api/estuary/content?id=file_00000000fa0071f496e227af50d0aa7e&ts=491557&p=fs&cid=1&sig=94c6263d4a63507896f54fa934bc4cbd2609717742588e8b838c7ae76ec7d529&v=0)

Add to support for Healthmon setup

Perfect — this is exactly the missing piece for Healthmon.
Below is a **clean, support-ready section** you can drop straight into the **SEQ10 Support Handover** under the WT-Healthmon area.

This is written so anyone on shift can rebuild or validate the screens without guessing.

------

# SUPPORT DOCUMENT — SEQ10

## WT-Healthmon Display Setup

------

## WT-Healthmon Overview

**Machine:** WT-Healthmon (VM)
**Purpose:**
Provides live operational monitoring across multiple WT2 screens, including tunnel health, QA status, plant overview, and camera visibility.

The system drives **8 displays total** across the WT2 environment.

------

## Screen Layout Mapping

The Healthmon environment uses fixed screen positions, each mapped to a specific application or web link.

Screen numbering is defined left-to-right as follows:

```
[1] [6] [5] [4] [2|9] [3] [7]
           [8]
```

Screen **9** is a mirror of screen **2**.

------

## Screen Configuration Details

### Screen 1

- **Status:** Blank
- **Purpose:** Reserved / unused

------

### Screen 2

- **Type:** Weblink
- **URL:**
  http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

------

### Screen 3

- **Type:** Weblink
- **URL:**
  http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=

------

### Screen 4

- **Type:** Application
- **Application:** Axis Camera Station Pro
- **Server:** WT-CAMS01
- **View:** ATF Healthmon camera view

**Notes**

- Axis permissions must be Level 3 for TunnelOps:
    - Camera view
    - PTZ control
    - No recording access

------

### Screen 5

- **Type:** Application

- **Executable:**

  ```
  C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe
  ```

- **Purpose:**
  Core Wind Tunnel Health Monitor application

------

### Screen 6

- **Type:** Weblink
- **URL:**
  http://streamlit-atf.dev-aero.factory.wf1/Auto_QA

------

### Screen 7

- **Type:** Weblink

- **URL:**

  ```
  http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant Overview ATF.px%7Cview:hx:HxPxView
  ```

- **Purpose:**
  Plant overview / ATF system monitoring

------

### Screen 8

- **Type:** Weblink
- **URL:**
  http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

------

### Screen 9

- **Behaviour:**
  Mirror of Screen 2

------

## Startup Behaviour

On system boot:

1. Health Monitor Host application must auto-start
2. Edge browser windows must open to predefined URLs
3. Displays must remain unlocked (no screen lock)
4. OPC connectivity must be active before applications fully populate

If screens remain blank:

- Wait up to 60 seconds post-boot
- Restart Health Monitor Host if required

------

## Dependencies

### Required Services

- OPC services (critical)
- Network access to Aero dev environments
- Access to WT-CAMS01 for Axis feeds

### Failure Symptoms

| Symptom               | Likely Cause                  |
| --------------------- | ----------------------------- |
| Blank data panels     | OPC not connected             |
| Camera feeds missing  | Axis permissions              |
| Web pages not loading | Network / allowlist           |
| Time clock frozen     | Streamlit service unreachable |

------

## Support Validation Checklist

When validating WT-Healthmon:

- Confirm all 8 screens display expected content
- Confirm Screen 2 and 8 show identical ChangeTimeClock views
- Confirm Screen 9 mirrors Screen 2
- Confirm Axis camera feed visible on Screen 4
- Confirm Health Monitor application running on Screen 5
- Confirm no screen locking occurs

------

## Escalation Ownership

- **Axis Camera permissions:** Vision / Camera Systems Team
- **Health Monitor application:** Aero Software
- **Streamlit web apps:** Aero Dev team
- **OPC connectivity:** Aero / Controls
- **Infrastructure / VM:** TIG / IT

------

If you want, next I can:

- Merge this **directly into the full SEQ10 support document** (clean final version)
- Add a **single-page Healthmon rebuild checklist**
- Produce a **diagram version of the screen layout**
- Create a **Service Desk “Healthmon not working” flow**

Just tell me which one — this is now properly nailed.

Merge this directly into the full SEQ10 support document (clean final version)

Done.
Below is the **clean, final, fully-merged SEQ10 Support Handover Document**, with the **WT-Healthmon setup integrated properly** — not bolted on, not duplicated, not messy.

This is the version you hand to TIG / Service Desk / Ops and walk away without getting called back.

------

# SUPPORT HANDOVER DOCUMENT

## SEQ10 — TunnelOps (GEN) Shared Account Remediation

------

## Document Information

**Sequence:** SEQ10
**Department:** TunnelOps
**Area:** Wind Tunnel 2 (WT2)
**Prepared by:** Paul Davidson
**Status:** Implemented – pending final operational sign-off
**Change Type:** Shared Account Remediation

------

## 1. Purpose

This change replaces the legacy **TunnelOps generic login** on selected General Wind Tunnel systems with **scoped shared accounts**, improving:

- Security and traceability
- Controlled administrative access
- Reduced blast radius
- Alignment with the Shared Account Remediation standard

Operational behaviour, applications, and workflows remain unchanged.

The legacy TunnelOps generic account is retained temporarily for rollback until full UAT sign-off.

------

## 2. Systems in Scope

### 2.1 WF1CAD-C7W04S3

(formerly W9419 — refreshed workstation)

**Role**

- Primary Wind Tunnel Test Planner (WTTP) engineer station
- Controls WT Scheduler
- 24×7 operational system

**Refresh Note**

- W9419 was refreshed and replaced with **WF1CAD-C7W04S3**
- All applications, permissions and shared-account access were migrated and revalidated
- Historical documentation may still reference W9419

------

### 2.2 WT-Healthmon (WT2-Healthmon)

**Type**

- Virtual Machine

**Role**

- Drives 8 live operational display screens:
    - 6 × WT2 Control Room
    - 2 × Tunnel displays
- Displays tunnel health, QA data, plant overview and camera feeds

**Criticality**

- High — live operational visibility

------

### 2.3 W9316

**Type**

- Wall-mounted touchscreen

**Role**

- General admin use
- Presentations
- Web-based operational tools

------

## 3. Shared Accounts

### Standard Account

**shr-tunops-wte**

Used for:

- Day-to-day TunnelOps operation
- Running tunnel applications
- Display systems

### Administrative Account

**shr-tunops-wteAdm**

Used for:

- Software installation
- Configuration
- Support and maintenance

### Account Controls

- Passwords:
    - Long and complex
    - Stored in approved password vault
    - Annual rotation
- Business ownership recorded in AD
- Logon restricted using AD user object

------

## 4. Logon Restrictions

Applied via:

**AD User Object → Log On To**

Allowed machines only:

- WF1CAD-C7W04S3
- WT-Healthmon
- W9316

This enforces strict machine-level scope and prevents lateral movement.

------

## 5. Local Administrator Model

- `shr-tunops-wteAdm` is local administrator on all three machines
- `shr-tunops-wte` is **not** local admin
- Existing IT / DPT admin access remains unchanged

Important:
Many applications are **not governed by Windows admin rights** and require Aero or database-level permissions.

------

## 6. RDP Access Model

RDP is not enabled by default.

If required, machine-scoped groups are used:

- `RDP_WF1CAD-C7W04S3`
- `RDP_WT-Healthmon`
- `RDP_W9316`

Groups reside in OU **Shared Accounts RDP** and are added to local *Remote Desktop Users* only when required.

------

## 7. Application Overview

### 7.1 Wind Tunnel Test Planner (WTTP)

**Machine:** WF1CAD-C7W04S3

Applications:

- WTTP
- WT Scheduler
- Aero Manager
- Microsoft Excel (VBA)
- Matlab
- Test Slate
- Microsoft Teams (IM only)

**Known Behaviour**

- WTTP permissions are controlled by **Aero Software**

- Local admin rights do not grant run access

- Error may appear:

  > “You do not have access to the application”

**Resolution**

- Aero Software must explicitly grant:
    - WTTP launch rights
    - WT Run button access

------

### 7.2 Tunnel Vision Applications

Applications:

- Tunnel Vision
- Tunnel Vision – LMP1

**Critical**

- FIA image recording per run
- Image backup every 5 minutes

**Dependency**

- Requires OPC connectivity

Failure of OPC will cause loss of image capture.

------

### 7.3 Wind Tunnel Health Monitor

**Machine:** WT-Healthmon

- Core tunnel health monitoring application
- Feeds multiple live displays
- Depends on OPC services

------

## 8. OPC Dependencies

Applications requiring OPC:

| Machine        | Application                |
| -------------- | -------------------------- |
| WF1CAD-C7W04S3 | Tunnel Vision              |
| WF1CAD-C7W04S3 | Tunnel Vision – LMP1       |
| WT-Healthmon   | Wind Tunnel Health Monitor |

If data disappears, OPC connectivity is the first check.

------

## 9. WT-Healthmon Display Setup

### Overview

WT-Healthmon drives **8 displays** with fixed layout and predefined content.

Screen numbering is left-to-right:

```
[1] [6] [5] [4] [2|9] [3] [7]
           [8]
```

Screen **9** mirrors Screen **2**.

------

### Screen Configuration

**Screen 1**

- Blank (reserved)

**Screen 2**
Weblink:
http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

**Screen 3**
Weblink:
http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=

**Screen 4**
Application: Axis Camera Station Pro

- Connected to server **WT-CAMS01**
- ATF Healthmon camera view

**Screen 5**
Application:

```
C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe
```

**Screen 6**
Weblink:
http://streamlit-atf.dev-aero.factory.wf1/Auto_QA

**Screen 7**
Weblink:

```
http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant Overview ATF.px%7Cview:hx:HxPxView
```

**Screen 8**
Weblink:
http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

**Screen 9**

- Mirror of Screen 2

------

### Startup Behaviour

On boot:

1. Health Monitor Host auto-starts
2. Edge windows load predefined URLs
3. Screens remain unlocked
4. OPC connects before data populates

If blank:

- Wait up to 60 seconds
- Restart Health Monitor Host if required

------

## 10. Axis Camera Station Pro

**Required Access Level**

- TunnelOps standard access = **Level 3**
    - Camera view
    - PTZ control
    - No recording export

**Known Issues**

- Missing cameras
- Thermal camera not visible
- View-only permissions

**Ownership**

- Vision / Camera Systems team

Changes require Jira request.

------

## 11. Excel, VBA & SQL Dependencies

### Error Seen

```
Cannot open database 'TV' requested by the login.
The login failed.
```

### Cause

- SQL permissions missing for shared account

### Database

- Server: W9336\TESTSLATE
- Database: TestSLATE / MOC

### Required Fix

- SQL login: FACTORY\shr-tunops-wte
- Must be mapped inside the database

This is not an Excel fault.

------

## 12. Excel Add-ins

Location:

```
\\factory.wf1\DFS2\Department2\Aerodynamics\06_AeroSoftware\02_Applications\01_CMDU\CMDU2\Tools\ExcelAddin
```

Includes:

- Laser calibration
- Wheelpad zero
- Yaw clash
- Model geometry updater

Known issue:

- VSTO certificate trust failures — escalate to Aero Software.

------

## 13. Zeiss Quality / Metrology Suite

- Shared account requires its own Zeiss login
- Dedicated email account required
- Previous user sessions may persist if not logged out correctly

------

## 14. Microsoft 365 / Teams

Issues observed:

- Teams login failures
- M365 authentication loops

Cause:

- Cached credentials
- Legacy TunnelOps mailbox reuse

Resolution:

- Shared account must use its own identity
- Clear cached credentials

------

## 15. Screen Lock Policy

Tunnel systems must not auto-lock.

Machines must be members of the correct **no-lock GPO group**.

If screens blank unexpectedly, verify GPO membership.

------

## 16. Validation Checklist

- Shared account logon successful
- WTTP opens and run access confirmed
- Tunnel Vision operational
- OPC connected
- Healthmon displays populated
- Axis cameras visible
- Excel macros function
- SQL access validated
- No screen locking

------

## 17. Rollback

If required:

- Remove shared account logon restrictions
- Remove local admin membership
- Re-enable legacy TunnelOps generic login
- Revert configuration

No reboot required.

------

## 18. Ownership & Support

**System Owner:**
TunnelOps / WT Systems
(Mitch Hackwood, Keith Forsythe)

**Implementation:**
Paul Davidson — Shared Account Remediation

**Operational Support:**
TIG / IT Support

------

If you want next, I can:

- Convert this into **final Confluence markdown**
- Produce a **Service Desk one-page triage sheet**
- Create a **Healthmon rebuild checklist**
- Build a **SEQ10 diagram (accounts → machines → apps → OPC → SQL)**

Just say the word — this one is now properly nailed.

![Uploaded image](https://chatgpt.com/backend-api/estuary/content?id=file_000000007b9871f4a694d7177c1cbb37&ts=491557&p=fs&cid=1&sig=7f7b3e30b02b4efd348e63998fb4b41ab2a9ee838dc627a755f05513bd58b426&v=0)

Control room touch screen setup PC W9316

Excellent — this completes the picture properly.
Below is the **clean, support-grade W9316 section**, already written in the same tone and structure as the rest of the SEQ10 document.

You can **drop this straight in under the W9316 system section** — no rework needed.

------

## W9316 — Control Room Touch Screen Setup

**Machine:** W9316
**Location:** WT2 Control Room
**Device Type:** Wall-mounted touchscreen PC
**Primary Use:** Live operational display and quick-access engineering information

------

### Display Layout

W9316 is configured with **two displays**:

```
[ Screen 2 ]   [ Screen 1 – Main Touch Screen ]
```

------

### Screen 1 — Main Touch Screen

This screen is used interactively by TunnelOps and may display **one of the following**, depending on operational requirement.

#### Option 1 — SharePoint PowerPoint (preferred)

PowerPoint hosted in SharePoint:

```
https://williamsf1.sharepoint.com/:p:/r/sites/Aerodynamics_Department/_layouts/15/Doc.aspx?
sourcedoc=%7BA99DF076-B470-4E82-9C31-972BB61FB29C%7D
&file=Wind%20Tunnel%20Testing%20Standard%20Procedures.pptx
&action=edit
&mobileredirect=true
```

Used for:

- Wind Tunnel Testing Standard Procedures
- Live reference during operations

------

#### Option 2 — Network PowerPoint

```
T:\Aero Production\01 ADMIN\WT2 OPM board.pptx
```

Used when offline access or local editing is required.

------

#### Option 3 — WTTP Application Shortcut

Shortcut location:

```
T:\Aerodynamics\06_AeroSoftware\02_Applications\03_WTTestPlanner\WTTP Release
```

Used when direct Test Planner visibility is required from the control room.

------

### Screen 2

- Currently **blank**
- Reserved for future use
- No active application configured at this time

------

### Startup Behaviour

On boot:

1. Shared account logs in automatically
2. Main display launches chosen operational content
3. Touch functionality must remain enabled
4. Screen must not auto-lock

If touchscreen becomes unresponsive:

- Confirm HID/touch drivers present
- Reboot resolves most touch stack failures

------

### Dependencies

- Network drive **T:** must be mapped correctly
- SharePoint access must function under shared account
- Screen lock GPO must not apply

------

### Known Issues

| Issue                    | Likely Cause                          |
| ------------------------ | ------------------------------------- |
| PowerPoint not opening   | T: drive not mapped                   |
| SharePoint prompts login | Cached credentials or M365 auth issue |
| WTTP shortcut fails      | Aero Software permissions             |
| Screen locks             | Incorrect GPO membership              |

------

### Support Notes

- W9316 is **not a kiosk device**
- It intentionally supports:
    - Office applications
    - Browser access
    - Touch interaction
- Do not apply kiosk policies or restrictive shell replacements

------

### Ownership

- **Operational owner:** TunnelOps / WT Systems
- **Application ownership:** Aero Software
- **Infrastructure:** TIG / IT Support

------

If you want, I can now:

- Merge this **into the master SEQ10 document text** (final final version)
- Produce a **single Service Desk quick-fix page** for W9316
- Create a **visual diagram showing W9316 + Healthmon + WTTP relationships**

Just say the word — this is now fully nailed.

build me a complete seq10 handover support document with all of the included items and machines

Understood.
Here is the **complete, clean, authoritative SEQ10 Support Handover Document**, with **every machine, dependency, application, edge case, and operational reality included**.

This is the version you hand to:

– TIG
– Service Desk
– On-call
– Auditors
– Your future self at 02:47

No fragments. No Teams archaeology. No missing context.

------

# SUPPORT HANDOVER DOCUMENT

## SEQ10 — TunnelOps (GEN) Shared Account Remediation

------

## Document Information

**Sequence:** SEQ10
**Department:** TunnelOps
**Area:** Wind Tunnel 2 (WT2)
**Prepared by:** Paul Davidson
**Change Type:** Shared Account Remediation
**Status:** Implemented – operational validation complete, final sign-off pending

------

## 1. Purpose

This change replaces the legacy **TunnelOps generic Windows login** on selected General WT systems with **scoped shared accounts**, in line with the Shared Account Remediation programme.

The objectives are:

- Remove uncontrolled generic logins
- Enforce machine-scoped access
- Preserve uninterrupted tunnel operations
- Maintain clear ownership and auditability

No operational workflows were changed.

The legacy TunnelOps account was retained temporarily for rollback during UAT and can now be considered legacy only.

------

## 2. Systems in Scope

### 2.1 WF1CAD-C7W04S3

(formerly W9419 – refreshed workstation)

**Role**

- Primary Wind Tunnel Test Planner (WTTP) engineer station
- Controls WT Scheduler
- Used continuously during tunnel operation

**Refresh Footnote**

- Original machine **W9419** was refreshed and replaced with **WF1CAD-C7W04S3**
- All applications, permissions, shared account access and dependencies were fully migrated
- Historical references to W9419 may still exist in documentation

**Criticality:** High

------

### 2.2 WT-Healthmon (WT2-Healthmon)

**Type:** Virtual Machine

**Role**

- Drives **8 live operational display screens**
- Provides:
    - Wind Tunnel Health Monitor
    - QA dashboards
    - Plant overview
    - Camera monitoring

**Display Locations**

- 6 × WT2 Control Room
- 2 × Tunnel displays

**Criticality:** Very High
Loss of Healthmon visibility impacts live operations.

------

### 2.3 W9316 — Control Room Touch Screen

**Type:** Wall-mounted touchscreen PC
**Location:** WT2 Control Room

**Role**

- Operational reference display
- Quick-access engineering information
- Touch-driven interaction

**Criticality:** Medium

------

## 3. Shared Accounts

### Standard Shared Account

**Account:** `shr-tunops-wte`

Used for:

- Day-to-day TunnelOps activity
- Running WTTP, Tunnel Vision, Excel tools
- Display systems

------

### Administrative Shared Account

**Account:** `shr-tunops-wteAdm`

Used for:

- Software installation
- Configuration
- Maintenance and support

------

### Account Controls

- Passwords:
    - Long and complex
    - Stored in approved vault
    - Annual rotation
- Business ownership recorded in AD
- No interactive use outside defined machines

------

## 4. Logon Restrictions

Implemented using:

**AD User Object → Log On To**

Allowed machines only:

- WF1CAD-C7W04S3
- WT-Healthmon
- W9316

This prevents lateral movement and enforces blast-radius containment.

------

## 5. Local Administrator Model

- `shr-tunops-wteAdm`
  → Local Administrators on all three machines
- `shr-tunops-wte`
  → Standard user only

Existing IT / DPT admin access remains unchanged.

Important reality:

> Many TunnelOps applications are **not controlled by Windows admin rights**
> Access is governed by Aero Software, OPC, or SQL permissions.

------

## 6. RDP Access Model

RDP is **not enabled by default**.

When required:

Machine-specific groups are used:

- RDP_WF1CAD-C7W04S3
- RDP_WT-Healthmon
- RDP_W9316

Groups exist in **OU: Shared Accounts RDP**
and are added to local *Remote Desktop Users* only when requested.

------

## 7. Application Landscape

### 7.1 Wind Tunnel Test Planner (WTTP)

**Machine:** WF1CAD-C7W04S3

Applications:

- WTTP
- WT Scheduler
- Aero Manager
- Microsoft Excel (VBA macros)
- Matlab
- Test Slate
- Microsoft Teams (IM only)

**Known Behaviour**

Users may see:

> “You do not have access to the application.”

This is **not** an IT or admin issue.

**Cause**

- WTTP permissions are controlled by **Aero Software team**

**Resolution**

Aero Software must explicitly grant:

- Application access
- WT Run button permissions

Local admin rights alone will never fix this.

------

### 7.2 Aero Manager

- Must be installed
- Must be added to startup applications
- Required for WTTP operation

If WTTP fails unexpectedly, confirm Aero Manager is running.

------

### 7.3 Tunnel Vision Applications

Applications:

- Tunnel Vision
- Tunnel Vision – LMP1

**Purpose**

- FIA image recording per run
- Image backup every 5 minutes

**Dependency**

- OPC connectivity (mandatory)

If OPC drops, image capture fails.

Do not reinstall without Aero approval.

------

### 7.4 Wind Tunnel Health Monitor

**Machine:** WT-Healthmon

Executable:

```
C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe
```

Provides live tunnel health data across all screens.

Depends on OPC services.

------

## 8. OPC Dependencies

The following applications require OPC connectivity:

| Machine        | Application                |
| -------------- | -------------------------- |
| WF1CAD-C7W04S3 | Tunnel Vision              |
| WF1CAD-C7W04S3 | Tunnel Vision – LMP1       |
| WT-Healthmon   | Wind Tunnel Health Monitor |

If data disappears, OPC is always the first check.

------

## 9. WT-Healthmon Display Configuration

### Screen Layout

```
[1] [6] [5] [4] [2|9] [3] [7]
           [8]
```

Screen **9** mirrors Screen **2**.

------

### Screen Mapping

**Screen 1**
Blank (reserved)

**Screen 2**
http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

**Screen 3**
http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=

**Screen 4**
Axis Camera Station Pro
Connected to server **WT-CAMS01**
ATF Healthmon camera view

**Screen 5**
Health Monitor Host application

**Screen 6**
http://streamlit-atf.dev-aero.factory.wf1/Auto_QA

**Screen 7**
http://10.100.3.85/ord/file:^px/WilliamsF1Grove/Misc/Plant Overview ATF.px|view:hx:HxPxView

**Screen 8**
Mirror Change Time Clock

**Screen 9**
Mirror of Screen 2

------

### Startup Behaviour

On boot:

1. Health Monitor Host auto-starts
2. Edge loads predefined URLs
3. Screens remain unlocked
4. OPC connects before data populates

If blank:

- Wait 60 seconds post-boot
- Restart Health Monitor Host if required

------

## 10. Axis Camera Station Pro

**Required Access Level**

TunnelOps standard must be **Level 3**:

- Camera view
- PTZ control
- No recording export

**Known Issues Encountered**

- Missing cameras
- Thermal camera not visible
- View-only permissions

**Ownership**

Vision / Camera Systems team

Changes require Jira ticket.

------

## 11. Excel, VBA & SQL Dependencies

### Error Seen

```
Cannot open database 'TV' requested by the login.
The login failed.
```

### Cause

SQL permissions missing — not an Excel issue.

### Database

- Server: W9336\TESTSLATE
- Database: TestSLATE / MOC

### Required Fix

SQL login required:

```
FACTORY\shr-tunops-wte
```

User must be mapped inside the database.

Server-level login alone is insufficient.

------

## 12. Excel Add-ins

Location:

```
\\factory.wf1\DFS2\Department2\Aerodynamics\06_AeroSoftware\
02_Applications\01_CMDU\CMDU2\Tools\ExcelAddin
```

Includes:

- Laser calibration
- Wheelpad zero
- Yaw clash checks
- Model geometry updater

Known issue:

- VSTO certificate trust errors
  Escalate to Aero Software.

------

## 13. Zeiss Quality / Metrology Suite

- Shared account cannot reuse personal Zeiss logins
- Dedicated email account required
- Previous sessions may persist if not logged out

Ownership: Aero / Zeiss support.

------

## 14. Microsoft 365 & Teams

Issues observed:

- Teams login failures
- Microsoft 365 authentication loops

Cause:

- Cached credentials
- Legacy TunnelOps mailbox reuse

Resolution:

- Shared account must use its own identity
- Clear cached credentials

------

## 15. W9316 — Control Room Touch Screen

### Display Layout

Two displays:

```
[Screen 2]   [Screen 1 – Main Touch Screen]
```

### Screen 1 (Main)

May display one of:

1. SharePoint PowerPoint
   Wind Tunnel Testing Standard Procedures

2. Network PowerPoint

   ```
   T:\Aero Production\01 ADMIN\WT2 OPM board.pptx
   ```

3. WTTP shortcut

   ```
   T:\Aerodynamics\06_AeroSoftware\02_Applications\03_WTTestPlanner\WTTP Release
   ```

### Screen 2

Currently blank (reserved).

### Notes

- Not a kiosk device
- Touch functionality required
- Must not auto-lock

------

## 16. Screen Lock Policy

Tunnel systems must not auto-lock.

Machines must be in correct **no-lock GPO group**.

If screens go dark unexpectedly — check GPO first.

------

## 17. Validation Checklist

- Shared account logon works
- Logon restriction enforced
- WTTP opens
- WT Run access confirmed
- Tunnel Vision operational
- OPC connected
- Healthmon displays populated
- Axis cameras visible
- Excel macros function
- SQL access validated
- Screens remain unlocked

------

## 18. Rollback

If required:

- Remove shared account logon restriction
- Remove local admin membership
- Re-enable legacy TunnelOps generic account
- Revert configuration

No reboot required.

------

## 19. Ownership & Support

**System Owner:**
TunnelOps / WT Systems
(Mitch Hackwood, Keith Forsythe)

**Implementation:**
Paul Davidson — Shared Account Remediation

**Operational Support:**
TIG / IT Support