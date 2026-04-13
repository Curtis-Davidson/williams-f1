# **SUMMARY — SEQ05 TunnelOps**



- **Purpose:**

  Replace use of the legacy TunnelOps generic account on Real Time Controller (RTC) systems with controlled RTC shared accounts, while preserving 24/7 wind tunnel operations and safe rollback.

- **Machines:**
    - **W9338** — WT2 primary RTC controller **Production**
    - **W9338A** — WT2 backup RTC controller **Production**
    - **M9416** — WT2 image capture system **Production**
    - **W9314** — WT2 image capture system (currently faulty) 
    - **W9417** — WT2 image capture system **Production**
    - **W9341** — WT5 (Mobile) RTC host
    - **W9379** — WT2 thermal imaging system **Production**
    - **M3038** — WT2 motion capture monitoring **Production**
    - **W9342** — WT4 (Mobile) RTC controller (**Mobile WT4**)
    - **W9339** — WT1 (Mobile) RTC controller (**Mobile WT5**) **Proceed with migration 1st WT5**
    - **W9324** — RTC software development workstation **OnHold**
    - **W9378** — RTC software development workstation (RDP-only) **StandAlone** shr-tunops-rtc, 23rd Feb 26, Can Start 
Migration.



- **Accounts:**
    - **shr-tunops-rtc** — standard RTC operational access
    - **shr-tunops-rtcAdm** — RTC administrative access
    - TunnelOps generic account retained temporarily for rollback
    - No MFA or Intune status explicitly stated

- **Software:**

    - Bespoke RTC control and monitoring applications
    - Image capture applications
    - Thermal imaging interface software
    - Motion capture monitoring software
    - RTC software development tools
    - OPC / bespoke messaging components
    - No licence dongles identified; licensing tied to specialist machinerycmdslmgr /


- **Key Actions:**

    - Create two RTC shared accounts
    - Restrict logon per machine using AD “Log On To”
    - Implement machine-specific RDP access where required
    - Apply local admin access only via RTC admin account
    - Ensure network and local paths accessible to RTC accounts
    - Validate full operational parity before reducing TunnelOps usage


- **Final naming to be confirmed with department.**

------

# **WORKING DOCUMENT — SEQ05**

## **Scope**

- **In scope:**

  RTC systems supporting WT1, WT2, WT4, WT5 including control, monitoring, imaging, thermal and development workstations.

- **Out of scope:**

    - Immediate decommission of TunnelOps generic account
    - Redesign of bespoke RTC software or OPC architecture
    - Wider TunnelOps systems not listed in this sequence

## **Implementation Steps (authoritative)**

1. **Account creation & attributes**

    - Create **shr-tunops-rtc**

      Description: RTC operational shared account for wind tunnel control and monitoring.

    - Create **shr-tunops-rtcAdm**
      Description: RTC administrative shared account for supported systems.
    - Password policy: annual rotation, stored in IT password vault.

    - Restrict logon via AD User Object → *Log On To*:
        - W9338
        - W9338A
        - M9416
        - W9314
        - W9417
        - W9341
        - W9379
        - M3038
        - W9342
        - W9339
        - W9324
        - W9378


2. **RDP Access (only where applicable)**
    - Devices requiring RDP:
        - W9378 (no keyboard/screen/mouse)
    - Create security group **RDP_W9378** in OU **Shared Accounts RDP**.
    - Add required RTC users.
    - Add **RDP_W9378** to local *Remote Desktop Users* on W9378.

3. **Local Permissions / Vendor Requirements**
    - On all listed devices:

        - Add **shr-tunops-rtc01Adm** to local *Administrators*.
        - No other business accounts added.
        - Do not remove TunnelOps generic account at this stage.

4. **Software / Configuration**
    - Verify all RTC applications operate identically under both RTC shared accounts.
    - Validate bespoke messaging and OPC-dependent processes.
    - Ensure no dependency on TunnelOps profile paths.

5. **Intune / Compliance**
    - Not explicitly stated in BA — confirm with Infrastructure if required.

6. **Validation**
    - Physical logon test with both RTC shared accounts.
    - Confirm inability to log on to non-RTC machines.
    - Validate RDP access on W9378.
    - Confirm application parity versus TunnelOps.
    - Confirm TunnelOps generic account still functions for rollback.

## **Open Items**

- Confirm whether any RTC machines are Intune-managed.
- Confirm whether OPC changes are required before production cutover.
- Confirm long-term timeline for TunnelOps generic account removal.
- Confirm ownership for ongoing RTC password rotation.

## **Discarded Approaches**

- BA proposed multiple layered AD control groups for login and RDP.

  → **Discarded** in favour of project-standard method:

- AD *Log On To* for machine restriction.
- Machine-specific RDP groups only where RDP is required.


## **Rollback**
- Remove machine entries from *Log On To* for RTC accounts.
- Remove RTC admin account from local Administrators.
- Disable or delete RDP_W9378 group if unused.
- Revert users to TunnelOps generic account.

------

# **CAB DOCUMENT — SEQ05**

## **Change Summary**

- Implement RTC shared account remediation for TunnelOps Real Time Controller systems using standard machine-restricted logon and controlled RDP.

## **Business Justification**

- Reduces generic account risk while preserving continuous wind tunnel operation and providing immediate rollback capability.

## **Affected Systems**

- **Machines:** W9338, W9338A, M9416, W9314, W9417, W9341, W9379, M3038, W9342, W9339, W9324, W9378
- **Accounts:** shr-tunops-rtc01, shr-tunops-rtc01Adm
- **Applications:** RTC control, imaging, thermal, motion capture, development and bespoke messaging systems

## **Risk & Mitigation (practical)**

- **Risk:** Some RTC apps may not function under new shared accounts.

    - *Mitigation:* Parallel retention of TunnelOps account until validation complete.

- **Risk:** Messaging or OPC dependencies may fail between systems.

    - *Mitigation:* Validate end-to-end flows before reliance on RTC accounts.

- **Risk:** Access interruption on 24/7 systems.

    - *Mitigation:* Implement sequentially with live testing.

## **Implementation Plan**

- Execute steps defined in **Implementation Steps** in Working Document.

## **Validation Plan**

- Execute steps defined in **Validation** in Working Document.

## **Backout Plan**

- Execute steps defined in **Rollback** in Working Document.

## **Stakeholders (minimal)**

- Department owner: Wind Tunnel Systems (Alex Wibawa / Mich Hackwood)
- Implementer: Curtis-Davidson (Shared Account Remediation)

------

# **SUPPORT DOCUMENT — SEQ05**

## **Purpose**

RTC systems control, monitor and analyse wind tunnel operations including imaging, thermal data and motion capture.

## **Day-to-Day Use**

- Used continuously by Wind Tunnel Systems engineers and operators.
- Multiple users may need concurrent access depending on tunnel activity.

## **Access**

- **Standard operations:** shr-tunops-rtc01
- **Administrative tasks:** shr-tunops-rtc01Adm
- **RDP access:** Controlled per machine via RDP_ group (e.g. RDP_W9378).

## **Software Notes**

- Bespoke RTC applications are tightly coupled to specialist machinery.
- No general internet access required for RTC accounts.
- OPC and internal messaging may be sensitive to account changes.

## **Known Paths**

- Network:
    - \factory.wf1\wf1\department2\ → mapped as T:\
    - \factory.wf1\DFS2 → mapped as P:\WTDATA

- Local (device-dependent):

    - C:_GIT
    - C:\Backup
    - C:\Williams

## **Troubleshooting**

- **Cannot log on:**

  Check AD *Log On To* includes the machine hostname.

- **RDP denied:**

  Confirm membership of RDP_ and local *Remote Desktop Users*.

- **App malfunction:**

  Validate permissions to local and network paths; compare behaviour with TunnelOps account.

- **Operational failure:**

  Roll back immediately to TunnelOps generic account and escalate.


------


# **IMPLEMENTATION — SEQ05 TunnelOps RTC**


## **1. Create Shared Accounts**

Create the following AD users:

- **shr-tunops-rtc**

  Description: RTC operational shared account for wind tunnel control and monitoring.

- **shr-tunops-rtcAdm**

  Description: RTC administrative shared account for RTC systems.

Set for both:
- Password set manually (strong).
- Password expiry: annual.
- Store password in IT password vault.
- Do **not** enable MFA (not specified in BA).
- Do **not** assign mailbox.

------

## **2. Restrict Logon (authoritative control)**

On **both** shared accounts:

AD User → Account → **Log On To**

Add **only** the following machines:
- W9338
- W9338A
- M9416
- W9314
- W9417
- W9341
- W9379
- M3038
- W9342
- W9339
- W9324
- W9378

Result:
- Accounts cannot log on anywhere else.
- No group dependency.
- No GPO complexity.
- This is the control point.

------

## **3. Local Administrator Configuration**

On **each RTC device listed above**:

Local Administrators group must contain:

- **shr-tunops-rtc01Adm**
- DPT admin account(s)

Do **not** remove:

- TunnelOps generic account (yet)

Do **not** add:

- Individual users
- Business groups

Admin access is only via the RTC admin shared account.

------

## **4. RDP Access (only where required)**

### **Device requiring RDP:**

- **W9378** (no keyboard / mouse / screen)

Actions:

1. Create AD security group:

    - **RDP_W9378**
    - Location: **Shared Accounts RDP OU**

2. Add required RTC users to **RDP_W9378**.

3. On W9378:

    - Add **RDP_W9378** to local **Remote Desktop Users**.

No other devices get RDP unless explicitly requested later.

------

## **5. Network & Local Access Validation**

Confirm both RTC shared accounts can access:

### **Network:**

- T:\ATF\03_Maintenance
- T:\ATF\05_Reference
- T:\ATF\07_Software
- T:\ATF\09_Temp
- T:\ATF\10_Perso
- P:\WTDATA

### **Local (where present):**

- C:\_GIT
- C:\Backup
- C:\Williams


No expansion of access beyond this.

------

## **6. Application Validation**

On each RTC device:

- Log in using **shr-tunops-rtc01**
- Confirm RTC apps open and operate normally.

Then:

- Log in using **shr-tunops-rtc01Adm**
- Confirm admin-only functions operate correctly.

Then:

- Log in using **TunnelOps generic account**
- Confirm no regression (rollback safety).

This is mandatory before progressing.

------

## **7. Internet Access**

For both RTC shared accounts:

- No general internet access.

Allowed web access only:

- https://dev.azure.com/F1Technical/
- https://miro.com/

Local admin accounts may retain internet access for support and updates.

------

## **8. Operational Cutover**

Business instruction:

- **Standard use:** shr-tunops-rtc01
- **Admin tasks:** shr-tunops-rtc01Adm

TunnelOps generic account remains available **only** for rollback.

No technical enforcement against TunnelOps yet.

------

## **9. Stop Condition**

If **any** of the following occur:

- App fails
- Messaging breaks
- OPC behaviour changes
- RTC monitoring disrupted

→ Immediately revert to TunnelOps generic account

→ Do not continue remediation

→ Escalate to Wind Tunnel Systems + DPT

------

Every SEQ has proven the same truth: **BA discovery is never complete**. If we don’t explicitly allow for that, you end up firefighting mid-cutover.

Below is a **clean Discovery While Planning section** you can drop straight into every SEQ implementation.

 This protects you operationally.

------

# **DISCOVERY WHILE PLANNING — REQUIRED STEP**

## **Purpose**

During planning and pre-implementation, additional services, applications, scripts, scheduled tasks, or data flows may be discovered that were not captured during BA discovery.

This step ensures no live operational dependency is broken during remediation.

------

## **Discovery Activities (must be performed before implementation)**

### **1. Live Usage Review**

On each in-scope machine:

- Observe active users during operational hours where possible.
- Confirm how the machine is actually used, not how the document says it is used.
- Identify any behaviour that differs from BA description.

Examples:

- Additional apps opened manually
- Command-line tools launched ad-hoc
- Manual restarts required during tunnel runs

------

### **2. Running Processes & Services**

While logged in as TunnelOps (pre-cutover):

- Review running processes.
- Review Windows services.
- Identify any services running under:
    - TunnelOps generic account
    - Local system with TunnelOps-linked resources

Flag:
- Custom services
- Vendor services
- RTC or OPC-related executables
- Anything not clearly OS-native

------

### **3. Scheduled Tasks**

Check Task Scheduler for:

- Tasks running as TunnelOps
- Tasks running under stored credentials
- Tasks tied to scripts, batch files, Python, PowerShell, or executables

These are frequent hidden breakers.

------

### **4. File System Dependencies**

Identify:

- Hard-coded paths under:
    - C:\Users\TunnelOps\
    - Desktop shortcuts pointing to user profile locations
- Config files referencing TunnelOps profile paths
- Logs or temp files writing to restricted directories

These must be accounted for under the RTC shared accounts.

------

### **5. Network & Messaging Dependencies**

Confirm presence of:

- OPC endpoints
- Internal messaging services
- Socket listeners
- Shared folders used as message queues
- Cross-machine polling or heartbeat scripts

Many of these do **not** appear in BA documentation.

------

### **6. Development / Engineering Artefacts**

Especially on:

- W9324
- W9378

Check for:

- Active repositories under C:\_GIT
- Locally built tools used operationally
- Scripts deployed manually to other RTC machines

These frequently represent undocumented production dependencies.

------

### **7. Record Newly Discovered Items**

Any newly identified dependency must be recorded before cutover:

- Application / service name
- Machine(s) involved
- How it is started (manual / service / scheduled task)
- Account context required
- Operational impact if unavailable


These items must be validated under:

- **shr-tunops-rtc01**
- **shr-tunops-rtc01Adm**


Before proceeding.

------


## **Handling Newly Discovered Dependencies**


If a dependency is found:

- **Do not proceed blindly**
- Pause implementation for that machine
- Validate under RTC shared account
- If unresolved:
    - Leave TunnelOps generic account in use
    - Document as follow-up item
    - Resume after confirmation

This prevents silent breakage of live tunnel operations.

------

## **Key Principle**


Discovery does **not** end when the BA document ends.

Reality lives on the machines.

This step exists to acknowledge that reality and protect business continuity.