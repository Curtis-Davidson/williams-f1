# **SUMMARY — SEQ07 TunnelOps**



- **Purpose:**

  Replace use of the TunnelOps generic account on WT Central Control System (CCT) devices with controlled shared accounts while maintaining 24/7 operational continuity.

- **Machines:**
    - W9336 — WT2 primary CCT control and Test Slate scheduling device
    - W9337 — WT2 preparation and schedule/sequence setup device (RDP access required)
    - W9335 — WT1 primary CCT control device
    - W9326 — WT1 preparation and setup device
    - W9340 — WT4 primary CCT control device
    - W9332 — WT5 primary CCT control device
    - W9334 — Backup CCT device (can replace any of the above)

- **Accounts:**
    - shr-tunops-cct — standard shared account for CCT operation
    - shr-tunops-cctAdm — administrative shared account for CCT systems
    - TunnelOps generic account — retained temporarily for rollback and continuity


- **Software:**
    - Test Slate application (schedule and sequence management)
    - Bespoke WT Central Control applications
    - Embedded MS SQL databases (local to CCT systems)
    - OPC messaging interfaces to other WT systems


- **Key Actions:**
    - Create two CCT shared accounts
    - Restrict logon to named CCT machines only
    - Replace TunnelOps usage on these devices
    - Implement RDP access using machine-specific groups where required
    - Validate end-to-end WT operation before withdrawal of TunnelOps usage

- **Final naming to be confirmed with department.**


------

# **WORKING DOCUMENT — SEQ07**

## **Scope**

- **In scope:**

    - CCT devices listed in this sequence
    - Replacement of TunnelOps generic logon with shared accounts
    - Device-level access control and validation


- **Out of scope:**

    - Full decommissioning of TunnelOps generic account
    - Broader TunnelOps systems outside CCT devices

## **Implementation Steps (authoritative)**

1. **Account creation & attributes**

    - Create shr-tunops-cct

      Description: WT Central Control standard operational shared account.

    - Create shr-tunops-cctAdm

      Description: WT Central Control administrative shared account.

    - “User must change password at next logon” = No.

    - Restrict logon via **User Object → Log On To**:
        - W9336
        - W9337
        - W9335
        - W9326
        - W9340
        - W9332
        - W9334


2. **RDP Access** (where applicable)
    - Device requiring RDP:
        - W9337
    - Create security group RDP_W9337 in OU **Shared Accounts RDP**.
    - Add required users (Wind Tunnel Engineers, Methodology Engineers, WT Systems team as listed in BA).
    - On W9337, add RDP_W9337 to local **Remote Desktop Users**.


3. **Local Permissions / Vendor Requirements**
    - shr-tunops-cct01Adm to be added to local **Administrators** on all CCT devices.
    - No other business groups to be added at this stage.


4. **Software / Configuration**
    - Verify Test Slate application functionality on all applicable devices.
    - Confirm MS SQL components operate under new shared accounts.
    - Confirm OPC messaging continues to function between systems.
    - Confirm schedule and sequence data can be created, edited, loaded, and executed.


5. **Intune / Compliance**

    - Not specified in BA document.


6. **Validation**
    - Logon test using both shared accounts on each device.
    - Test Slate open, schedule creation, sequence execution.
    - Cross-device communication tests (prep → control devices).
    - RDP test to W9337.
    - Confirm TunnelOps generic account still functions during transition.


## **Open Items**
- Confirmation of final account naming suffix with CCT department.
- Confirmation of which users require ongoing RDP access to W9337.
- Confirmation of any undocumented vendor utilities or background services.

## **Discarded Approaches**

- BA proposed extensive AD group-based login control and access modelling.

  → Replaced with project-standard explicit **machine-level “Log On To” restriction** and **machine-specific RDP groups**.


## **Rollback**

- Remove machines from “Log On To” list on shared accounts.
- Revert users to TunnelOps generic account for logon.
- Remove RDP_W9337 from local Remote Desktop Users if required.
- No application rollback required unless functional issues identified.

------

# **CAB DOCUMENT — SEQ07**

## **Change Summary**

- Implement shared account remediation for WT Central Control Systems within TunnelOps using standard machine-restricted access.


## **Business Justification**

- Reduce security exposure from generic account usage.
- Maintain operational continuity of critical Wind Tunnel control systems.
- Introduce controlled, auditable shared access model.


## **Affected Systems**

- **Machines:** W9336, W9337, W9335, W9326, W9340, W9332, W9334
- **Accounts:** shr-tunops-cct, shr-tunops-cctAdm, TunnelOps (temporary)
- **Applications:** Test Slate, bespoke CCT applications, OPC interfaces


## **Risk & Mitigation (practical)**

