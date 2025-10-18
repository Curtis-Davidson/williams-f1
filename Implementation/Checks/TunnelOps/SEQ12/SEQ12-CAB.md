# **CAB DOCUMENT — SEQ12: TunnelOps WTA Shared Account Implementation (Final + PowerShell Integration)**

## **Change Summary**

Implement secure, traceable shared accounts for the Wind Tunnel Test Monitoring workstation (M3164) in TunnelOps.
This includes the creation of `shr-tunops-wta` and `shr-tunops-wtaAdm` accounts, application of direct logon restriction via **AD user object**, and execution of a **PowerShell-based migration** tested externally on a cloned NVMe disk.
Associated AD groups were BA recommendations only; implementation uses direct object control and existing TunnelOps group memberships.

------

## **Business Justification**

Legacy generic logins lack accountability and risk profile corruption during operational use.
This controlled migration introduces shared accounts with direct AD logon enforcement and uses a **PowerShell-driven migration process** to safely replicate and rebind all user profiles, paths, and application dependencies in an isolated test environment before live cutover.

------

## **Affected Systems**

- **Machine:** `M3164` (WT2 Control Room – Wind Tunnel Test Monitoring)

- **Accounts:**

    - `shr-tunops-wta` – standard shared account
    - `shr-tunops-wtaAdm` – administrative account

- **AD Groups (Discovery Only):**

    - `grp-tunops-wtaRW`, `grp-tunops-wtaRO`, `grp-tunops-wtaLAC`, `grp-tunops-wtaAdm`, `grp-tunops-wtaRDC`
      *(RW/RO groups only created if externally required; LAC not used — logon restriction applied directly.)*

- **Applications:**

    - WTTP, AeroView, Aero Manager, M-Part, NX, TeamCentre, PowerApps, OneNote, CamMan, MovieViewer, MS Office, Adobe Acrobat, VLC

-

- | No.  | Shortcut / Label            | Application Name                   | Description / Function                                       |
    | ---- | --------------------------- | ---------------------------------- | ------------------------------------------------------------ |
  | 1    | Launch **PowerpointExtent** | *PowerPoint Extension Tool*        | Custom integration or extension utility for Microsoft PowerPoint presentations. |
  | 2    | Launch **MovieViewer**      | *MovieViewer*                      | Bespoke Williams application for reviewing tunnel test video data or visual analysis sequences. |
  | 3    | Launch **mPART**            | *M-Part System*                    | Model parts tracking application linking components used in wind tunnel tests to part databases. |
  | 4    | Launch **PTT**              | *PTT (Project/Part Tracking Tool)* | Internal tracking system for projects or part workflow data. |
  | 5    | Launch **T3**               | *T3 Application*                   | Engineering utility likely associated with aerodynamic test data or tunnel scheduling. |
  | 6    | Launch **TappingPublisher** | *Tapping Publisher*                | Tool used for publishing or uploading pressure tapping data or measurement results. |
  | 7    | Launch **WTTP**             | *Wind Tunnel Test Planner*         | Core Wind Tunnel Test Planning and monitoring system used during live tests. |
  | 8    | **Competitor Analysis**     | *Competitor Analysis Tool*         | Application used for comparing external aerodynamic data, images, or performance figures. |
  | 9    | Launch **Remote Jobs**      | *Remote Jobs Utility*              | Interface for monitoring or triggering remote aerodynamic computation jobs. |
  | 10   | Launch **One Click Export** | *Data Export Utility*              | Automated data export tool for results and simulation outputs. |
  | 11   | Launch **Level 2**          | *Level 2 Utility*                  | Secondary analysis or internal tooling layer for tunnel or aerodynamic results. |
  | 12   | Launch **Jupyter**          | *Jupyter Notebook*                 | Data science and analysis interface used for Python-based aerodynamic analytics. |
  | 13   | Launch **AeroIntranet**     | *Aero Intranet Portal*             | Internal SharePoint/Intranet portal for Aerodynamics department documents and links. |

------

## **Risk & Mitigation (Practical)**

| Risk                      | Impact                             | Mitigation                                                   |
| ------------------------- | ---------------------------------- | ------------------------------------------------------------ |
| Profile migration error   | App paths or registry entries lost | PowerShell scripts handle automated path mapping, rights preservation, and registry replication with controlled logging. |
| AD group drift            | Misalignment of privileges         | Maintain existing TunnelOps groups; only add RW/RO if required. |
| Lockdown misconfiguration | Logon denied                       | Use **user object “Log On To”** method, not group enforcement. |
| Production impact         | System instability                 | All migration and testing occur on cloned disk externally.   |
| Rollback delay            | Downtime                           | Physical NVMe swap — rollback in under 5 minutes.            |

------

## **Implementation Plan**

### **1. Account and Access Control**

- Create `shr-tunops-wta` and `shr-tunops-wtaAdm`.
- Apply **“Log On To”** restriction via AD User Object (direct, no LAC group).
- Retain existing TunnelOps group membership for access continuity.
- RW/RO groups to be created only if later dependencies require it.

------

### **2. Software and Configuration Validation**

