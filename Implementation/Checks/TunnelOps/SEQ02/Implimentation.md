## Implementation Plan — SEQ02 TunnelOps (MTS Systems)

------

### 1. **Preparation & Pre-Checks**

- Confirm device list:
    - M10501, M10502, M10503, M10504, W9343, W9309, W9321
- Confirm user access list with:
    - Mich Hackwood (owner)
    - Anna Perry (methodology POC)
- Verify TunnelOps account is fully functional (baseline for rollback)
- Identify OPC clients/servers on each device for later validation

------

### 2. **Create Shared Account**

- Create AD user:
    - `shr-tunops-mts`
- Set:
    - Strong password (policy compliant)
    - Store in approved password vault "Keeper"
- Add description:
    - “MTS Rolling Road & Model Motion Systems access”
- Ensure:
    - Standard user permissions (Requires local Administrator Membership)

------

### 3. **Apply Logon Restriction (Project Standard)**

- Configure AD User Object → **Log On To**
- Add:
    - M10501
    - M10502
    - M10503
    - M10504
    - W9343
    - W9309
    - W9321
- Validate restriction before proceeding

------

### 4. **Configure RDP Access**

- Create groups in OU **Shared Accounts RDP**:
    - RDP_M10501
    - RDP_M10502
    - RDP_M10503
    - RDP_M10504
    - RDP_W9343
    - RDP_W9309
    - RDP_W9321
- Add approved users (engineers + systems teams)
- On each device:
    - Add `RDP_<MACHINE>` group to local **Remote Desktop Users**
- Confirm:
    - W9321 accessible via RDP only

------

### 5. **Configure Disk Access**

- Grant required RW access to:
    - `\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS`
- Validate access to local paths (where present):
    - C:\MTS
    - C:\MTS_bin
    - C:\MTS_user
    - C:\MTS Geo File

------

### 6. **Validate Application Access**

- Log in using `shr-tunops-mts` on each device
- Confirm:
    - Rolling Road System operates correctly
    - Model Motion System operates correctly
    - Comms systems (W9343/W9309) functioning
    - Temperature control (W9321) functioning
- Ensure:
    - No dependency on TunnelOps credentials

------

#### 6.1 Application Launch & Runtime Context

- Launch all MTS applications on each device
- Confirm:
    - Applications start without error
    - No credential prompts referencing TunnelOps
    - No missing profile/config issues
- Validate no dependency on:
    - `C:\Users\TunnelOps\...`
    - Cached credentials
    - User-specific environment variables

------

#### 6.2 Hardcoded Paths & Configuration Validation

- Review application configs where accessible
- Check for:
    - Hardcoded paths referencing TunnelOps profile
    - Incorrect or legacy UNC paths
- Validate access to:
    - C:\MTS
    - C:\MTS_bin
    - C:\MTS_user
    - C:\MTS Geo File
    - `\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS`
- Confirm:
    - Read / Write access
    - No access denied or silent failures

------

#### 6.3 Data Function Validation

- Execute normal workflows (RRS / MMS)
- Confirm:
    - Data is created, updated, and consumed correctly
    - No backlog or stuck files
    - No failures writing to disk
- Validate:
    - Logs generated correctly
    - Output data consistent with baseline

------

#### 6.4 Service & Background Process Validation

- Check:

  ```
  services.msc
  ```

- Confirm:

    - All required services are running
    - No service failures post-login switch

- If service identity changed:

    - Confirm successful start
    - Confirm dependent apps function

------

#### 6.5 Scheduled Task Validation

- Check:

  ```
  taskschd.msc
  ```

- Run tasks manually

- Confirm:

    - Successful execution
    - No credential or permission errors
    - Expected outputs generated

------

#### 6.6 OPC Connectivity & Function Validation (Integrated)

- Launch OPC test client / TestSlate
- Validate:
    - Connection to all OPC servers
    - Tag browsing works
    - Live values update correctly
    - No “OPC inactive” state
- Perform write test (if safe):
    - Confirm response from system

------

#### 6.7 Cross-System Messaging Validation

- Validate flows:
    - Apps → OPC → Machinery
    - Machinery → OPC → Apps
- Confirm:
    - Real-time updates
    - No dropped messages
    - No latency introduced

------

#### 6.8 Device-Specific Validation

**Rolling Road (M10502 / M10501)**

- Confirm full operational control
- Validate output consistency

**Model Motion (M10504 / M10503)**

- Confirm motion control functionality
- No command failures

**Comms Systems (W9343 / W9309)**

- Confirm stable system messaging
- No relay interruption

**Temperature Control (W9321)**

- Validate via RDP
- Confirm stable session and control

------

#### 6.9 Error & Log Review

- Review:
    - Application logs
    - Windows Event Viewer
- Check for:
    - Access denied
    - OPC errors
    - Service failures

------

#### 6.10 Regression Check vs TunnelOps

- Compare behaviour with TunnelOps baseline
- Confirm:
    - No functional difference
    - No degraded performance
    - No missing capability

------

### 7. **OPC Validation (Critical Step)**

- Using OPC test tools / TestSlate:
    - Connect to all OPC servers
    - Browse and read live tags
    - Perform write test where safe
- Validate:
    - Data flow between systems and machinery
    - No “OPC inactive” or permission errors
- Confirm:
    - Cross-system messaging intact

------

### 8. **RDP & Access Validation**

- Test RDP access using authorised users
- Confirm access denied for unauthorised users
- Validate login works only on in-scope machines

------

### 9. **Failover Validation**

- Validate backup operation via IP swap:
    - M10502 ↔ M10501
    - M10504 ↔ M10503
    - W9343 ↔ W9309
- Confirm:
    - No loss of control or communication

------

### 10. **Business User Validation (UAT)**

- Conduct live validation with:
    - Wind Tunnel Engineers
    - Methodology Engineers
    - Wind Tunnel Systems team
- Confirm:
    - All operational workflows function as expected

------

### 11. **Transition to Shared Account**

- Instruct users:
    - Use `shr-tunops-mts` for all MTS device access
- Monitor:
    - System behaviour
    - User feedback
    - Access / application issues

------

### 12. **Post-Implementation Monitoring**

- Maintain TunnelOps account during hypercare period
- Track:
    - OPC behaviour
    - Application errors
    - Access issues
- Log and escalate any defects

------

This is now: