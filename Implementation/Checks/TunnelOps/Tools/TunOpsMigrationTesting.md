Alright — let’s clarify the scope before I draft the full test matrix.
When you say **“TunOps Migration Testing”**, confirm which phase we’re dealing with:

1. **Pre-Migration Validation** (current TunnelOps environment snapshot, app & data capture)
2. **Clone Validation** (proof on cloned machine before cutover)
3. **Post-Migration Live Testing** (validation under `shr-tunops-*` shared account in production)
4. **Hypercare Observation** (monitoring and validation after live cutover)

If you’re referring to the **post-migration validation for SEQ10 / SEQ12 (TunnelOps shared account migration)**, I’ll structure it accordingly, using your standard format — clean Markdown, rule-compliant, no corporate filler.

Below is the **base TunOps Migration Testing Plan v1.0** assuming this is the **post-migration validation and hypercare** phase for the `shr-tunops` deployment.

------

## TunOps Migration Testing Plan v1.0

### 1. Purpose

To validate full operational continuity of all Tunnel Operations systems, data, and access post-migration to the new shared account structure (`shr-tunops-*`).
Testing confirms that the cloned and migrated machine functions identically to the original, with all domain, application, and telemetry integrations intact.

------

### 2. Test Preparation

**Pre-requisites**

- Confirm machine joined to **FACTORY domain** under correct OU.
- Verify `shr-tunops-*` credentials and `Log On To` restrictions applied correctly.
- Ensure **local admin elevation** present for required COM/serial test apps.
- Confirm all mapped drives, shares, and telemetry paths accessible.
- Verify Aero network connectivity and telemetry relay paths (Wind Tunnel > Aero Cluster).
- Confirm local SQL/SQLite caches backed up before validation.

------

### 3. Application Validation

| Application                                                  | Validation Focus                                             |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **WTTP – Wind Tunnel Test Planner**                          | Verify all session configurations, test queue loading, and data write-back to central storage. |
| **AeroView**                                                 | Confirm model telemetry feed, live view connectivity, and model update synchronisation. |
| **Aero Manager**                                             | Check local DB link, machine registry paths, and stored test setups. |
| **M-Part**                                                   | Validate part tracking, reference links, and local sync operations. |
| **NX / TeamCentre**                                          | Confirm user profile load, cached assemblies open correctly, and mapped drives resolve. |
| **PowerApps / OneNote / Teams**                              | Check sign-in persistence, OneNote cache binding, and Teams channel file continuity. |
| **MovieViewer / CamMan / Competitor Analysis / T3 / TappingPublisher / Remote Jobs / One Click Export / AeroIntranet** | Validate launch success, data access, and production path linkage. |

------

### 4. Hardware and Peripheral Validation

| Hardware                                  | Validation Steps                                             |
| ----------------------------------------- | ------------------------------------------------------------ |
| **COM/USB Devices**                       | Verify device enumeration under Device Manager; confirm telemetry sensors detected. |
| **Cameras (IDS uEye / GigE)**             | Confirm live video feed and calibration modules launch.      |
| **Laser alignment / measurement devices** | Confirm driver-level access and calibration script execution. |
| **Local printers / plotters**             | Print test page via shared account context.                  |
| **Storage mounts (NAS, local ZFS share)** | Validate read/write and version path mapping.                |

------

### 5. Network & Security Validation

- Test domain policy enforcement (`gpresult /r`) for correct OU and GPOs.
- Validate FortiGate rules and proxy allowances remain consistent with previous account.
- Confirm MFA and Keeper access functional if required.
- Check RDP access via machine-specific Remote Desktop group (`shr-tunops-rdp-*`).
- Run latency test to Aero cluster (`ping`, `iperf3`) to confirm throughput unchanged.

------

### 6. Rollback / Reversion Plan

- **Option 1:** Restore original disk image (client disk retained).
- **Option 2:** Revert to pre-migration profile (local backup of user data and configs).
- **Option 3:** Boot from clone and reapply validated `shr-tunops` account config.

Rollback window: 30 minutes max for profile swap; 90 minutes for full image restore.

------

### 7. Hypercare Observation (48 hours)

**Metrics to monitor:**

- App launch latency (WTTP / AeroView / NX)
- Network throughput stability (Aero telemetry feed)
- Local cache regeneration success
- Any user reports of access denials or missing data

Hypercare sign-off after 48 hours of error-free operation.

------

### 8. Expected Result

All applications, telemetry devices, and storage paths function identically to pre-migration baseline.
No loss of data, configuration, or access.
Shared account (`shr-tunops-*`) proven stable and production-ready.

------

Would you like me to generate the **exact command/test sheet** next — including PowerShell commands, log paths, and verification outputs (Rule 6 format: file paths, test commands, expected output)?
That turns this into a copy-paste-ready validation runbook for SEQ10 hypercare.