- Verify mapped drives (`P:\`, `T:\`), SharePoint, and OneNote paths.
- Confirm application launch integrity and registry bindings for NX, Aero Manager, and PowerApps.
- Validate Teams sync and OneDrive rebind under new profiles.

------

### **3. Clone-Based Migration and PowerShell Profile Automation**

**Purpose**
Ensure the entire migration is tested off-system using cloned NVMe disks, with all profile, app, and permission replication handled via PowerShell scripting.

**Hardware and Tools**

- **Sonnet Low-Profile PCIe Card** (dual M.2 NVMe slots) — chosen for its high cloning speed and reliability.
- **Acronis Disk Image 25** — used for capturing and verifying full disk images.
- **Dell Precision workstation** — external validation host.
- **Custom PowerShell scripts** — automate profile migration, path copying, registry rebinding, and OneNote/Teams cache relocation.

**Process Overview**

1. Clone M3164 production NVMe disk to secondary drive using the Sonnet PCIe card.
2. Boot the clone in the validation workstation.
3. Execute PowerShell scripts to:
    - Copy user profiles from legacy TunnelOps account to new WTA accounts.
    - Remap local and network paths, including `P:\`, `T:\`, SharePoint sync roots, and cached OneNote data.
    - Preserve NTFS rights and local registry keys for installed applications.
    - Verify all environment variables and user shell folders resolve correctly.
4. Validate application behaviour under both WTA accounts.
5. Refine scripts for portability and repeatability across SEQ13–SEQ15.
6. Once validated, perform cutover by inserting the cloned, proven NVMe disk back into M3164 (03:00–06:00 maintenance window).
7. Retain the original production disk for rollback.

------

### **4. Teams Integration**

- Dedicated **Microsoft Teams workspace** maintained under `shr-tunops-wta`.
- Teams remains the live coordination tool between TunnelOps and Aerodynamics teams.
- Validation includes persistence of channels, files, OneNote notebooks, and chat continuity.

------

### **5. Known Paths**

- **Network Drives:**
    - `P:\` → `\\factory.wf1\DFS2`
    - `T:\` → `\\factory.wf1\wf1\Department2`
- **Local Working Directories:**
    - `C:\Users\TunnelOps\WilliamsF1\Aerodynamics Department - FW48 Development\02 WT Sessions\25WT42-48`
    - `C:\Users\TunnelOps\WilliamsF1\Aerodynamics Department - 24J43-47`
    - `C:\Users\TunnelOps\WilliamsF1\Aerodynamics Department - Reference library`
- **SharePoint Library:**
    - `Aero Documents Library → 03_AeroDevelopment → 2025 → FW48 Development`
        - `01 Regulation`
        - `02 WT Sessions`
        - `03 Aero Teams`
        - `04 Fangio TD047`
        - `05 General`
- **Database Connection:**
    - `Aeroprodsql, 59112`

------

## **Validation & Test Plan**

### **Pre-Cutover Validation (on Clone)**

1. Boot cloned disk on validation machine.
2. Run PowerShell migration scripts; confirm all logs output successfully.
3. Log in as `shr-tunops-wta` and `shr-tunops-wtaAdm`.
4. Validate:
    - App registry integrity
    - Mapped drives and OneNote functionality
    - Teams sign-in, channel sync, and file persistence
5. Confirm all expected directories and environment variables correctly align.
6. Sign off clone readiness before physical cutover.

### **Cutover Validation**

1. Insert validated cloned disk into M3164.
2. Verify boot success and user profile integrity.
3. Validate application runtime and network paths.
4. Confirm Aero RDP/VNC connections and Teams collaboration in real time.
5. Capture screenshots, event logs, and PowerShell transcript output for CAB evidence.

### **Post-Cutover Monitoring**

- Monitor application logs and AD sync for 48 hours.
- Confirm PowerShell migration audit logs archived in CAB folder.
- Retain original disk off-site as immutable rollback baseline.

------

## **Rollback Plan**

- **Immediate rollback** via physical reinsertion of the original NVMe disk (no imaging or restore delay).
- Revert user logon control to legacy TunnelOps account if needed.
- Retain PowerShell migration logs to refine scripts before reattempt.
- Notify Aero IT and Security teams once rollback verified stable.

------

## **Stakeholders**

- **Requestor / Owner:** Duncan Barr – Principal Aero Engineer
- **Implementer:** Curtis-Davidson – Shared Account Remediation
- **Approvers:** Mike Smith (IT Support Manager), Chris Hicks (Information Security Engineer)

------

## **Appendix A – Clone-Based Migration and PowerShell Scripting Process**

### **Overview**

The migration process uses a **hardware clone + PowerShell automation model**.
All work is conducted on a cloned NVMe disk outside of the production system, ensuring operational safety, reproducibility, and full rollback capability.

### **Technical Summary**

| Item                | Detail                                                       |
| ------------------- | ------------------------------------------------------------ |
| **Hardware**        | Sonnet Low-Profile PCIe (Dual M.2 NVMe)                      |
| **Software**        | Acronis Disk Image 25 + Custom PowerShell Scripts            |
| **Access Control**  | Direct “Log On To” restriction via AD user object            |
| **Profiles**        | Migrated using PowerShell for accuracy and rights preservation |
| **Rollback**        | Physical NVMe swap (<5 min)                                  |
| **Validation Host** | Dell Precision workstation (isolated)                        |

### **PowerShell Automation Scope**

- Copy and remap all user profile directories to new WTA accounts.
- Preserve ACLs, NTFS rights, and registry keys.
- Rebind local app configs (NX, M-Part, PowerApps).
- Reconnect OneNote and Teams caches to correct user SID paths.
- Export migration logs and verification checksums for CAB evidence.

### **Cutover Window**

- **Scheduled:** 03:00–06:00 (Tunnel inactive)
- **Rollback:** Instant via disk swap

### **Benefits**

- No production interference.
- Fully scripted, reproducible migration process.
- Physical rollback available instantly.
- Establishes standardised migration pattern for future SEQs.

------