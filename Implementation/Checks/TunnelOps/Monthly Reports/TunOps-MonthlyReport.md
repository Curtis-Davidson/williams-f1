# **TunnelOps Remediation Programme – Monthly Progress Report**

**Reporting Period:** Last 7 Weeks

**Sequences Covered:** 6, 11, 15, 10, 12, 14

**Prepared by:** Paul Davidson



------

# **1. Summary **

Over the last seven weeks, good progress has been made across multiple TunnelOps remediation sequences. Three early sequences (6, 11, and 15) were completed, and have moved to the deeper, more complex operational sequences (10, 12, and now 14).

Delivered **five remediated accounts** within the TunnelOps environment, including full role-based machine builds, security validation, application packaging, macro compliance, and multi-screen tunnel operational setups.

**Wind Tunnel Engineer (Sequence 10)** and **Wind Tunnel Aero (Sequence 12)** roles. These required extensive ground-up machine builds, application work, security remediation, and operational testing.

------

# **2. Completed & In-Progress Sequences**

## **2.1 Sequence 6, 11, 15 (Completed Earlier in Period)**

These sequences were delivered prior to the last three weeks.

------

# **3. Sequence 10 – Wind Tunnel Engineer Role **

Sequence 10 represented one of the more complex and critical components of the TunnelOps remediation programme due to the operational sensitivity and compliance requirements of the Wind Tunnel Engineer role.

### **3.1 Ground-Up Machine Build (Windows 11 + Intune)**

There was no existing method document or historical build process.

A **complete build document** is in progress of being created based on a full end-to-end rebuild of a new Windows 11 workstation, including:

- Intune enrolment and policy baselining
- Role-specific configuration
- Verification with senior wind tunnel engineers
- Full discovery of undocumented requirements

### **3.2 Application & Add-in Packaging**

Several engineering tools failed under Windows 11 due to packaging, security, and signing differences.

Key work completed:

- Repackaged and re-signed the required Excel add-ins
- Resolving Defender and macro security compliance issues (Working with Chris)
- Corrected Windows 11 packaging behaviour that blocked installation
- Ensured macro-heavy engineering workflows could run safely and reliably

### **3.3 FIA Camera Tool (“Tunnel Vision”)**

This application is **FIA-regulated and legally tied to tunnel run documentation**, requiring perfect reliability.

Work completed:

- Fixed packaging and installation failures
- Repaired the screenshot capture → run number → email workflow
- Ensured correct image output format for FIA documentation compliance

### **3.4 Security Permissions + Database Access**

Multiple back-end permissions and database entries were required.

- Worked with Aero across the road
- Resolved Wind Tunnel Planner access issues
- Implemented database user provisioning (coordinated with Duncan Barr)

### **3.5  **Multi-Screen (Distributed 9-Monitor Environment)****

- Total of **nine monitors** used across the tunnel workflow
- **Six monitors** in the Wind Tunnel Control Room
- **Two monitors** positioned inside the tunnel for live run visibility
- **One monitor** in the model-makers’ preparation area
- All monitors operate on independent IP-based virtual channels
- Mixed refresh rates
- Historical instability and repeated manual layout adjustments
- Tunnel Workflow Live Data Visuals systems
- Adjacent **operations-room touchscreen workstation** used for procedural PowerPoint automations and live workflow steps
- Device configured to remain active (no sleep or display timeout) to keep procedures continuously visible
- Workflow between touchscreen station and the procedure whiteboard reviewed to confirm alignment with day-to-day tunnel operationsWork completed:

- Wrote a **automated placement script** with error handling to ensure deterministic window placement
- Resolved refresh-rate mismatches
- Eliminated the long-standing manual configuration

### **3.6 Outcome**

The Wind Tunnel Engineer role is now **fully cut over**.

The new machine is the primary working device, with the original secondary device retained temporarily for safety during macro policy propagation.

------

# **4. Sequence 12 – Wind Tunnel Aero Role (In Final Testing)**

Sequence 12 followed similar principles:

### **4.1 Ground-Up Rebuild**

- New Windows 11 machine built from scratch
- All applications, permissions, and data paths discovered and validated
- Role dissected to identify all operational touchpoints

### **4.2 Current Status**

- Machine currently in operational testing
- Engineers are validating during available tunnel downtime
- Tunnel has been extremely busy, requiring early mornings and odd-hour testing windows

### **4.3 Next Steps**

- Final acceptance sign-off
- Move the role to production use
- Update and finalise the build document and support documentation



------

# **5. Sequence 14 – Virtual Environment Role (In Progress)**

### **5.1 Preparation**

- Coordinating with role specialists
- Planning snapshot strategy prior to configuration changes
- Documenting each step to ensure rollback safety

### **5.2 Status**

- Active technical review underway
- Environment requirements being documented for the remediation

### **5.3 Planned Future Work**

Leadership has asked to prepare for movement into **Sequence 9** next, as it aligns with the work done for Sequence 14, and later **Sequence 5** pending internal scheduling.



------

# **6. Documentation Produced / In Progress**

Across all sequences, the following have been produced or are currently being finalised:

- **Full Build Documents** (Wind Tunnel Engineer & Wind Tunnel Aero roles)
- **Discovery Logs** capturing every unexpected behaviour, permission, and dependency
- **Support Handover ** for operational and support teams
- **Updated role requirement inventories**
- **Scripted automation for 8-screen setups**
- **Application packaging notes** for Windows 11 compatibility
- **Event Viewer and Defender log analysis reports**



------

# **7. Pending Work During Leave**

While away for 10 days: (Two weeks)

- Prepare CAB documents for Sequences, 9, and 5
- Finalise and refine build documents for both the Engineer and Aero roles
- Produce complete handover documentation for support for SEQ: 06, 11, 15, 10, 12.
- Progress SEQ:15



------

# **8. Operating & Delivery**



The wind tunnel environment is uniquely demanding and requires a measured, highly controlled approach.



- **Tunnel Availability**

  Access windows are dictated by live aerodynamic testing, which prioritises car performance. As a result, much of the work has required unusual hours—early mornings, late evenings, and opportunistic gaps—to ensure zero disruption to tunnel operations.

- **High-Sensitivity Systems**

  Many of the components involved (Excel macro engines, legacy data flows, FIA-regulated tooling, specialist camera systems, and screen control environment) are deeply embedded into operational workflows. These require careful handling, layered validation, and precise change execution to avoid downstream impacts.

- **Collaborative Integration**

  Being integrated into TunnelOps and working directly alongside the engineers, analysts, and aero specialists has significantly accelerated progress. Real-time feedback, shared troubleshooting, and immediate access to domain experts have allowed us to uncover issues faster, validate fixes sooner, and build documentation grounded in real operational use.

- **Complexity Driving Turnaround Times**

  The nature of the systems—multi-decade legacy components mixed with modern Windows 11, Intune, Defender, Streamlit, and FIA compliance workflows—means each build requires full end-to-end understanding, not simple replication. This has added legitimate turnaround time but has resulted in far more robust, future-proofed builds.

- **Positive Momentum**

  Despite the complexity, progress is strong and continuous. The department has been extremely supportive, collaborative, and open. Myself being  integrated has been essential part of out collaborative work.





------

------