- **Risk:** Loss of WT functionality under new shared accounts.

    - **Mitigation:** Retain TunnelOps account until full validation completed.


- **Risk:** Inter-system communication failure (OPC / database access).

    - **Mitigation:** Perform staged testing with business teams before progressing.


## **Implementation Plan**

- Execute steps defined in **Working Document — Implementation Steps**.


## **Validation Plan**

- Execute steps defined in **Working Document — Validation**.

## **Backout Plan**

- Execute steps defined in **Working Document — Rollback**.

## **Stakeholders**

- Department owner: Wind Tunnel Systems Manager (Mich Hackwood)
- Implementer: Paul R Davidson (Shared Account Remediation)

------

# **SUPPORT DOCUMENT — SEQ07**


## **Purpose**

- These machines operate and coordinate Wind Tunnel Central Control Systems, including scheduling, sequencing, and live tunnel operation.


## **Day-to-Day Use**

- Used by Wind Tunnel Engineers, Methodology Engineers, and WT Systems team.
- Devices operate 24/7 and support live testing activity.


## **Access**

- Standard operations: shr-tunops-cct
- Administrative tasks: shr-tunops-cctAdm
- RDP access (where required): via RDP_<MACHINE_NAME> group membership.


## **Software Notes**

- Test Slate manages schedules and sequences.
- Embedded SQL databases store operational data.
- OPC messaging enables cross-system coordination.
- Applications are tightly coupled to specialist machinery.

## **Known Paths**

- Network shares:
    - \smb.wf1-isil01.factory.wf1\department2 (mapped T:\ATF)
    - \factory.wf1\DFS2 (mapped P:\WTData\WT2)



- Local paths (device-dependent):
    - C:\Data
    - C:\ExhaustCalibrations
    - C:\Templates
    - C:\Template Macros

    
## **Troubleshooting**

- **Cannot log on:**

  Check “Log On To” includes the specific device hostname.

- **RDP denied:**

  Verify membership in RDP_<MACHINE_NAME> and local Remote Desktop Users.

- **Application failure:**

  Confirm shared account permissions, database access, and restart application.

# **CAB DOCUMENT — SEQ07**


## **Change Summary**

Implement shared account remediation for TunnelOps WT Central Control System (CCT) devices, replacing day-to-day use of the TunnelOps generic account with controlled shared accounts using standard machine-restricted access.

## **Business Justification**

The TunnelOps generic account is currently used across multiple critical WT Central Control devices, creating unnecessary security exposure and lack of access control.

This change introduces controlled shared accounts with explicit machine-level restriction while preserving full operational continuity for Wind Tunnel operations.


## **Affected Systems**

- **Machines:**
    - W9336 — WT2 primary CCT control device
    - W9337 — WT2 preparation / setup device
    - W9335 — WT1 primary CCT control device
    - W9326 — WT1 preparation device
    - W9340 — WT4 primary CCT control device
    - W9332 — WT5 primary CCT control device
    - W9334 — Backup CCT device



- **Accounts:**
    - shr-tunops-cct
    - shr-tunops-cctAdm
    - TunnelOps generic account (retained temporarily for rollback)


- **Applications:**
    - Test Slate (schedule and sequence management)
    - Bespoke WT Central Control applications
    - Embedded MS SQL databases
    - OPC messaging interfaces

## **Risk & Mitigation (practical)**

- **Risk:**

  Loss of functionality under new shared accounts.

  **Mitigation:**

  Retain TunnelOps generic account until full end-to-end validation is completed. Rollback remains immediately available.

- **Risk:**

  Inter-system communication issues (OPC or database access).

  **Mitigation:**

  Perform staged testing with business teams prior to progression.

- **Risk:**

  RDP access failure for preparation devices.

  **Mitigation:**

  Pre-create machine-specific RDP group and validate access before enforcement.


## **Implementation Plan**

Execute the steps defined in the **Working Document — SEQ07 Implementation Steps**, including:

- Creation of shared accounts
- Explicit “Log On To” machine restriction
- Local administrator configuration for admin shared account
- Machine-specific RDP access where required
- Application and operational validation


## **Validation Plan**

Execute the validation steps defined in the **Working Document — SEQ07 Validation**, including:

- Successful logon using shared accounts on all listed devices
- Verification of Test Slate functionality
- Verification of schedule and sequence execution
- RDP connectivity tests (where applicable)
- Confirmation that TunnelOps generic account remains functional during transition

## **Backout Plan**

If any operational issues occur:

- Revert users to TunnelOps generic account
- Remove machine names from shared account “Log On To” restriction
- Remove RDP group from local Remote Desktop Users if required
- No application rollback unless functional defects are identified

