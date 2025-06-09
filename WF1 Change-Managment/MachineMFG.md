# CAB Submission – Replacement of Generic Accounts with Shared Account `shr-machine-mfg`

## A – Action Plan (Implementation Steps)

### [shr-machine-mfg-FR0001-01]
**Create AD Shared Account**
- Create new AD account: `shr-machine-mfg`
- Complies with IT policy requiring all shared accounts to be prefixed with `shr-`
- Replaces non-compliant accounts: `CellA`, `CellB`

### [shr-machine-mgf-FR0021-01 to FR0024-01]
**Create Supporting AD Groups**
- Create access control groups:
    - `grp-machine-mfgRO` (read-only)
    - `grp-machine-mfgRW` (read/write)
    - `grp-machine-mfgLAC` (local access control)
    - `grp-machine-mfgRDC` (RDP access control)
- Ensures role separation and PoLP alignment

### [shr-machine-mfg-FR0041-01, FR0042-01]
**Assign Shared Account to Required Groups**
- Add `shr-machine-mfg` to:
    - `grp-machine-mfgRW`
    - `grp-machine-mfgLAC`
- Enables login and access to required resources

### [shr-machine-mfg-FR0061-01 to FR0063-01]
**Configure Storage Access**
- Grant mapped network drive access: V:\, J:\, Z:\
- Enable local RW access on devices
- Ensure access to defined SharePoint libraries:
    - [Metallic Manufacturing](https://williamsf1.sharepoint.com/sites/SPC-MetallicManufacturing)
    - [Shopfloor Development](https://williamsf1.sharepoint.com/sites/ShopfloorDevelopent)

### [shr-machine-mfg-FR0102-01]
**Restrict Login to Machine Shop Devices Only**
- Limit `shr-machine-mfg` login access to:
    - M8662, W9474, M1909, M8687, SEIKI21
- Enforces least privilege and reduces misuse risk

### [shr-machine-mfg-FR0121-01]
**Restrict RDP Access**
- Only members of `grp-machine-mfgRDC` can RDP to target machines
- Prevents broad, uncontrolled remote access

### [shr-machine-mfg-FR0341-01]
**Remove Legacy Generic Accounts from Local Admins**
- Remove `CellA` and `CellB` from local Administrator groups
- Eliminates hidden privilege risk on devices

### [shr-machine-mgf-FR0141-01 to FR0144-01]
**Enable and Test App/Web Access**
- Confirm access to key apps:
    - NX, Teamcenter, Mestec, MS Office, MS Edge
- Test compatibility under `shr-machine-mfg`
- Perform UAT for all apps and web apps

### [shr-machine-mgf-FR0142-01]
**File Transfer from Legacy Accounts**
- Migrate any remaining files from `CellA` / `CellB` to `shr-machine-mfg` storage

### [shr-machine-mfg-FR0301-01]
**Validate Software Licensing**
- Confirm Teamcenter and NX licensing compliance
- Avoid unlicensed usage under new shared account

### [shr-machine-mfg-FR0321-01]
**Enable Internet Access**
- Ensure `shr-machine-mfg` has internet access per policy
- Required for system updates and web app access

### [shr-machine-mfg-FR0361-01, FR0362-01]
**Password Policy and AD Documentation**
- Enforce annual password change
- Store in 1Password vault
- Document usage, owner, and security policy in AD notes

### [shr-machine-mfg-FR0501-01]
**Disable Legacy Generic Accounts**
- Decommission `CellA` and `CellB` accounts in AD/Entra
- Triggered only after successful implementation and testing

---

## B – Business Justification

- Removes legacy non-compliant generic accounts
- Aligns with IT Security standards for shared accounts (`shr-*` naming)
- Reduces attack surface and privilege creep risk
- Enables secure, traceable access for over 40 users in the Machine Shop
- Ensures continuity of manufacturing operations

---

## C – Risk Assessment

| Risk Ref | Description                                                  | Mitigation                                     |
|----------|--------------------------------------------------------------|------------------------------------------------|
| R01      | Migration from legacy account may cause unexpected behaviour | Staged rollout and UAT validation              |
| R02      | Some apps may have hardcoded references to old accounts      | Perform config validation and app testing      |
| R03      | Possible Teamcenter licence gaps                             | Review licensing before go-live                |
| R04      | Possible NX CAD/CAM licence mismatch                         | Confirm contract and entitlement before switch |

---

## D – Rollback Plan

- Retain `CellA` / `CellB` accounts in disabled state for 14 days post-migration
- Reactivate accounts if any critical application failure occurs
- Backup of original app configs prior to transfer

---

## E – Test Plan (UAT)

1. Confirm `shr-machine-mfg` login on each device
2. Test mapped drives and SharePoint access
3. Launch and validate all core apps
4. Confirm RDP access for RDC group users
5. Monitor for 48 hours across shift handovers

---

Let me know if you'd like this wrapped in a CAB change template or Word version for submission.

-----------------------------------------------------

# CAB Submission – Decommissioning of Generic Accounts (CellA & CellB) and Implementation of Shared Account `shr-machine-mfg`

---

## C – Context

**Project Title:** Remediate Generic Account Risk – Machine Shop  
**Change ID (Reference):** P-135901  
**Business Function:** Metallic Manufacturing – Machine Shop  
**Change Type:** Standard Infrastructure Change  
**Priority:** High (Security Compliance + Operational Continuity)  
**Implementation Owner:** Paul Davidson  
**Stakeholder Owner:** Conner Murphy

### Summary:
This change will replace legacy generic Windows login accounts (`CellA`, `CellB`) used on the Machine Shop floor with a compliant, controlled, and auditable shared account: `shr-machine-mfg`.

The current use of generic logins breaches IT security policy, lacks traceability, and increases risk. This change introduces named AD groups with scoped access, ensures principle-of-least-privilege (PoLP), and aligns with Williams F1 security posture.

---

## R – Risk Assessment

### Current State:
- Five critical manufacturing devices (M8662, W9474, M1909, M8687, SEIKI21) use insecure shared credentials.
- No login accountability (all users share `CellA` or `CellB`)
- Admin rights are loosely scoped.
- No effective control over RDP, SharePoint or drive access

### Identified Risks (with mitigation):
| Risk Ref | Description                                                        | Mitigation                                              |
|----------|--------------------------------------------------------------------|---------------------------------------------------------|
| R01      | Legacy apps may not function correctly with the new shared account | App validation and staged UAT                           |
| R02      | Hardcoded credentials may exist in NX or Teamcenter                | Confirm all integrations and run test sessions          |
| R03      | Licensing for NX/Teamcenter may be invalid                         | Engage business owner for audit and contract validation |
| R04      | Users may not adopt the new login process cleanly                  | Stakeholder-led communication and desk support          |

---

## A – Action Plan (Implementation Steps)

### Account Creation and Group Structure

- **[shr-machine-mfg-FR0001-01]** Create AD Shared Account: `shr-machine-mfg`
- **[FR0021-01 to FR0024-01]** Create supporting AD groups:
    - `grp-machine-mfgRO`
    - `grp-machine-mfgRW`
    - `grp-machine-mfgLAC` (Local Access Control)
    - `grp-machine-mfgRDC` (Remote Desktop Control)
- **[FR0041-01, FR0042-01]** Assign `shr-machine-mfg` to RW and LAC groups

### Storage and App Access

- **[FR0061-01 to FR0063-01]** Configure drive access:
    - `V:\`, `J:\`, `Z:\`
    - SharePoint: [Metallic Manufacturing](https://williamsf1.sharepoint.com/sites/SPC-MetallicManufacturing), [Shopfloor Development](https://williamsf1.sharepoint.com/sites/ShopfloorDevelopent)
- **[FR0141-01 to FR0144-01]** Confirm full application compatibility via UAT
- **[FR0142-01]** Migrate legacy files from `CellA`/`CellB` to shared profile

### Device and Login Configuration

- **[FR0102-01]** Restrict login access to only listed devices
- **[FR0121-01]** Lock RDP access to members of `grp-machine-mfgRDC`
- **[FR0341-01]** Remove `CellA` and `CellB` from local Admin groups

### Security Policy and Operations

- **[FR0361-01]** Enforce annual password change for `shr-machine-mfg`
- **[FR0362-01]** Add AD notes detailing purpose, owner, and password control
- **[FR0321-01]** Permit internet access under shared account per policy

### Finalisation and Decommissioning

- **[FR0501-01]** Disable `CellA` and `CellB` in AD/Entra post-successful implementation
- Record changes in ITSM system, backup old account data, and retain for 14 days post-cutover

---

## F – Functional & Security Justification

### Why this change is essential:

- Removes the use of non-compliant, shared credential accounts
- Aligns with internal audit, IT security, and ISO27001 principles
- Enforces named-user accountability through group delegation and audit trace
- Ensures compliance without degrading operational performance for Machine Shop staff
- Preserves fast login experience while securing infrastructure access

---

## T – Test Plan

### UAT Checklist:
- [ ] Can login with `shr-machine-mfg` on all five target devices
- [ ] Confirm mapped drives mount: `V:`, `J:`, `Z:`
- [ ] Open and interact with: NX, Teamcenter, Mestec, MS Office
- [ ] Access and navigate SharePoint: Manufacturing + Shopfloor sites
- [ ] Perform RDP test from an authorised source device
- [ ] Validate local admin restrictions apply
- [ ] Confirm internet access functions within policy constraints
- [ ] Verify password is vaulted and recoverable via 1Password

---

## Implementation Window

- **Proposed Date:** Wednesday, [Insert actual date here]
- **Expected Duration:** 2 hours (1-hour prep, 1-hour implementation + validation)
- **Downtime Impact:** None (transparent to users during standard shift)
- **Affected Users:** 40+ machine shop personnel (Conner Murphy's team)

---

## Implementation Owner

- **Name:** Paul Davidson
- **Department:** Infrastructure Engineering
- **Email:** paul.davidson@williamsf1.com

---

## Approval Required From

- Mike Smith – IT Support Manager
- Chris Hicks – IT Security Engineer
- Conner Murphy – Manufacturing (business sponsor)

---

## E – Emergency Rollback Plan

- Retain disabled `CellA`/`CellB` accounts for 14-day fallback window
- Restore original AD group membership if needed
- Revert mapped drives and app configurations (snapshot prior)
- Engage IT Support Team (TIG) for full rollback coordination

---

## CAB Notes

- Aligns with the WF1 IT Security Policy (2025.03)
- Implements PoLP access control
- All decisions made and approved in Technical Review – 03/03/2025

---

## Attachments

- `shr-machine-mfg.docx` (source requirements and device list)
- Full user list (Excel, provided separately)
- AD diagram: Figure 1 (To-Be state)




#  CAB Submission – Shared Machine Manufacturing Account (`shr-machine-mfg`)

---

##  Title
**Deployment of `shr-machine-mfg` Shared Domain Account – Machine Shop Consolidation**

---

## C – Context (Business & Technical Overview)

This change introduces a centralised, domain-controlled shared account `shr-machine-mfg`, replacing unmanaged local accounts (`CellA`, `CellB`) on five designated manufacturing machines.

**Drivers:**
- Security consolidation
- Auditability
- Account lifecycle governance
- Alignment with identity standards (WF1 domain policy)

---

## R – Risk Assessment (Pre-Change State + Failure Modes)

### Current State:
- Two unmanaged local accounts used inconsistently across five machines.
- No group-based access control.
- No audit trace of file/app usage.
- Access to shared drives and critical apps managed manually.

### Risks Identified:
- Privilege creep via unmanaged local admin rights.
- Difficulty tracking accountability and usage.
- Inconsistent experience for users between machines.
- Compliance failure in terms of password policy enforcement.

---

## A – Action Plan (Implementation Steps)

###  Account & Group Creation
- Create `shr-machine-mfg` AD account with `LogonWorkstations` restriction.
- Create and document four AD security groups:
    - `grp-machine-mfgRO`
    - `grp-machine-mfgRW`
    - `grp-machine-mfgLAC`
    - `grp-machine-mfgRDC`

###  Group Membership Assignment
- Add account to `RW` and `LAC` groups by default.
- Add site admin(s) to `RDC` group for remote access.

###  Workstation Policy Enforcement
- Apply LAC restriction via GPO or local policy.
- Assign RDP rights to `grp-machine-mfgRDC`.
- Remove `CellA` and `CellB` from local admin groups.

###  Network & Drive Validation
- Ensure access to `J:`, `V:`, and `Z:` shares.
- Test SharePoint access to:
    - `/sites/Teamcenter`
    - `/sites/ManufacturingDocs`

###  Application Access Testing
- Confirm access to:
    - Mestec
    - NX
    - Teamcenter
    - Outlook 365
    - Chrome
    - Microsoft Office
- Migrate local files from `CellA`/`CellB` if required.

###  Finalisation
- Disable legacy local accounts.
- Store final credentials in password vault.
- Annotate AD `info` field:
    - Owner
    - Location
    - Rotation schedule (365d)
    - Audit tag

---

## F – Failure Recovery / Reversion Plan

**If failure occurs:**
1. Re-enable `CellA` and `CellB` accounts.
2. Restore local profile folders from backup (if impacted).
3. Temporarily reassign local admin rights if required.
4. Notify service desk to revert `LogonWorkstations` setting.

- **Rollback time:** ~15 minutes per machine
- **Impact:** Minimal if restored same day

---

## T – Testing & Verification Plan

1. Confirm domain login to all five workstations.
2. Validate mapped drive and SharePoint access.
3. Full usage tests:
    - Mestec
    - Teamcenter
    - NX
    - Outlook 365
    - Microsoft Office
4. Final sign-off from site lead.

 UAT log location:  
`/Teams/Manufacturing/MachineShop/UAT-Log.xlsx`

---

##  Implementation Window

- **Preferred:** After hours (17:30–19:00)
- **Fallback:** Early morning (06:00–07:30)

---

##  Reference Codes

| Code                        | Purpose                                  |
|-----------------------------|------------------------------------------|
| `shr-machine-mfg-FR0001-01` | Account creation                         |
| `shr-machine-mfg-FR0021-01` | RO group                                 |
| `shr-machine-mfg-FR0022-01` | RW group                                 |
| `shr-machine-mfg-FR0023-01` | LAC group                                |
| `shr-machine-mfg-FR0024-01` | RDC group                                |
| `shr-machine-mfg-FR0102-01` | LogonWorkstations restriction            |
| `shr-machine-mfg-FR0141-01` | Application access validation            |
| `shr-machine-mfg-FR0321-01` | Internet access confirmation             |
| `shr-machine-mfg-FR0361-01` | Vaulted password & lifecycle policy      |
| `shr-machine-mfg-FR0501-01` | Legacy account disablement               |

---

## Optional Add-ons Available on Request

-  UAT Tracker Excel template
-  AD automation scripts (PowerShell-based)
-  Screenshot placeholders for handover/documentation pack  