Executive Summary — TunnelOps Generic Account Risk Remediation
🧠 Purpose
To remediate security risk by phasing out the use of the TunnelOps generic account ID on a defined list of wind tunnel machines, transitioning to individual user accounts, and decommissioning obsolete devices. Document is sequence-based, assumes prior remediations have been implemented.

📌 Key Implementation Outcomes
1. Devices to Be Decommissioned (Hand-off to DPT)
   Devices are no longer used in the Wind Tunnel area.

Device Group 1 (Mich Hackwood):
M1156, M1924, WT2_BMS, ATFHEALTHMON10, W9330, W9421, W9415, W9422

Device Group 2 (Calum Mciver):
M1132, M1208

Device Group 5 (Richard Sinclair):
WT2-Atlas02

🛠️ Action:

Mark as obsolete

Schedule physical collection

DPT to decommission

2. Devices to Switch from TunnelOps to Individual Accounts
   These remain operational, but generic login will be prohibited by policy.

Device Group 3, 6, 7, 8 (Various Stakeholders)
W9357, M9124, W8836, M3058, M3079, M3076, M3015, L2016, L2315, W9378,
W9377, W9312, W8710, T2013, W9432, W9435, M9476, T2420,
WT2ADMIN, WT2-SSRS, FACT-AEROADMIN01, W9322

🛠️ Action:

Remove TunnelOps from local admin group

Remove all business users from local admin

Enforce policy: individual accounts only

TunnelOps login remains technically possible (fallback), but not to be used

3. Admin Permission Removals (Precision Targeted)
   Specific devices require hardening via local admin group cleanup.

Example Actions:

M9124: Remove TunnelOps from Administrators

M3058: Remove Aero Local Admin Group

WT2ADMIN: Remove adrake and TunnelOps from Administrators

WT2-SSRS: Remove seven named individuals

W9432, W9435, W9476: Remove Aero Local Admin Group

🛠️ All actions confirmed and agreed in technical decision meetings (15/10/2024 and 04/11/2024).

⚠️ Risks & Mitigation
Ref	Risk	Mitigation
R01	Apps may break under Individual logins	Business teams monitor and escalate
R02	Unknown app licensing dependencies	Same as above
R03	TunnelOps still has admin rights	Enforced by business process, not technical lock
R04	Removing admin access could disrupt ops	Teams monitor and resolve as needed

📌 None of these risks are project-blockers — all are tagged as "Non-Project Risk" with business owner flags.

🧱 Design Decisions (Canonical)
No Kiosk Mode: Not suitable due to equipment access risks.

No hard block on TunnelOps login: Still admin; removing could cause operational impact elsewhere.

All changes are business-driven with IT enforcement support.

🗂️ Governance and Approvals
Approved via stakeholder meetings (dates: 15/10/2024, 04/11/2024)

Fully versioned, with traceable decision logs

Device-specific remediation references logged as:
e.g., tunnelops-ind01-FR0011-01 (for L2315 admin removal)

✅ Ready to Proceed
This document is operationally clear, stakeholder-aligned, and implementation-ready. All device-specific actions are mapped, approved, and logically grouped.

If you're building automation scripts, IAM policy updates, or validation tooling, let me know — we can structure the implementation layer using this as source of truth.

Would you like:

A master spreadsheet mapping each device to its action and stakeholder?

Ansible/GPO logic to automate the group membership updates?

Slack alert script to notify on usage of TunnelOps where it shouldn’t be?

Ready to proceed to next layer on your word.