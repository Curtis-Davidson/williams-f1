# SUMMARY — SEQ15 TunnelOps

- **Purpose:**
  Transition WT2 diagnostic operations from the legacy *TunnelOps* generic account to controlled DIA shared accounts, ensuring continuity of 24/7 diagnostics while introducing traceable, machine-restricted access.
- **Machines:**
    - **L2160** — WT2 diagnostics laptop located above the tunnel. Connected to multiple diagnostic and measurement devices. Operates continuously during tunnel activity.
- **Accounts:**
    - **shr-tunops-dia01** — Standard diagnostics operations
    - **shr-tunops-dia01Adm** — Administrative diagnostics configuration
    - **TunnelOps** — Retained temporarily for rollback only
    - Passwords stored in approved IT vault with annual rotation
    - Final naming to be confirmed with department.
- **Software:**
    - Bespoke in-house WT2 diagnostic applications
    - Local data paths:
        - `C:\Users\shr-tunops-dia01\`
        - `C:\Williams\`
    - Network path:
        - `T:\ATF` → `\\smb.wf1-isil01.factory.wf1\department2`
    - Permitted web access only:
        - `https://dev.azure.com/F1Technical/`
        - `https://miro.com/`
- **Key Actions:**
    - Create DIA shared accounts
    - Restrict logon to L2160 via AD User Object → Log On To
    - Implement machine-specific RDP group
    - Migrate diagnostic data paths from TunnelOps profile
    - Validate USB diagnostic devices under Intune
    - Maintain rollback capability until stability confirmed

------

# WORKING DOCUMENT — SEQ15

## Scope

**In scope**

- Device L2160 (WT2 diagnostics)
- Migration from TunnelOps to DIA shared accounts
- Diagnostic software, data paths, permissions, and access control
- RDP access for authorised engineers

**Out of scope**

- Application redesign
- Hardware replacement
- Kiosk mode
- Network or VLAN re-architecture

------

## Implementation Steps (authoritative)

### 1. Account creation & attributes

- Create **shr-tunops-dia01**
  Description: Shared account for WT2 diagnostics operations.
- Create **shr-tunops-dia01Adm**
  Description: Administrative shared account for diagnostics configuration.
- Set “User must change password at next logon” = **No**
- Restrict logon via AD User Object → **Log On To**:
    - **L2160**

------

### 2. RDP Access

- Create security group **RDP_L2160** in OU **Shared Accounts RDP**
- Add required users (operational and engineering)
- On L2160, add **RDP_L2160** to local **Remote Desktop Users**

------

### 3. Local Permissions / Vendor Requirements

- Add **shr-tunops-dia01Adm** and approved DPT admin accounts to **local Administrators**
- Remove legacy or unrelated admin groups

------

### 4. Software / Configuration

- Retain all existing diagnostic applications
- Migrate data:
    - `C:\Users\TunnelOps\` → `C:\Users\shr-tunops-dia01\`
- Update application configuration files referencing legacy paths
- Confirm read/write access to:
    - `C:\Williams`
    - `T:\ATF`
- Restrict Internet access to approved URLs only

------

### 5. Intune / Compliance

- Verify L2160 remains Intune compliant
- Ensure USB diagnostic devices remain permitted:
    - Canon DSLR
    - PICO Logger
    - Maxon EPOS
    - Arduino

------

### 6. Validation

- Logon test using both DIA accounts on L2160
- Validate diagnostic software launches and operates correctly
- Confirm local and network path access
- Confirm RDP access for authorised users
- Confirm TunnelOps login still functional for rollback safety

------

## Open Items

- Confirm whether L2160 remains outside secure cabinet scope
- Confirm any hardcoded credentials within diagnostic tools
- Confirm ongoing USB device allow-listing requirements
- Confirm timing for final TunnelOps account removal

------

## Discarded Approaches

- Continued use of generic TunnelOps account — rejected
- Kiosk mode — unsuitable for diagnostic hardware
- Immediate decommission of TunnelOps — deferred
  → Project-standard method used: **AD Log On To + machine-specific RDP group**

------

## Rollback

- Remove DIA accounts from Log On To restrictions
- Restore TunnelOps local permissions if required
- Revert application paths to `C:\Users\TunnelOps`
- Disable DIA shared accounts if rollback extends beyond 48 hours

------

# CAB DOCUMENT — SEQ15

## Change Summary

Implement controlled DIA shared accounts on WT2 diagnostics laptop L2160, replacing the legacy TunnelOps generic login using standard shared account remediation controls.

## Business Justification

Improves security, traceability, and audit alignment while preserving uninterrupted diagnostic capability for Wind Tunnel operations.

## Affected Systems

- **Machine:** L2160
- **Accounts:** TunnelOps, shr-tunops-dia01, shr-tunops-dia01Adm
- **Applications:** WT2 bespoke diagnostic software

## Risk & Mitigation

- **Risk:** Application failure due to legacy path dependency
    - Mitigation: Migrate and validate paths pre-cutover
- **Risk:** USB devices blocked by Intune
    - Mitigation: Validate hardware allow-list prior to change
- **Risk:** Access disruption from logon restriction
    - Mitigation: Implement in agreed maintenance window with rollback available

## Implementation Plan

Follow Working Document implementation steps.

## Validation Plan

Follow Working Document validation steps.

## Backout Plan

Follow Working Document rollback procedure.

## Stakeholders

- **Owner:** Mich Hackwood — Wind Tunnel Systems Manager
- **Implementer:** Curtis-Davidson — Shared Account Remediation

------

# SUPPORT DOCUMENT — SEQ15

## Purpose

L2160 supports WT2 diagnostics and monitoring using bespoke in-house applications connected to physical measurement hardware. DIA shared accounts provide controlled access while maintaining operational continuity.

## Day-to-Day Use

Wind Tunnel and Methodology engineers log on using DIA shared accounts to run diagnostics, collect data, and review tunnel system behaviour.

## Access

- **Shared accounts**
    - shr-tunops-dia01 — operational use
    - shr-tunops-dia01Adm — administrative configuration
- **RDP**
    - Controlled via **RDP_L2160**
    - Access requests via Service Desk

## Software Notes

- In-house diagnostic tools only
- No external licensing dependencies
- Internet restricted to approved engineering platforms
- USB hardware essential for operation

## Known Paths

- `C:\Users\shr-tunops-dia01\`
- `C:\Williams\`
- `\\smb.wf1-isil01.factory.wf1\department2\ATF`

## Troubleshooting

- **Cannot log on:** verify L2160 listed under AD “Log On To”
- **RDP denied:** confirm membership in RDP_L2160 and local Remote Desktop Users
- **App errors:** verify folder permissions and configuration paths
- **USB not detected:** confirm Intune device allow-listing
- **Emergency fallback:** log on using TunnelOps until resolved

------

If you want next, I can:

- Add a **refresh footnote** (same style as your other TunnelOps sequences)
- Produce a **one-page Service Desk summary**
- Convert this into a **Confluence-ready clean export**
- Cross-align tone with SEQ06 / SEQ10 / SEQ12 so they read as one set

Just say which.