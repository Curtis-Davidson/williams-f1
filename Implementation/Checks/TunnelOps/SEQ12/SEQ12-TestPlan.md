# **Implementation Test Plan — SEQ12 TunnelOps WTA Migration**

## **1. Objective**

To confirm that the migration of TunnelOps workstation M3164 to the new shared accounts (`shr-tunops-wta`, `shr-tunops-wtaAdm`) performs identically to the legacy setup — with all profiles, mapped paths, applications, and collaboration tools fully functional — before go-live.

------

## **2. Test Environment**

- **Hardware:** Dell Precision workstation (validation host)
- **Source Disk:** Original M3164 production NVMe
- **Clone Disk:** Validated Sonnet PCIe dual-NVMe drive
- **Software Tools:**
    - Acronis Disk Image 25
    - PowerShell Migration Scripts (Profile + Path + Registry Uplift)
    - Standard TunnelOps software suite (WTTP, AeroView, Aero Manager, NX, M-Part, TeamCentre, PowerApps, OneNote, Teams)

------

## **3. Pre-Test Checks**

| Step | Description                                                  | Expected Result                                           |
| ---- | ------------------------------------------------------------ | --------------------------------------------------------- |
| 1    | Confirm cloned disk boots successfully in validation workstation. | Windows loads without error; identical environment.       |
| 2    | Verify network drives `P:\` and `T:\` map correctly.         | Drive letters resolve; content matches production.        |
| 3    | Run PowerShell migration scripts with logging enabled.       | Script executes cleanly; migration.log created.           |
| 4    | Check registry and profile SID mapping for new shared accounts. | SID paths reflect `shr-tunops-wta` / `shr-tunops-wtaAdm`. |

------

## **4. Functional Test Matrix**

### **4.1 Application Validation**

| Application                   | Test Action                                                  | Expected Outcome                                            |
| ----------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- |
| **WTTP**                      | Launch app under `shr-tunops-wta`; verify connection to live tunnel feed. | WTTP connects; telemetry visible; no permissions prompt.    |
| **AeroView / Aero Manager**   | Open project set, load current model configuration.          | Model data accessible; no path or permission errors.        |
| **NX / TeamCentre**           | Launch CAD suite; open sample part from mapped drive.        | Opens successfully; TeamCentre sync functional.             |
| **M-Part**                    | Run test calculation.                                        | Output saved correctly to `T:\` workspace.                  |
| **PowerApps / Power BI**      | Validate login, data connection to Aerodynamics workspace.   | No authentication or token errors.                          |
| **OneNote**                   | Open local cache; confirm notebooks sync to SharePoint.      | All pages load; edits sync.                                 |
| **Teams**                     | Join existing channel meeting; test file upload.             | Call audio/video functional; file saved to correct channel. |
| **CamMan / MovieViewer**      | Load and play captured wind tunnel session video.            | Playback smooth; network path accessible.                   |
| **MS Office / Acrobat / VLC** | Open standard documents and videos.                          | Files open; save and print functions work.                  |

------

### **4.2 Profile and Rights Validation**

| Check                      | Method                                           | Success Criteria                         |
| -------------------------- | ------------------------------------------------ | ---------------------------------------- |
| NTFS rights                | Compare ACLs before/after migration.             | All inherited rights identical.          |
| Registry keys              | Run `reg export` comparison pre/post migration.  | No missing keys in application branches. |
| Environment variables      | Run PowerShell `Get-ChildItem Env:` and compare. | Values identical across accounts.        |
| OneDrive / SharePoint sync | Validate sync status icons.                      | Green tick; all files current.           |

------

### **4.3 Collaboration and Remote Access**

| Function             | Test                            | Expected Result                  |
| -------------------- | ------------------------------- | -------------------------------- |
| Teams channel chat   | Send message to Aero engineers. | Immediate delivery and response. |
| File share via Teams | Upload tunnel report PDF.       | File visible to both sides.      |
| RDP access           | Connect from Aero Building.     | Login accepted; session stable.  |
| VNC access (if used) | Observe active tunnel session.  | Visual feed established; no lag. |

------

## **5. Cutover Test Plan (03:00–06:00 Window)**

| Step | Description                                   | Pass Criteria                                         |
| ---- | --------------------------------------------- | ----------------------------------------------------- |
| 1    | Power down M3164; swap validated cloned NVMe. | BIOS detects drive; boots to Windows.                 |
| 2    | Log in with `shr-tunops-wta`.                 | Successful login; no policy errors.                   |
| 3    | Launch all primary applications.              | No launch errors; runtime stable.                     |
| 4    | Confirm network paths, OneNote, Teams.        | Identical to validation results.                      |
| 5    | Capture screenshots and event logs.           | Saved to `\\factory.wf1\DFS2\CAB\SEQ12\TestEvidence`. |

------

## **6. Post-Cutover Monitoring**

- Duration: **48 hours** continuous observation.
- Monitor:
    - AD sync and Intune compliance
    - Teams and OneNote cache integrity
    - App performance logs (WTTP, NX, Aero Manager)
- Record any anomalies in `PostCutover_Log.txt`.

------

## **7. Acceptance Criteria**

- All test steps pass without functional degradation.
- PowerShell migration logs verified clean (no skipped objects).
- Teams and OneNote fully operational under new profile.
- Remote access (RDP/VNC) functional.
- Rollback NVMe confirmed bootable and stored securely.
- CAB evidence pack compiled and archived.

------

## **8. Rollback Verification**

- Physically re-insert original NVMe disk.
- Confirm M3164 boots to legacy environment.
- Validate data and app functionality intact.
- Log rollback confirmation to CAB record.

------

## **9. Deliverables**

- `Migration_Scripts.log` (PowerShell transcript)
- `Validation_Results.xlsx` (Test Matrix outcomes)
- `PostCutover_Log.txt`
- Screenshots of app validation
- CAB approval sign-off