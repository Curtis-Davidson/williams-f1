# SUMMARY — SEQ10 TunnelOps (GEN)

Purpose: Replace legacy "TunnelOps" generic logins on three General WT Systems with scoped shared accounts, preserving operations and enabling controlled admin where required.

## Machines
- W9419 — WT Test Planner (WTTP) primary control in WT2; controls WT Scheduler; 24x7.
- WT-Healthmon (aka "WT2-Healthmon") — VM driving 8 status screens (6 in WT2 Control Room, 2 in tunnel); shows Edge web apps + Williams "Healthmonitor" + another Williams app.
- W9316 — Wall-mounted touchscreen in WT2 Control Room; general admin/presentation use.

## Accounts
- `shr-tunops-wte` (standard)
- `shr-tunops-wteAdm` (admin)
- Final naming to be confirmed with department (trailing descriptors if they want them).

## Software / Dependencies (by area)
- **W9419:** MS Teams (IM), Excel (VBA to DB on W9336), Test Slate, Matlab, WTTP/WT scheduler control.
- **WT-Healthmon:** Edge web apps; "Healthmonitor" (Williams app); "another Williams" app (desktop icons).
- **W9316:** General use (PowerPoint, web apps).

## Paths & Data
- **Network:** `\\factory.wf1\DFS2`, `\\factory.wf1\Department2`
- **Local:** `C:\WilliamsF1`, `C:\Scripts` (W9419, WT-Healthmon); `C:\WilliamsF1` (W9316); plus WT-Healthmon root folders starting with "Health Monitor".
- **SharePoint:**
    - `/sites/AerodynamicOperations`
    - `/sites/ATF/SitePages/TEST HOME.aspx`
    - `/sites/Aerodynamics_Department`
    - `/sites/AeroOps1`
- **Database:** Aeroprodsql on port 59112 (exact server not stated; confirm).

## Security Model (standard)
- **Logon restriction:** set on the User Object → Log On To with explicit machine names.
- **RDP (if/when required):** OU "Shared Accounts RDP" → create `RDP_<MACHINE>` group, add required users, add that group to local `Remote Desktop Users` on the target machine.

## Internet for Shared Accounts
Blocked by default; allowlist (if needed): `https://dev.azure.com/F1Technical/`, `https://miro.com/` (confirm with SecOps/TIG before enforcing).

## Key Actions
- Create `shr-tunops-wte` and `shr-tunops-gen01Adm`.
- Restrict both via Log On To to `W9419`, `WT-Healthmon`, `W9316`.
- Add `shr-tunops-wteAdm` (or an admin group containing it) to local Administrators on the three devices.
- Map drives/paths, validate apps, confirm SharePoint access, and run UAT on shift.
- Keep `TunnelOps` generic available for rollback until sign-off.

---

# WORKING DOCUMENT — SEQ10

## Scope
Remediate the "WTE" subset of TunnelOps machines (`W9419`, `WT-Healthmon`, `W9316`) by introducing two shared accounts with minimal blast radius, enforcing machine-scoped logon, and preparing optional RDP access using the standard RDP group pattern. No kiosk mode. No complex BA group lattice.

## Implementation Steps (authoritative)

### 1. Account Creation & Attributes
- Create `shr-tunops-wte` (standard). Description: "TunnelOps GEN — standard shared account for W9419, WT-Healthmon, W9316 (WT2)".
- Create `shr-tunops-wteAdm` (admin). Description: "TunnelOps GEN — admin shared account for W9419, WT-Healthmon, W9316 (WT2)".
- Password policy: long, vaulted; annual rotation per policy; store in Keeper/1Password; department informed on change via secure channel.
- Note fields in AD: business owner (WT Systems), purpose, vault reference, rotation note.

### 2. Logon Restriction (standard method)
- On each shared account's AD user object: Log On To → add: `W9419`, `WT-Healthmon`, `W9316`.
- Confirm `TunnelOps` generic remains functional for rollback until UAT sign-off.

### 3. Local Admin (where needed)
- On `W9419`, `WT-Healthmon`, `W9316` add `shr-tunops-gen01Adm` (or domain group that contains it) to local `Administrators`.
- Keep DPT Admin accounts intact. Do not add standard `shr-tunops-gen01` to `Administrators`.

### 4. RDP Access (only if required)
- Create (in OU "Shared Accounts RDP") machine-scoped groups: `RDP_W9419`, `RDP_WT-Healthmon`, `RDP_W9316`.
- Add permitted users (roles/names) to the appropriate `RDP_<MACHINE>` group when RDP is actually requested.
- On each machine, add its `RDP_<MACHINE>` to local `Remote Desktop Users`.

### 5. Drives / Paths / Permissions
- Ensure both accounts can R/W as appropriate to `\\factory.wf1\DFS2`, `\\factory.wf1\Department2`.
- Local paths:
    - **W9419:** `C:\WilliamsF1`, `C:\Scripts`
    - **WT-Healthmon:** `C:\WilliamsF1`, `C:\Scripts`, roots starting "Health Monitor*"
    - **W9316:** `C:\WilliamsF1`
- SharePoint (interactive access): `/AerodynamicOperations`, `/ATF/SitePages/TEST HOME.aspx`, `/Aerodynamics_Department`, `/AeroOps1`.

