#  Implementation Plan: Neo800 Generic Account Remediation
**Project Ref:** P-135901  
**Scope:** Neo800-01 to Neo800-08 & Device W10103  
**Owner:** Andrew Cripps  
**Approved Date:** 09/09/2024

---

##  Phase 1 – Preparation & Governance

1. **Confirm Business Sponsor & IT Owner**
    - Business Owner: Andrew Cripps
    - Confirm with InfoSec that no remote access will be granted to Stratasys at this stage.

2. **AD Notes for Neo800-01 Account**
    - Add to Active Directory:
        - Business Owner name
        - Note that password must be rotated annually
        - Purpose of the account
        - Flag for 1Password update policy
    - Ensure Neo800-01 account is enabled and operational

3. **Password Security**
    - Set a strong, complex password for `Neo800-01`
    - Store securely in **1Password**
    - Implement annual password reset reminder

---

##  Phase 2 – Device Configuration (Neo800-02 to Neo800-08)

4. **Standardise All Devices on `Neo800-01`**
    - **Disable:** Neo800-02 to Neo800-08 accounts in AD
    - On each device Neo800-02 through Neo800-08:
        - Add `Neo800-01` to the local Administrators group
        - Log in as `Neo800-01`
        - Remove any existing Titanium shortcut from desktop
        - Copy Titanium shortcut from `C:\Users\Public\Desktop` to `Neo800-01`'s desktop
    - Repeat steps for:
        - Neo800-02
        - Neo800-03
        - Neo800-04
        - Neo800-05
        - Neo800-06
        - Neo800-07
        - Neo800-08

5. **Lock Down Account Usage**
    - Restrict `Neo800-01` to only log in on Neo800 devices
    - Ensure no other generic or individual accounts can log into Neo800 devices except:
        - `Neo800-01`
        - IT Admin accounts (for maintenance)

6. **Disable Internet Access (Neo800 Devices)**
    - Configure local firewall or group policy to block internet access for sessions under `Neo800-01`
    - Leave IT admin sessions exempt to allow patching or remote diagnostics

7. **Locking the Cabinet**
    - Lock all Neo800 cabinets physically
    - Access only permitted during maintenance with documented authorisation

---

##  Phase 3 – Device W10103 Kiosk Conversion

8. **Configure W10103 as Kiosk PC**
    - Convert Windows 10 into **Kiosk Mode**
    - Setup to:
        - Display Webcam App (`C:\Program Files (x86)\D-Link\D-ViewCam\main console.exe`) on TV 1
        - Auto-launch Excel to open the following file on TV 2:
            - `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation\ADM Machine Utilisation Tracker.xlsx`
        - If Excel file is missing, launch Excel without file
    - Confirm user can open any Excel file from the subfolder:
        - `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation`

9. **Restrict Logins on W10103**
    - Only allow Kiosk account to log in
    - Admins retain elevated access for support
    - Block internet access when logged in as Kiosk user

---

##  Phase 4 – Permissions & Access Rights

10. **Network Share Access**
- Ensure `Neo800-01` has:
    - **Read/write** access to:
        - `\\factory.wf1\wf1\department1\adm\1.12 Machine Utilisation`

- Ensure **Kiosk account** has:
    - **Read-only** access to the same path

11. **Shared Email Functionality**
- No change required
- Emails from Titanium continue to send notifications to:
    - `Neo800_notifications@williamsf1.com` (Exchange Distribution List)

---

##  Phase 5 – Testing & Validation

12. **Neo800-01 Functionality Test**
- Log in to all Neo800 devices using `Neo800-01`
- Confirm:
    - Titanium App launches correctly
    - Print job runs as expected
    - Reports are generated and written to network location
    - Event-based emails are sent successfully

13. **File Access Test – Individual Users**
- From their own Windows laptops, verify:
    - Users can access ADM report folders
    - Open and view Excel reports

14. **W10103 Kiosk Validation**
- On boot, confirm:
    - TV 1 displays live webcam feed via D-Link software
    - TV 2 displays Excel report or opens Excel blank if missing
    - User can browse Excel folder structure (read-only)
    - Internet is restricted in Kiosk session

---

##  Phase 6 – Decommissioning

15. **Decommission the following accounts in AD (once all tests pass):**
- `Neo800-02`
- `Neo800-03`
- `Neo800-04`
- `Neo800-05`
- `Neo800-06`
- `Neo800-07`
- `Neo800-08`
- Log deactivation and archive

---

##  Rollback Plan (if required)

If issues arise post-implementation:

- Re-enable `Neo800-02` to `Neo800-08` accounts temporarily
- Restore Titanium shortcuts from backups
- Reverse device lockouts and local group changes
- Restore original desktop profile if needed
- Revert W10103 from Kiosk mode to standard Windows login
- Notify ADM and Stratasys of rollback and freeze further changes

**Estimated rollback time:** 2–4 hours total for all devices  