## **Stakeholders**

- **Department Owner:**

  Wind Tunnel Systems Manager — Mich Hackwood

- **Implementer:**

  Paul R Davidson (Shared Account Remediation)

----------------------------------------

Below is a **strengthened Implementation Plan block**, still clean and CAB-safe, but now:
- Covers **all required technical items**
- Explicitly allows **new discovery during implementation**
- Protects you from “wasn’t in the BA” arguments
- Keeps rollback authority intact
- Still reads like engineering, not governance fluff

Source remains SEQ07 BA

------

## **Implementation Plan**

1. Create shared Active Directory accounts:
    - shr-tunops-cct (standard operational access)
    - shr-tunops-cctAdm (administrative access)

Add clear descriptive notes identifying business purpose and sponsoring department.

2. Configure account security attributes:
    - Apply strong password in line with organisational policy.
    - Store credentials in the approved IT password vault.
    - Record ownership and reset requirements on the AD user objects.

3. Restrict interactive logon using explicit machine-level control:
    - Configure **AD User Object → “Log On To”** for both shared accounts.
    - Permit access only to:
        - W9336
        - W9337
        - W9335
        - W9326
        - W9340
        - W9332
        - W9334

4. Configure local administrator permissions:
    - Add shr-tunops-cctAdm to the local **Administrators** group on all listed CCT devices.
    - Do not remove or modify the TunnelOps generic account at this stage to preserve rollback capability.

5. Configure Remote Desktop access where required:
    - Identify devices requiring RDP access (currently W9337).
    - For each such device:
        - Create machine-specific security group RDP_<MACHINE_NAME> in OU **Shared Accounts RDP**.
        - Add approved users as required.
        - Add the group to the local **Remote Desktop Users** group on the target device.

6. Configure file system and data access:
    - Validate access to required network shares used by CCT operations.
    - Validate access to required local directories where present.
    - Confirm read/write functionality under both shared accounts.

7. Validate application functionality:
    - Confirm Test Slate and associated bespoke WT Central Control applications function correctly.
    - Validate schedule and sequence creation, editing, loading, and execution.
    - Confirm embedded MS SQL database access operates as expected.

8. Validate inter-system communication:
    - Confirm cross-device data exchange between preparation and control devices.
    - Validate OPC messaging and any dependent background services.

9. Perform staged operational testing with business teams:
    - Physical logon testing on each device.
    - RDP testing where applicable.
    - Verification that systems remain operational during live or simulated tunnel activity.

10. **New discovery handling (controlled):**

    - If additional dependencies, applications, services, permissions, databases, or integrations are identified during implementation:

      - Pause progression at that stage.
      - Validate impact with business and technical owners.
      - Apply only changes required to restore equivalent functionality.
      - Record findings as implementation discovery.

    - Any material scope increase will be assessed before proceeding further.

11. Maintain rollback readiness throughout:

    - TunnelOps generic account remains available during implementation.
    - No irreversible changes applied until functional validation is confirmed.

12. Proceed to next remediation step only after:

    - Business confirmation that operational functionality is unaffected.
    - Agreement that shared account usage is stable for day-to-day operations.

------

This version does three very important things for you:

1. It **covers everything already known**
2. It **explicitly allows unknowns** without breaking CAB
3. It **protects you personally** if something emerges mid-cutover

------------------------------------

## **Backout Plan**

### **Hard Stop Criteria**

Implementation must be **immediately halted** and rollback initiated if **any** of the following occur:
- A shared account is unable to log on to a required CCT device.
- Test Slate or any WT Central Control application fails to launch or operate as expected.
- Schedule or sequence execution is disrupted or behaves unpredictably.
- Inter-system communication (including OPC messaging) fails or produces errors.
- Database access errors occur under either shared account.
- RDP access required for preparation or support activity is unavailable.
- Any condition is identified that could impact live or upcoming Wind Tunnel operations.
- Business users confirm loss of confidence in system stability.

No further changes are permitted once a hard stop condition is reached.

------

### **Backout Actions**

1. Immediately cease further implementation activity.

2. Revert user access back to the TunnelOps generic account for affected devices.

3. Remove machine-level restrictions from shared accounts:

    - Clear affected devices from **AD User Object → “Log On To”** where necessary.

4. Remove machine-specific RDP access:
    - Remove RDP_<MACHINE_NAME> group from local **Remote Desktop Users**.
    - Retain group objects unless explicitly confirmed no longer required.


5. Restore previous operational state:

    - Confirm TunnelOps generic account can log on locally and via RDP (if previously used).
    - Confirm all applications function as they did prior to change.


