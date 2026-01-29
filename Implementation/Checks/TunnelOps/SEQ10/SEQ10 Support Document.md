# SUPPORT HANDOVER DOCUMENT

## SEQ10 — TunnelOps (WTE) Shared Account Remediation

------

## Document Information

**Sequence:** SEQ10
**Department:** TunnelOps
**Area:** Wind Tunnel 2 (WT2)
**Prepared by:** Paul Davidson
**Change Type:** Shared Account Remediation Project
**Status:** Implemented

------

## 1. Purpose

This change replaces the legacy **TunnelOps generic Windows login** on selected General WT systems with **scoped shared accounts**, in line with the Shared Account Remediation Project.

The objectives are:

- Remove  generic logins
- Machine-scoped access
- Preserve uninterrupted tunnel operations
- Maintain clear ownership and auditability

No operational workflows were changed.

The legacy TunnelOps account was retained temporarily for rollback during UAT and Project completion.

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
- Historical references to W9419 may still exist.

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

**Account:** `shr-tunops-wte` (Wind Tunnel Engineer)

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
  → Local Administrators (If Required)
- `shr-tunops-wte`
  → Standard user only

Existing IT / DPT admin access remains unchanged.

Important:

> Many TunnelOps applications are **not controlled by Windows admin rights**
> Access is governed by Aero Software, OPC, or SQL permissions.

------

## 6. RDP Access Model

RDP is **not enabled by default**. (**WT2 Uses TightVNC**)

When required:

Machine-specific groups are used:

- RDP_WF1CAD-C7W04S3
- RDP_WT-Healthmon
- RDP_W9316

Groups in **OU: Shared Accounts RDP**
and are added to local *Remote Desktop Users* only when requested.



### 6.1 TightVNC Access (WT2 Standard)

- WT2 environments primarily use **TightVNC** for remote viewing.
- Used for:
    - Healthmon monitoring Tunnel Screens
    - Control room **W9316** Screens

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
>
>

**Cause**

- WTTP permissions are controlled by **Aero Software team**

**Resolution**

Aero Software must explicitly grant:

- Application access
- WT Run button permissions

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

## 7.5 Tunnel CCTV (Axis Camera System)

### Overview

Tunnel CCTV is provided via **Axis Camera Station Pro** and is used by TunnelOps for **live visual monitoring of the wind tunnel and associated areas** during operation.

------

### Application

- **Application:** Axis Camera Station Pro
- **Camera Server:** WT-CAMS01
- **Access Method:** Application login

------

### Access Model

The TunnelOps shared account must be configured with **Level 3 access**:

- Live camera viewing
- PTZ (pan / tilt / zoom) control
- **No access** to view or export recordings

This access level is intentional and enforced for security and compliance.

------

### Important Support Note

Camera visibility and PTZ functionality are **not controlled by local admin rights** on the workstation.

If cameras are missing, greyed out, or PTZ is unavailable, this indicates a **camera system permission issue**.

------

### Known Issues Observed

- Cameras missing from the device list
- Thermal camera not visible
- User account only has view-only rights
- PTZ controls unavailable

These issues occur when the account is not assigned the correct access level within the Axis system.

------

### Resolution Path

Axis permissions are managed by the TIG.

If CCTV issues are reported:

1. Confirm Axis Camera Station Pro launches successfully
2. Confirm connection to server **WT-CAMS01**
3. Verify the shared account is assigned **Level 3 access**
4. Raise a **Jira ticket**  Camera Systems if access changes are required



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

### Support Notes

The Excel add-ins used on this workstation are business-critical for tunnel operation and rely on a combination of VBA macros and VSTO components loaded from the shared Aero Software location.

Issues have been observed where add-ins fail to load or macros are blocked. These are **not Excel faults** and are typically caused by one or more of the following:

- Microsoft Defender macro protection policies
- Local or domain-based permission restrictions
- Expired or untrusted VSTO installer signing certificates

Common symptoms include:

- Add-ins not appearing in Excel
- Macros failing to execute
- Security or trust prompts preventing installation

These issues cannot be resolved through local administrator rights alone.

If macro or add-in failures occur:

- Do **not** repeatedly reinstall the add-ins
- Do **not** bypass security prompts

The issue must be escalated to the **Aero Software team** & **TIG** to review:

- Certificate validity and trust chain
- Defender policy exclusions (where approved)
- Correct signing of the installer packages

This ensures the add-ins remain secure while functioning correctly within the shared account environment.

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
- Legacy TunnelOps mailbox

Resolution:

- Shared account has a Teams identity
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

- Member of NO ScreenSaver
- Member of No Power Save
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

## **Rollback — Workstation Refresh Contingency**



If issues are encountered on the refreshed workstation **WF1CAD-C7W04S3** that cannot be resolved within the agreed support window, the previous workstation **W9419** remains available as a fallback.

- Suspend use of **WF1CAD-C7W04S3**.
- Re-enable logon to **W9419** using the legacy TunnelOps configuration.
- Confirm network access, WTTP launch, and basic application functionality on W9419.
- Resume tunnel operations on W9419 while faults are investigated offline.



------

## 19. Ownership & Support

**System Owner:**
TunnelOps / WT Systems
(Mitch Hackwood, Keith Forsythe)

**Implementation:**
Paul Davidson — Shared Account Remediation

**Operational Support:**
TIG / IT Support Manger (Mike Smith)