### 6. Apps / Config
- **W9419:** Teams; Excel (VBA to DB on `W9336` — confirm server & DSN/ODBC); Test Slate; Matlab; WTTP/WT Scheduler control.
- **WT-Healthmon:** "Healthmonitor" and second Williams app; Edge profiles for 6 control-room screens + 2 tunnel screens.
- **W9316:** General use; confirm touch; Teams/Office/Edge.
- Maintain allowlist if enforcing no Internet: `https://dev.azure.com/F1Technical/`, `https://miro.com/`.

### 7. Networking (for validation)
- **W9419:** NIC1 `10.100.3.81` mask "255.255.255.0-64" (likely `/24`) GW `10.100.3.254`.
- **WT-Healthmon:** NIC1 `10.100.3.33` GW `10.100.3.254`; NIC2 `172.16.179.8` GW none.
- **W9316:** NIC1 `172.29.28.118` `/23` GW `172.29.29.254`.
- OS: Windows 10 Enterprise (64-bit) all.

### 8. Validation (on-shift)
- Logon test with both shared accounts on each device.
- Validate paths, apps, SharePoint, and RDP (if used).
- Confirm screen-lock behaviour.

## Open Items
- Confirm subnet masks for W9419 and WT-Healthmon.
- Confirm Aeroprodsql instance/port and DSN.
- Confirm URL list for WT-Healthmon screens.
- Confirm if RDP required now or later.
- Confirm if Internet allowlist needed or route via admin.

## Discarded Approaches (BA)
- Rejected: complex domain groups for LAC/RDC/RO/RW.  
  Using: user-object Log On To + per-machine RDP groups.
- Rejected: kiosk mode.
- Rejected: immediate decommission of TunnelOps generic before UAT.

## Rollback
- Remove accounts from Log On To or local groups.
- Remove RDP groups if unused.
- Revert app config if changed.
- Restore `TunnelOps` generic if rollback needed.

---

# CAB DOCUMENT — SEQ10

## Change Summary
Implement shared account remediation for TunnelOps GEN machines using two new scoped accounts (`shr-tunops-gen01`, `shr-tunops-gen01Adm`) restricted to `W9419`, `WT-Healthmon`, and `W9316`, with optional RDP via per-machine groups.

## Business Justification
Replaces broad generic login with scoped shared accounts, ensuring accountability, least privilege, and operational continuity.

## Affected Systems
- Machines: `W9419`, `WT-Healthmon`, `W9316`
- Accounts: `shr-tunops-wte`, `shr-tunops-wteAdm`
- Applications: WTTP, Healthmonitor, Teams, Excel, Test Slate, Matlab, Edge web apps

## Risks & Mitigations
- Function breaks under shared account
    - Mitigation: keep TunnelOps generic enabled for rollback.
- RDP failure from missing group
    - Mitigation: pre-create RDP groups and validate.
- DB/licence issues
    - Mitigation: pre-test VBA/DB link and confirm licences.

## Implementation / Validation / Backout
Refer to Working Document sections for Implementation Steps, Validation, and Rollback.

## Stakeholders
- Owner: WT Systems (Mich Hackwood) / WT Engineers (Keith Forsythe)
- Implementer: Paul Davidson (Shared Account Remediation)
- Support: TIG (IT Support)

---

# SUPPORT DOCUMENT — SEQ10

## Purpose
Three WT2 devices use scoped shared accounts to replace the old TunnelOps generic, improving security and accountability.

## Day-to-Day Use
- **W9419:** WTTP/WT Scheduler, Teams, Excel VBA link, Test Slate, Matlab.
- **WT-Healthmon:** Dashboards across 8 screens, Healthmonitor apps, Edge web.
- **W9316:** General presentation/touchscreen.

## Access
- Shared accounts: `shr-tunops-gen01` and `shr-tunops-gen01Adm`.
- Restricted logon: only `W9419`, `WT-Healthmon`, `W9316`.
- RDP (if enabled): via `RDP_<MACHINE>` groups in local Remote Desktop Users.

## Software Notes
- Edge dashboards: verify URLs and order.
- Healthmonitor apps on WT-Healthmon: check service status.
- Excel VBA on W9419: check DSN/driver to `W9336`.
- SharePoint areas: AerodynamicOperations, ATF, Aerodynamics_Department, AeroOps1.

## Known Paths
- Network: `\\factory.wf1\DFS2`, `\\factory.wf1\Department2`
- Local:
    - **W9419:** `C:\WilliamsF1`, `C:\Scripts`
    - **WT-Healthmon:** `C:\WilliamsF1`, `C:\Scripts`, `C:\Health Monitor*`
    - **W9316:** `C:\WilliamsF1`

## Troubleshooting
- Cannot log on → check Log On To for device.
- RDP denied → check group membership.
- Excel DB fail → verify DSN/rights.
- Dashboards blank → check Edge URLs and app service.

---

# Rule 6 — Exact Commands

## Restrict Logon to Machines
```powershell
Import-Module ActiveDirectory
Set-ADUser -Identity "shr-tunops-wte" -LogonWorkstations "W9419,WT-Healthmon,W9316"
Set-ADUser -Identity "shr-tunops-wteAdm" -LogonWorkstations "W9419,WT-Healthmon,W9316"
(Get-ADUser "shr-tunops-wte" -Properties LogonWorkstations).LogonWorkstations
(Get-ADUser "shr-tunops-wteAdm" -Properties LogonWorkstations).LogonWorkstations