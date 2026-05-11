# **CAB DOCUMENT — SEQ03**

## **Change Summary**

Implement Shared Account Remediation for TunnelOps Particle Image Velocimetry (PIV) systems using a single operational shared account, controlled machine-level logon restrictions, standardised Wind Tunnel RDP access grouping, scoped filesystem permissions, and local administrator access aligned to the agreed implementation approach.

------

## **Business Justification**

Replace operational use of the TunnelOps generic account on PIV systems with a dedicated shared account to improve accountability, standardise access management, and reduce dependency on the legacy generic account while maintaining operational continuity for critical Wind Tunnel PIV systems.

The TunnelOps generic account will remain available during transition and validation phases to support rollback if required.

------

## **Affected Systems**

### **Machines**

- W10172
- W10173
- W10174
- WT2-ILA01
- WT2-ILA02
- WT2-ILA03
- WT2-ILA04
- WT2-ILA05
- WT2PIV3
- WT2PIV4
- WT2PIV5

### **Accounts**

- shr-tunops-piv
- TunnelOps (retained temporarily for rollback)

### **AD Groups**

- WT_RDP

### **Applications**

- ILA_5150
- DaVis
- LaVision
- OPC messaging interfaces
- PIV acquisition, processing and analysis applications

------

## **Risk & Mitigation (practical)**

### **Risk**

Loss of operational capability following migration from TunnelOps account.

#### **Mitigation**

Retain TunnelOps account throughout implementation and validation period.

------

### **Risk**

PIV applications or OPC integrations fail under the new shared account.

#### **Mitigation**

Perform staged UAT validation with Wind Tunnel Systems and Methodology teams before operational sign-off.

------

### **Risk**

Filesystem or application permissions incomplete.

#### **Mitigation**

Validate all local paths, mapped drives, network shares and operational workflows prior to cutover acceptance.

------

### **Risk**

RDP access failure.

#### **Mitigation**

Pre-create WT_RDP group membership and validate Remote Desktop Users group membership on all target devices.

------

## **Implementation Plan**

### **Phase 1 — AD Shared Account Preparation**

1. Create AD shared account:
    - `shr-tunops-piv`
2. Configure:
    - Strong password aligned to organisational policy
    - Annual password rotation
    - Password stored in approved password vault
3. Update AD account notes:
    - Business owner
    - Password rotation requirement
    - Password vault update requirement
    - Operational purpose

------

### **Phase 2 — Logon Restriction Configuration**

Apply AD User Object → “Log On To” restriction for:

- `shr-tunops-piv`

#### **Allowed Devices**

- W10172
- W10173
- W10174
- WT2-ILA01
- WT2-ILA02
- WT2-ILA03
- WT2-ILA04
- WT2-ILA05
- WT2PIV3
- WT2PIV4
- WT2PIV5

------

### **Phase 3 — RDP Configuration**

1. Create AD security group:
    - `WT_RDP`
2. Add users:
    - Anna Perry
    - Calum Maciver
    - Conor Crickmore
    - Mich Hackwood
3. Add devices:
    - W10172
    - W10173
    - W10174
    - WT2-ILA01
    - WT2-ILA02
    - WT2-ILA03
    - WT2-ILA04
    - WT2-ILA05
    - WT2PIV3
    - WT2PIV4
    - WT2PIV5
4. Add `WT_RDP` to:
    - Local “Remote Desktop Users” group on all target devices

------

### **Phase 4 — Filesystem Permission Configuration**

#### **Network Shares**

Grant RW access for `shr-tunops-piv` to:

- `\\factory.wf1\wf1\department2\ATF\02_Development\Facilities\WT2\PIV`
- `\\factory.wf1\wf1\department2\ATF\02_Development\Methodology\PIV`
- `\\factory.wf1\wf1\PIVData`

#### **Mapped Drive**

- `T:\ -> \\factory.wf1\wf1\department2\`

------

### **Phase 5 — Local Disk Permissions**

#### **Acquisition Systems**

(W10172/W10173/W10174)

Grant access to:

- `C:\iLA_5150`
- `C:\ProgramData\ILA_5150`
- `D:\`

------

#### **Processing Nodes**

(WT2-ILA01–05)

Grant access to:

- `C:\iLA_5150`
- `C:\ProgramData\ILA_5150`
- `D:\`
- `E:\`

------

#### **Analysis Systems**

(WT2PIV3–5)

Grant access to:

- `C:\ProgramData\LaVision`
- `C:\ProgramData\LaVision GmbH`
- `C:\DaVis*`
- `C:\PIVData`
- `C:\PIVView`

------

### **Phase 6 — Local Administrator Configuration**

1. Add to local Administrators group:
    - `shr-tunops-piv`
2. Retain:
    - Existing DPT administration access
    - Existing TunnelOps account during transition phase
3. Remove:
    - Aero Local Administrators group where specified in the sequence

------

### **Phase 7 — Validation & UAT**

Validate:

- Physical login
- RDP login
- RW filesystem access
- Application functionality
- OPC messaging continuity
- Existing operational workflows
- TunnelOps rollback capability

Validation to be performed jointly with:

- Wind Tunnel Systems
- Methodology Engineers
- DPT Support

------

## **Validation Plan**

1. Confirm:
    - `shr-tunops-piv` login succeeds on all target systems
2. Confirm:
    - RDP access succeeds via `WT_RDP`
3. Confirm:
    - RW access to all required network shares and local paths
4. Confirm:
    - All PIV applications function normally
5. Confirm:
    - OPC messaging and processing workflows operate correctly
6. Confirm:
    - TunnelOps account still functions during rollback phase
7. Confirm:
    - No impact to business continuity operations

------

## **Backout Plan**

1. Revert users to TunnelOps account usage.
2. Remove:
    - Logon restrictions
    - WT_RDP membership/configuration
    - Shared account local administrator membership
    - Filesystem ACL changes if required
3. Restore:
    - Previous local administrator memberships where applicable
4. Validate:
    - TunnelOps operational functionality restored
5. Suspend further implementation until root cause analysis completed.

------

## **Stakeholders (minimal)**

### **Requestors / Business Owners**

- Mich Hackwood — Wind Tunnel Systems Manager
- Anna Perry — Wind Tunnel Support Engineer
- Calum Maciver — Wind Tunnel Support Engineer

### **Implementer**

- Paul Davidson (Shared Account Remediation)