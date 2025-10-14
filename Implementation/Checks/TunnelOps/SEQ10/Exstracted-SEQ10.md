SUMMARY — SEQ10 TunnelOps (GEN)

Purpose: Replace legacy “TunnelOps” generic logins on three General WT Systems with scoped shared accounts, preserving operations and enabling controlled admin where required.

Machines:
•	W9419 — WT Test Planner (WTTP) primary control in WT2; controls WT Scheduler; 24×7.
•	WT-Healthmon (aka “WT2-Healthmon”) — VM driving 8 status screens (6 in WT2 Control Room, 2 in tunnel); shows Edge web apps + Williams “Healthmonitor” + another Williams app.
•	W9316 — Wall-mounted touchscreen in WT2 Control Room; general admin/presentation use.

Accounts:
•	shr-tunops-gen01 (standard)
•	shr-tunops-gen01Adm (admin)
•	Final naming to be confirmed with department (trailing descriptors if they want them).

Software / dependencies (by area):
•	W9419: MS Teams (IM), Excel (VBA to DB on W9336), Test Slate, Matlab, WTTP/WT scheduler control.
•	WT-Healthmon: Edge web apps; “Healthmonitor” (Williams app); “another Williams” app (desktop icons).
•	W9316: General use (PowerPoint, web apps).

Paths & Data:
•	Network: \\factory.wf1\DFS2, \\factory.wf1\Department2
•	Local: C:\WilliamsF1, C:\Scripts (W9419, WT-Healthmon); C:\WilliamsF1 (W9316); plus WT-Healthmon root folders starting with “Health Monitor”.
•	SharePoint:
•	…/sites/AerodynamicOperations
•	…/sites/ATF/SitePages/TEST HOME.aspx
•	…/sites/Aerodynamics_Department
•	…/sites/AeroOps1
•	Database: Aeroprodsql on port 59112 (exact server not stated; confirm).

Security model (your standard):
•	Logon restriction: set on the User Object → Log On To with explicit machine names.
•	RDP (if/when required): OU “Shared Accounts RDP” → create RDP_<MACHINE> group, add required users, add that group to local Remote Desktop Users on the target machine.

Internet for shared accounts: blocked by default; allowlist (if needed): https://dev.azure.com/F1Technical/, https://miro.com/ (confirm with SecOps/TIG before enforcing).

Key actions:
•	Create shr-tunops-gen01 and shr-tunops-gen01Adm.
•	Restrict both via Log On To to W9419, WT-Healthmon, W9316.
•	Add shr-tunops-gen01Adm (or an admin group containing it) to local Administrators on the three devices.
•	Map drives/paths, validate apps, confirm SharePoint access, and run UAT on shift.
•	Keep TunnelOps generic available for rollback until sign-off.

⸻

WORKING DOCUMENT — SEQ10

Scope

Remediate the “GEN” subset of TunnelOps machines (W9419, WT-Healthmon, W9316) by introducing two shared accounts with minimal blast radius, enforcing machine-scoped logon, and preparing optional RDP access using the standard RDP group pattern. No kiosk mode. No complex BA group lattice.

Implementation Steps (authoritative)

Accounts — create and describe
•	Create shr-tunops-gen01 (standard).
Description: “TunnelOps GEN — standard shared account for W9419, WT-Healthmon, W9316 (WT2)”.
•	Create shr-tunops-gen01Adm (admin).
Description: “TunnelOps GEN — admin shared account for W9419, WT-Healthmon, W9316 (WT2)”.
•	Password policy: long, vaulted; annual rotation per policy; store in Keeper/1Password; department informed on change via secure channel.
•	Note fields in AD: business owner (WT Systems), purpose, vault reference, rotation note.

Logon restriction (your method; no group indirection)
•	On each shared account’s AD user object: Log On To → add: W9419, WT-Healthmon, W9316.
•	Confirm TunnelOps generic remains functional for rollback until UAT sign-off.

Local admin (where needed)
•	On W9419, WT-Healthmon, W9316 add shr-tunops-gen01Adm (or domain group that contains it) to local Administrators.
•	Keep DPT Admin accounts intact. Do not add standard shr-tunops-gen01 to Administrators.

RDP access (only if required now or later)
•	Create (in OU “Shared Accounts RDP”) machine-scoped groups:
RDP_W9419, RDP_WT-Healthmon, RDP_W9316.
•	Add permitted users (roles/names) to the appropriate RDP_<MACHINE> group when RDP is actually requested.
•	On each machine, add its RDP_<MACHINE> to local Remote Desktop Users.

Drives / paths / permissions
•	Ensure shr-tunops-gen01 & shr-tunops-gen01Adm can R/W (as appropriate) to:
\\factory.wf1\DFS2, \\factory.wf1\Department2.
•	Local paths:
•	W9419: C:\WilliamsF1, C:\Scripts (R/W as required)
•	WT-Healthmon: C:\WilliamsF1, C:\Scripts, roots starting “Health Monitor*”
•	W9316: C:\WilliamsF1
•	SharePoint (interactive access):
…/AerodynamicOperations, …/ATF/SitePages/TEST HOME.aspx, …/Aerodynamics_Department, …/AeroOps1.

Apps / config
•	W9419: Teams; Excel (VBA to DB on W9336 — confirm server & DSN/ODBC); Test Slate; Matlab; WTTP/WT Scheduler control shortcuts & permissions.
•	WT-Healthmon: Desktop icons for “Healthmonitor” and the second Williams app; Edge profiles/URLs for 6 control-room screens + 2 tunnel screens (screen mapping list).
•	W9316: General; confirm touch support; ensure Teams/Office/Edge are present and profiles don’t break screen lock policy.
•	If you enforce no Internet for shared accounts, maintain allowlist:
https://dev.azure.com/F1Technical/, https://miro.com/. Validate with SecOps/TIG.

Networking (for reference/validation)
•	W9419 NIC1: 10.100.3.81 / mask in BA reads “255.255.255.0-64” (likely /24) GW 10.100.3.254 — confirm mask.
•	WT-Healthmon: NIC1 10.100.3.33 (/24?) GW 10.100.3.254; NIC2 172.16.179.8 (/24?) GW none — confirm masks.
•	W9316 NIC1: 172.29.28.118 /23 GW 172.29.29.254.
•	OS: Windows 10 Enterprise (64-bit) on all three.

Validation (on-shift, with operators)
•	Logon with both shared accounts on each device.
•	Confirm drive/path R/W tokens.
•	Confirm SharePoint access.
•	Launch apps and run representative workflows (Excel→W9336 DB, WTTP control actions, Healthmonitor dashboards, etc.).
•	If RDP enabled, test via RDP_<MACHINE> membership.
•	Prove screen-lock behaviour when unattended.

Open Items (to confirm)
•	Exact subnet masks for W9419 and WT-Healthmon NICs (BA text uses “-64”).
•	Precise server/instance for Aeroprodsql:59112 and any DSN/driver requirements.
•	Full URL list for each WT-Healthmon screen (1–8), plus the name of the “another Williams” app.
•	Whether RDP is required now; if not, park RDP_<MACHINE> groups empty.
•	Whether Internet allowlist is truly required for shared accounts (Azure DevOps/Miro), or route via admin account only.

Discarded Approaches (BA)
•	Complex domain groups for LAC/RDC/RO/RW everywhere — replaced with:
•	Logon restriction on the user object (explicit machines).
•	RDP per-machine group in “Shared Accounts RDP” OU when needed.
•	Kiosk mode — not appropriate for specialist machinery.
•	Immediate decommission of TunnelOps generic — keep enabled until GEN UAT passes, then plan disable in a separate change.

Rollback
•	Remove shr-tunops-gen01 & shr-tunops-gen01Adm from Log On To scope (or clear temporarily).
•	Remove shr-tunops-gen01Adm (or admin group) from local Administrators.
•	Remove RDP_<MACHINE> from local Remote Desktop Users (if created).
•	Revert any app config files you altered (list path in change notes).
•	Operators resume using TunnelOps generic until fix forward.

⸻

CAB DOCUMENT — SEQ10

Change Summary

Introduce two scoped shared accounts (shr-tunops-gen01, shr-tunops-gen01Adm) for TunnelOps GEN machines (W9419, WT-Healthmon, W9316), restrict their interactive logon to those machines, and (if required) enable controlled RDP via per-machine groups.

Business Justification

Reduces risk from a broad, embedded generic account; improves accountability and least-privilege while preserving operational continuity for WT2 processes.

Affected Systems
•	Machines: W9419, WT-Healthmon (VM), W9316 (touchscreen) — all WT2 area.
•	Accounts: shr-tunops-gen01, shr-tunops-gen01Adm.
•	Applications: WTTP control, Healthmonitor, additional Williams app, Teams, Excel (VBA→W9336), Test Slate, Matlab, Edge web apps.

Risks & Mitigations (practical)
•	Function stops working under shared account.
Mitigation: keep TunnelOps generic enabled for rollback; implement during low-risk window; on-shift UAT.
•	RDP access denied (if used) due to missing group mapping.
Mitigation: create RDP_<MACHINE> first; validate membership before enabling GPO/policy.
•	Licensing / DB connectivity mis-scoped.
Mitigation: pre-test Excel→W9336 VBA path; verify Aeroprodsql connection and drivers; confirm app licence behaviour with vendor.

Implementation Plan

As per “Implementation Steps (authoritative)” in the Working Document.

Validation Plan

As per “Validation” in the Working Document; execute with operators present.

Backout Plan

As per “Rollback” in the Working Document.

Stakeholders (minimal)
•	Owner: WT Systems (Mich Hackwood) / WT Engineers (Keith Forsythe)
•	Implementer: Curtis-Davidson (Shared Account Remediation)
•	Support: IT Support (TIG) for device/GPO touchpoints

⸻

SUPPORT DOCUMENT — SEQ10

