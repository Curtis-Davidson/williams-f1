# Neo800-01 Shared Account Remediation Plan – WF1

---

### 1.  Purpose of Change
- The objective is to consolidate multiple generic accounts used across Neo800 3D printers into a single secured AD account (**Neo800-01**) to improve traceability, maintain operational integrity, and reduce access risk.
- The change addresses issues where only the initiating account can manage print jobs, requiring the continued use of a single shared identity for these devices.

---

### 2. 🖥 Devices Involved
- **Neo800-01** – Large-format 3D printer (ADM)
- **Neo800-02** to **Neo800-08** – Additional printers (to be decommissioned)
- **W10103** – ADM office PC used for camera/live monitoring and report display via TV output

---

### 3. 👤 Named Users & Roles
- **Andrew Cripps** – Role: Additive Digital Manufacturing Supervisor
- **Krishan Mistry** – Role: Additive Manufacturing Engineer
- **Thomas Wrenn** – Role: ADM Technician
- **Will Wrenn** – Role: ADM Technician
- **Reece Hardy-Jack** – Role: ADM Technician
- **Charlie Souch** – Role: ADM Technician

---

### 4.  New AD Account(s)
- ✅ **shr-kiosk-w10103**
    - Purpose: Kiosk mode login for **W10103** device only
    - Permissions: Read-only to report folders; cannot access internet
    - Restricted to **W10103**

---

### 5.  Existing Shared Account Handling
- ✅ **Neo800-01**
    - Retained and restricted to Neo800 devices only
- ❌ **Neo800-02** to **Neo800-08**
    - Disabled post-validation
- ✅ **shr-kiosk-w10103**
    - Used solely for Kiosk mode on **W10103**

---

### 6. 🛠️ Implementation Plan (MANDATORY)

####  Phase 1 – Preparation
1. Identify all Neo800 devices and users involved
2. Confirm physical access to cabinets and ensure **Neo800-01** account password is stored in 1Password
3. Back up user profile: `C:\Users\Neo800-01` on all devices

####  Phase 2 – AD Account Setup
1. Confirm **Neo800-01** is retained in AD, with updated description and notes:
    - Business owner: **Andrew Cripps**
    - Usage: 3D Printer control account
    - Change log: Password policy compliance, store in 1Password
2. Disable accounts **Neo800-02** to **Neo800-08**
3. Create kiosk account **shr-kiosk-w10103** and restrict to **W10103**

####  Phase 3 – Device Lockdown
1. Restrict **Neo800-01** login to only:
    - **Neo800-01** to **Neo800-08**
2. Restrict **shr-kiosk-w10103** to only **W10103**
3. Confirm only IT Admins can login outside of these accounts
4. Apply GPO or local policy to prevent internet access for both account types

####  Phase 4 – Application & Access Configuration
1. On **Neo800-02** to **Neo800-08**:
    - Add **Neo800-01** to Local Administrators
    - Remove old Titanium shortcut from desktop
    - Log in as **Neo800-01** and copy Titanium shortcut from `C:\Users\Public\Desktop`
2. Setup W10103 in Kiosk Mode:
    - Webcam feed via: `C:\Program Files (x86)\d-link\D-ViewCam\main console.exe`
    - Excel autoload: `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation\ADM Machine Utilisation Tracker.xlsx`
    - Ensure read-only permissions for **shr-kiosk-w10103**
3. Validate Titanium, Excel and report write access

####  Phase 5 – Fallback or Decommission
1. Confirm successful login and app functionality for **Neo800-01**
2. Validate kiosk mode operation on **W10103**
3. Decommission AD accounts:
    - **Neo800-02** to **Neo800-08**
4. Update system documentation and notify Service Desk

---

### 7.  Rollback Plan
- Re-enable AD accounts **Neo800-02** to **Neo800-08**
- Remove kiosk settings from **W10103**
- Restore Titanium shortcuts if removed incorrectly
- Undo GPO restrictions on affected machines
- Estimate: ~30 mins per device

---

### 8.  Stakeholders

🔹 **Business Stakeholders**
- Andrew Cripps – Additive Digital Manufacturing Supervisor

🔸 **Technical Stakeholders**
- Mike Smith – IT Support Manager
- Harry Wilson – Head of IT Security
- Matt Wallace – DPT Infrastructure Manager
- Tom Lewington – Project Manager
- James Chrystie – Project Manager
- David Steward – Director of Infrastructure and Services
- Michael Cutugno – CISO

---

### 9.  Special Notes or Concerns
- ❗ No confirmation of Titanium and Magics app licensing — to be flagged with Business Owner & IT Security
- ❗ Titanium app does not support multi-user interaction or Switch User function
- ✅ No change to existing email notification functionality
- ✅ No vendor remote access – per Williams IT Security policy
- ✅ ADM cabinet must remain physically locked outside maintenance

---

### 10.  Output Format
- Markdown `.md`
- Fully copy-pasteable
- Structured by section, ready for CAB documentation and implementation scripting

