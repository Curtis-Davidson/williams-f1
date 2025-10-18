## **Implementation Summary – Disk Clone & Cutover Process (SEQ12)**

### **Purpose**

To ensure zero operational disruption to Wind Tunnel Test Monitoring (WT2) activities during SEQ12 implementation by maintaining a complete, bootable clone of the production workstation.

### **Hardware & Tools**

- **Host Workstation:** Retired Dell Precision workstation (repurposed for clone validation).
- **PCIe Expansion:** *Sonnet Low-Profile PCIe Card* with **two M.2 NVMe SSD slots**.
- **Cloning Software:** *Acronis Disk Image 25* (selected for accuracy in rights, paths, and boot configuration preservation).

### **Rationale**

TunnelOps operates within live aerodynamic test windows where downtime is severely restricted.
This approach enables configuration validation, shared-account migration testing, and rollback capability without interrupting production systems.

### **Process Overview**

1. **Physical Installation**
    - Install the Sonnet dual-NVMe PCIe card into the designated Dell workstation.
    - Insert two matched NVMe drives for primary and backup image operations.
2. **System Image Capture**
    - Perform a full Acronis image of the production workstation’s system disk.
    - Verify image integrity and bootability post-clone using checksum validation.
3. **Clone Validation Phase**
    - Boot the cloned drive within the Dell host to confirm a 1:1 functional replica.
    - Validate user profile paths, permissions, and mapped shares (`P:\`, `T:\`, SharePoint syncs).
    - Confirm OneNote cache, application configurations, and runtime dependencies are preserved.
4. **Profile & Application Migration Testing**
    - Execute scripted profile uplift to align all local and roaming paths under the new shared account (`shr-tunops-wta`).
    - Verify application bindings and environment variables correctly resolve to the new account context.
    - Confirm that OneNote, Power BI, PowerApps, and local project paths open as expected under WTA credentials.
5. **Pre-Cutover Testing**
    - Functional tests are executed on the clone environment while the production workstation remains online.
    - Regression validation ensures no runtime dependency is lost in the migration process.
6. **Cutover Schedule**
    - **Timing:** Out-of-hours change window (typically **03:00–06:00**).
    - **Conditions:** Wind Tunnel operations fully paused (normal shutdown between **00:00–02:00**).
    - Production system switched to new WTA-aligned profile post validation.
7. **Rollback Plan**
    - If any post-cutover issue occurs, revert to the previous production disk immediately using the cloned NVMe image.
    - Rollback time estimated <30 minutes.

### **Outcome**

This cloning and cutover methodology ensures:

- Complete business continuity with zero data loss risk.
- Verified and reproducible profile migration process.
- Repeatable model for future SEQ migrations.
- Documented fallback ensuring CAB compliance and audit trace.