Purpose

These three WT2 devices use two scoped shared accounts (standard/admin) instead of the historic “TunnelOps” generic. This narrows access, keeps WT operations stable, and supports auditability.

Day-to-Day Use
•	W9419: WTTP/WT Scheduler control; Teams; Excel (VBA to W9336 DB); Test Slate; Matlab.
•	WT-Healthmon: Always-on VM showing dashboards across 8 screens; runs “Healthmonitor” and another Williams app, plus Edge web apps.
•	W9316: General touchscreen for presentations/web in WT2 Control Room.

Access
•	Shared accounts: shr-tunops-gen01 (standard), shr-tunops-gen01Adm (admin).
•	These accounts are restricted to log on only to W9419, WT-Healthmon, W9316.
•	RDP (if enabled): membership of RDP_W9419 / RDP_WT-Healthmon / RDP_W9316 controls access; those groups are added to each machine’s local Remote Desktop Users.

Software Notes
•	Edge dashboards: confirm exact URLs/ordering across 1–8.
•	“Healthmonitor” and the second Williams app launch via desktop icons on WT-Healthmon.
•	Excel on W9419 uses VBA to connect to DB on W9336 (confirm DSN/driver and credentials).
•	SharePoint areas used by operators: AerodynamicOperations / ATF / Aerodynamics_Department / AeroOps1.

Known Paths
•	Network: \\factory.wf1\DFS2, \\factory.wf1\Department2
•	Local:
•	W9419: C:\WilliamsF1, C:\Scripts
•	WT-Healthmon: C:\WilliamsF1, C:\Scripts, C:\Health Monitor* (root folders)
•	W9316: C:\WilliamsF1

Troubleshooting
•	Cannot log on: check User Object → Log On To includes the device name; confirm you’re using shr-tunops-gen01/…Adm.
•	RDP denied: confirm user is in RDP_<MACHINE> and that group is in local Remote Desktop Users on target machine.
•	Excel DB fail (W9419): verify network path to W9336, DSN/driver, and account rights.
•	Dashboards blank (WT-Healthmon): check Edge URLs, profile, and the “Healthmonitor” app service status.

⸻

Rule 6 — Exact commands (ready to paste)

Restrict logon to the three machines (run in a privileged PowerShell on a management workstation with RSAT)

# PURPOSE: Restrict interactive logon of shared accounts to W9419, WT-Healthmon, W9316
Import-Module ActiveDirectory

Set-ADUser -Identity "shr-tunops-gen01"    -LogonWorkstations "W9419,WT-Healthmon,W9316"
Set-ADUser -Identity "shr-tunops-gen01Adm" -LogonWorkstations "W9419,WT-Healthmon,W9316"

# Verify
(Get-ADUser "shr-tunops-gen01" -Properties LogonWorkstations).LogonWorkstations
(Get-ADUser "shr-tunops-gen01Adm" -Properties LogonWorkstations).LogonWorkstations

Create per-machine RDP groups and (optionally) add initial members

# PURPOSE: RDP groups per machine in OU "Shared Accounts RDP"
Import-Module ActiveDirectory
$ou = "OU=Shared Accounts RDP,DC=wf1,DC=local"   # <-- adjust to your domain DN

$groups = @("RDP_W9419","RDP_WT-Healthmon","RDP_W9316")
foreach ($g in $groups) {
if (-not (Get-ADGroup -LDAPFilter "(cn=$g)" -ErrorAction SilentlyContinue)) {
New-ADGroup -Name $g -Path $ou -GroupScope Global -GroupCategory Security -Description "RDP access to $($g -replace '^RDP_','')"
}
}

# Example: add users later when required
# Add-ADGroupMember -Identity "RDP_W9419" -Members "WF1\keith.forsythe","WF1\mich.hackwood"


Map RDP group to local “Remote Desktop Users” (per machine)

# PURPOSE: Add RDP_<MACHINE> to local Remote Desktop Users on the target machine
$machine = "W9419"  # change per target
$rdpGroup = "WF1\RDP_W9419"

Invoke-Command -ComputerName $machine -ScriptBlock {
param($grp)
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $grp
} -ArgumentList $rdpGroup


Add admin shared account (or admin group) to local Administrators

# PURPOSE: Grant admin shared account local admin on target machines
$machines = "W9419","WT-Healthmon","W9316"
$adminMember = "WF1\shr-tunops-gen01Adm"   # or a domain group that contains it

Invoke-Command -ComputerName $machines -ScriptBlock {
param($m)
Add-LocalGroupMember -Group "Administrators" -Member $m
} -ArgumentList $adminMember

Drive access smoke test (token files)

# PURPOSE: Quick R/W token write under shared account session
$paths = "\\factory.wf1\DFS2","\\factory.wf1\Department2"
foreach ($p in $paths) {
$t = Join-Path $p ("token_" + $env:COMPUTERNAME + "_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")
"ok from $env:USERNAME @ $env:COMPUTERNAME" | Out-File -FilePath $t -Encoding ascii
}