6. Validate system recovery:

    - Confirm Test Slate operates normally.
    - Confirm schedules and sequences can be executed.
    - Confirm inter-device communication has resumed.

7. Record rollback outcome:

    - Document trigger reason.
    - Document affected device(s).
    - Capture any newly discovered dependencies or constraints for follow-up remediation.

8. Defer further remediation:

    - No additional shared-account changes are to be attempted until issues are analysed and corrective actions agreed with business and technical owners.


------

This backout block is **deliberately strong**.

It gives you:
- Clear authority to stop
- Clear technical reversal steps
- Clear audit narrative
- Zero room for “why didn’t you continue?”

-------------------------------

**high-quality CAB content pack** covering:

- Change Summary
- Business Justification
- Affected Systems
- Risk & Mitigation
- Implementation Overview
- Validation Overview
- Backout Overview

Written so it:
- Reads clean to CAB
- Protects operations
- Protects you
- Aligns with previous SEQs
- Allows discovery without reopening CAB
- Avoids BA fluff completely

Source context: SEQ07 CCT BA

------

# **CAB CONTENT — SEQ07 (TunnelOps CCT)**

## **Change Summary**

Implement shared account remediation for TunnelOps WT Central Control System (CCT) devices by introducing controlled shared accounts with explicit machine-level access restrictions.

This change replaces day-to-day reliance on the TunnelOps generic account on CCT systems while maintaining full operational continuity for live Wind Tunnel activities.

The TunnelOps generic account will be retained temporarily to allow controlled rollback during validation.

------

## **Business Justification**

The TunnelOps generic account is currently used across multiple critical WT Central Control devices, creating:

- Excessive privilege exposure
- Limited traceability of access
- Increased operational and security risk

This change introduces a controlled shared account model that:

- Restricts logon to explicitly approved machines only
- Separates operational and administrative access
- Maintains business continuity for 24/7 Wind Tunnel operations
- Enables safe transition without immediate decommissioning of the generic account

The approach balances security improvement with the critical requirement for uninterrupted Wind Tunnel testing.

------

## **Scope of Change**

### **In Scope**

- WT Central Control (CCT) devices listed in SEQ07
- Introduction of two shared accounts:
    - Operational
    - Administrative
- Explicit machine-level logon restriction
- Controlled RDP access where required
- Validation of applications, databases, and inter-system communication

### **Out of Scope**

- Immediate decommissioning of the TunnelOps generic account
- Changes to non-CCT TunnelOps systems
- Redesign of applications or control systems

------

## **Affected Systems**

### **Devices**

- W9336 — WT2 primary control
- W9337 — WT2 preparation / setup
- W9335 — WT1 primary control
- W9326 — WT1 preparation
- W9340 — WT4 primary control
- W9332 — WT5 primary control
- W9334 — Backup CCT device

### **Accounts**

- shr-tunops-cct
- shr-tunops-cctAdm
- TunnelOps generic account (retained during transition)

### **Applications**

- Test Slate scheduling and sequencing system
- Bespoke WT Central Control applications
- Embedded MS SQL databases
- OPC messaging interfaces

------

## **Risk & Mitigation (Operational)**

### **Risk: Loss of operational functionality**

- **Mitigation:**

  TunnelOps generic account retained until shared accounts are fully validated.

### **Risk: Inter-system communication failure (OPC / database)**

- **Mitigation:**

  Staged testing with business and systems teams prior to progression.

### **Risk: RDP access disruption**

- **Mitigation:**

  Machine-specific RDP groups created and validated before enforcement.

### **Risk: Undiscovered dependencies**

- **Mitigation:**

  Controlled discovery handling built into implementation with hard stop authority.

------

## **Implementation Overview**

Implementation will be performed in a staged manner:

- Shared accounts created and secured
- Explicit machine-level access applied
- Local administrative access configured
- RDP access implemented where required
- Application and system validation performed with business teams

Progression between stages is conditional on successful validation.

No irreversible changes will be applied until operational stability is confirmed.

------

## **Validation Overview**

Validation will include:
- Successful logon testing on all CCT devices
- Verification of Test Slate operation
- Validation of schedule and sequence execution
- Confirmation of database access
- Confirmation of inter-device communication
- RDP testing where applicable
- Business sign-off confirming operational confidence

------

## **Backout Overview**

Rollback can be executed at any point if a hard stop condition is met.

Backout is achieved by:

- Reverting users to the TunnelOps generic account
- Removing machine-level restrictions from shared accounts
- Reinstating previous access model

This ensures immediate restoration of operational capability if required.

------

## **Change Ownership**

- **Business Owner:**

  Wind Tunnel Systems Manager — Mich Hackwood

- **Change Implementation:**

  Paul R Davidson — Shared Account Remediation

------