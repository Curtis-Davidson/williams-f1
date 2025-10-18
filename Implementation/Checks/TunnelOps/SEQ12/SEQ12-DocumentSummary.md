# **SUMMARY — SEQ12 TunnelOps**



- **Purpose:** Replace the legacy “TunnelOps” generic account used on Device M3164 for WT2 Wind Tunnel Test Monitoring with two new access-controlled shared accounts (shr-tunops-wta and shr-tunops-wtaAdm) to improve accountability, strengthen security, and maintain business continuity during migration.

- **Machines:**



- **M3164** – WT2 Control Room workstation used for Wind Tunnel Test Monitoring; primary focus of SEQ12.



    - IP 10.100.3.60 Subnet 255.255.254.0-64 Gateway 19.100.3.254
    - Role: Dedicated WTA system host, retained temporarily for rollback.



- **Accounts:**



- shr-tunops-wta – Standard shared account for WTA operations (E5 licence, Teams, OneDrive, Exchange mailbox required).
- shr-tunops-wtaAdm – Administrative shared account for WTA setup, app maintenance and configuration.
- Associated AD Groups: grp-tunops-wtaRW, grp-tunops-wtaRO, grp-tunops-wtaLAC, grp-tunops-wtaAdm, grp-tunops-wtaRDC.
- Logon restricted via AD User Object → “Log On To” → M3164 only.



- **Software:**



- WTTP, AeroView, Aero Manager, M-Part, MovieViewer, T3, NX, TeamCentre, PowerApps, Power BI, OneNote, SharePoint, MS Office, Acrobat, CamMan, VLC, Snipping Tool.



- **Key Actions:**



- Create shared accounts and mailboxes.
- Create and assign AD groups for access control and local administration.
- Map drives P:\ (\\factory.wf1\DFS2) and T:\ (\\factory.wf1\wf1\Department2).
- Configure SharePoint and database access (Aeroprodsql, port 59112).
- Limit Internet access to approved URLs (dev.azure.com, miro.com).
- Retain TunnelOps account for rollback until validation complete.
- Enforce password rotation and AD notes per policy.



- **Final naming to be confirmed with department.**



------

# **WORKING DOCUMENT — SEQ12**

## **Scope**

- Transition M3164 Wind Tunnel Test Monitoring to new WTA shared accounts.
- Maintain operational continuity using rollback plan.
- Decommission TunnelOps account post-validation.

## **Implementation Steps (authoritative)**

1. **Account creation & attributes**



- Create shr-tunops-wta (standard WTA shared account).
- Create shr-tunops-wtaAdm (administrative WTA shared account).
- “User must change password at next logon” = No.
- Restrict logon to M3164.



2. **RDP Access**

    - Create RDP_M3164 in OU “Shared Accounts RDP”.
    - Add authorised users (WTA admins / DPT Admin).
    - On M3164, add RDP_M3164 to local “Remote Desktop Users”.



3. **Local Permissions / Vendor Requirements**

    - Add grp-tunops-wtaAdm and DPT Admin to local Administrators.
    - Remove non-essential admin entries.



4. **Software / Configuration**

    - Verify apps (WTTP, AeroView, Aero Manager, NX, TeamCentre, PowerApps etc.).
    - Map P:\ → \\factory.wf1\DFS2; T:\ → \\factory.wf1\wf1\Department2.
    - Grant SharePoint access https://williamsf1.sharepoint.com/sites/Aerodynamics_Department/Documents/.
    - Database Aeroprodsql, 59112.
    - Confirm Teams, OneDrive and Exchange connectivity.
    - Block general Internet access; allow dev.azure.com, miro.com.



5. **Intune / Compliance**

    - Ensure M3164 enrolled and compliant with E5 baseline.



6. **Validation**



- Logon tests for both accounts.
- Verify network drives and SharePoint access.
- Confirm apps operate normally.
- Validate rollback via TunnelOps account.



## **Open Items**

- Confirm final device naming for replacement.
- Confirm licensing (E5 and bespoke apps).
- Validate SharePoint permissions.
- Confirm database connection string updates if hard-coded.

## **Discarded Approaches**

- Preventing TunnelOps login – rejected (admin rights dependency).
- Kiosk mode – rejected (safety and control).
- Complex group hierarchy – replaced with direct “Log On To”.

## **Rollback**

- Re-enable TunnelOps on M3164.
- Remove WTA accounts and groups if rollback triggered.
- Delete RDP_M3164 if unused.
- Revert drive mappings and configs.



------

# **CAB DOCUMENT — SEQ12**

## **Change Summary**

Implement new shared accounts (shr-tunops-wta, shr-tunops-wtaAdm) for WT2 monitoring, replacing the generic TunnelOps login.

## **Business Justification**

Eliminate shared credential risk while maintaining operational integrity of the critical WTA system.

## **Affected Systems**

- **Machines:** M3164
- **Accounts:** shr-tunops-wta, shr-tunops-wtaAdm
- **Applications:** WTTP, AeroView, Aero Manager, M-Part, NX, TeamCentre, PowerApps, Power BI, SharePoint, OneNote, VLC, MS Office.

## **Risk & Mitigation (practical)**



- Risk: Functionality gaps under new accounts.

  Mitigation: Retain TunnelOps for rollback until validation.

- Risk: Licence or DB permissions mismatch.

  Mitigation: Verify licensing and database access before cut-over.

- Risk: Network mapping issues.

  Mitigation: Test P:\ T:\ and SharePoint prior to sign-off.

## **Implementation Plan**

- Follow “Implementation Steps”

## **Validation Plan**

- Follow “Validation”

## **Backout Plan**

- Follow “Rollback”

## **Stakeholders (minimal)**



- Requestor/Owner: Duncan Barr (Principal Aero Engineer)
- Implementer: Paul Davidson (Shared Account Remediation)





------

