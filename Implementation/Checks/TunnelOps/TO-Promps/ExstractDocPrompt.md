**UT-NoBS Extraction Prompt v1.0 (Reusable — paste this above your sequence text)**


You are assisting on Williams Formula One’s Shared Account Remediation project. Your job is to extract ONLY the actionable working information from the BA’s discovery text below and output four clean Markdown sections. Avoid governance filler, cross-references, or “see section x” language. Use British English. No corporate fluff. Plain, friendly, accurate.

CONSTANT PROJECT RULES (always apply):
- Logon restriction method: Apply via AD User Object → “Log On To” with explicit MACHINE NAMES (no group-based indirection).
- RDP method: There is an OU named “Shared Accounts RDP”. For any machine needing RDP, create a machine-specific security group in that OU, add required users to the group, and add that group to the local “Remote Desktop Users” on the machine. Use this consistently.
- Naming: Start from BA’s suggested names; final trailing descriptor is confirmed with the department for contextual clarity. Write: “Final naming to be confirmed with department.”
- Tone: Clear, cooperative, implementation-focused. No governance jargon, no references to other documents, no obscure codes.

INPUT:
- Department: TunnelOps
- Sequence ID: SEQ{NN}  (replace with actual number if present in the text; if absent, infer from file name or leave “TBC”)
- Raw BA text (verbatim, pasted below):
  <<<BA_TEXT_START
  PASTE THE FULL PLAIN TEXT FROM THE .TXT FILE HERE
  BA_TEXT_END>>>

TASKS:
1) Identify and list:
    - Purpose of the sequence (why this exists)
    - Machines (hostnames), locations if stated, and role of each machine
    - Accounts (existing, new shared accounts), required access, MFA/Intune state if noted
    - Software/applications actually used on each machine (e.g. NX, TeamCenter, Wind Tunnel Planner, MPart, etc.)
    - Network shares/paths, scanner/camera hotfolders, service dependencies, licence dongles, vendor tools, etc.
    - People/roles who actually use it day to day (minimal: role or named if present)
    - Data flows relevant to operation (e.g. photo capture → OneDrive → workstation profile)
    - Security controls explicitly needed (logon restriction, RDP, local admin/vendor accounts)
    - Open questions / missing info (as actionable bullets)
    - Risks/constraints (practical, not governance speak)

2) Apply CONSTANT PROJECT RULES wherever relevant. If the BA proposed a different approach (complex groups, etc.), note it briefly under “Discarded Approaches” and state the project-standard approach you will implement instead.

3) Output exactly four Markdown sections in this single response, in this order, using these headers and skeletons:

# SUMMARY — SEQ{NN} TunnelOps
- Purpose: <1–2 lines>
- Machines: <bulleted list of hostnames + role>
- Accounts: <bulleted list (new shared accounts, existing, MFA/Intune notes)>
- Software: <bulleted list by machine if needed>
- Key Actions: <tight bullet list of what will be changed/created>
- Final naming to be confirmed with department.

# WORKING DOCUMENT — SEQ{NN}
## Scope
- <what is in/out, practical terms>

## Implementation Steps (authoritative)
1. Account creation & attributes
    - Create <account_name>. Description: <short, human-meaningful>.
    - Set “User must change password at next logon” = <Yes/No per standard>.
    - Restrict logon via User Object → Log On To → add:
        - <MACHINE_1>, <MACHINE_2>, …
2. RDP Access (only if applicable)
    - Create security group “RDP_<MACHINE_NAME>” in OU “Shared Accounts RDP”.
    - Add required users: <names/roles>.
    - On <MACHINE_NAME>, add “RDP_<MACHINE_NAME>” to local “Remote Desktop Users”.
3. Local Permissions / Vendor Requirements (if any)
    - Add group/user <x> to local <Administrators/Power Users/Custom>.
4. Software / Configuration
    - Install/verify: <apps> with version if stated.
    - Configure: <paths, hotfolders, OneDrive sync targets, pinned SharePoint sites, VLC migration, etc.>
5. Intune / Compliance (if stated)
    - Ensure machine is Intune enrolled and aligned with E5 licensing baseline.
6. Validation
    - Logon test with <account> on <machine>.
    - App open/close sanity checks.
    - RDP test (if applicable).
    - OneDrive/SharePoint path check (if applicable).

## Open Items
- <questions to confirm>.

## Discarded Approaches
- <brief note on BA’s rejected methods> → Using project-standard method instead.

## Rollback
- Remove <account/group> from <Log On To / local groups>.
- Delete created security group(s) if unused.
- Revert app config files (list path if we changed anything).

# CAB DOCUMENT — SEQ{NN}
## Change Summary
- Implement shared account remediation for <machine(s)> in TunnelOps using standard method.

## Business Justification
- Replace legacy logins with controlled shared account(s), enforce scope-limited access, standardise RDP where required.

## Affected Systems
- Machines: <list>
- Accounts: <list>
- Applications: <list>

## Risk & Mitigation (practical)
- Risk: Access disruption if logon restriction set before validation.
    - Mitigation: Implement in maintenance window, pre-validate with test account.
- Risk: RDP failure due to missing local group membership.
    - Mitigation: Pre-create “RDP_<MACHINE>” group and add before enabling policy.

## Implementation Plan
- Steps: Reference “Implementation Steps” in Working Document (same content).

## Validation Plan
- Steps: Reference “Validation” in Working Document (same content).

## Backout Plan
- Steps: Reference “Rollback” in Working Document (same content).

## Stakeholders (minimal)
- Requestor/Owner (dept lead): <name/role if present>
- Implementer: Curtis-Davidson (Shared Account Remediation)

# SUPPORT DOCUMENT — SEQ{NN}
## Purpose
- What this machine/account does in simple terms.

## Day-to-Day Use
- Who uses it and how.

## Access
- Which shared account(s).
- Where RDP is allowed and how to request additions (point to “RDP_<MACHINE>” group membership).

## Software Notes
- App list + known quirks (viewer codecs, pinned sites, licence paths, hotfolders).

## Known Paths
- <\\server\share\...> or<C:\path\...> <OneDrive\...> etc.

## Troubleshooting
- Can’t log on → check “Log On To” list for machine name.
- RDP denied → verify membership in “RDP_<MACHINE_NAME>” and local “Remote Desktop Users”.
- App fails to open → check licence path <path>, confirm Intune compliance baseline, restart app.

END OF SPEC.