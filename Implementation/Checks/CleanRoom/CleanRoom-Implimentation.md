# 🧾 Cleanroom Account Migration: Implementation Plan

## 📍 Project Summary

- **Objective:** Decommission the shared `f1cleanroom` generic Windows account and enforce named user authentication on all Cleanroom workstations.
- **Reason:** Improve traceability, enforce security policy compliance, and eliminate shared logins which violate audit and cyber standards.

---

## 🔧 Implementation Work Breakdown

### 1. ✅ User Identification & Account Setup

**Tasks:**
- [ ] Confirm full Cleanroom staff list with Composites Manager
- [ ] Create/verify AD user accounts for:
    - Liam Bragg
    - Myles Jones
    - 2–3 additional staff (names TBC by manager)

**Requirements per user:**
- Unique AD login credentials
- Access rights to:
    - Cleanroom devices (see below)
    - Composites SharePoint folders
    - Cleanroom MS Teams channel
- Outlook access:
    - Primary mailbox (personal)
    - Secondary access to `f1cleanroom@williamsf1.com` (if required)

**Owner:** Infrastructure Team + AD Admin  
**Deadline:** Prior to rollout window

---

### 2. 💻 Device Configuration

**Devices Affected:**
- W10815 – Cleanroom PC
- W8991 – Secondary PC
- W8714 – Status to be confirmed
- W9075 – Possibly retired (confirm if still active)

**Tasks:**
- [ ] Configure Group Policy / Local Settings to:
    - Restrict login to named users only
    - Remove `f1cleanroom` from login rotation (or flag for emergency use only)
- [ ] Ensure successful login for each named user on all live devices

**Owner:** Desktop Support + GPO Admin  
**Timeline:** Immediately after user account provisioning

---

### 3. 📂 File & Shortcut Migration

**Tasks:**
- [ ] Backup and migrate all required files from:
    - `C:\Users\f1cleanroom\Documents\`
- [ ] Move to Composites Team SharePoint under Cleanroom folder
- [ ] Replicate key shortcuts in new user profiles:
    - Cleanroom dashboard
    - Inspection logs
    - Site utilities (if any)

**Owner:** Curtis-Davidson + Local IT  
**Dependency:** SharePoint permissions and folder structure must be pre-configured

---

### 4. 📬 Email & Collaboration Setup

**Outlook:**
- [ ] Setup individual Outlook profiles for each user
- [ ] Optionally link shared mailbox `f1cleanroom@williamsf1.com`

**Teams:**
- [ ] Ensure login under personal accounts
- [ ] Confirm access to Cleanroom Teams channel
- [ ] Verify chat, file access, and call integration works

**Owner:** Collaboration Team + Curtis-Davidson  
**Notes:** Warn users of first-time login delays

---

### 5. 🖨️ Printing & Peripheral Access

**Tasks:**
- [ ] Test print functionality from each account on:
    - All Cleanroom printers (model names not specified)
- [ ] Ensure driver inheritance from AD profile or install per user if required

**Owner:** Print Services or Desktop Support

---

### 6. ❌ Generic Account Decommissioning

**Conditions to Proceed:**
- All users migrated successfully
- Verified:
    - Login works
    - Email and Teams functioning
    - File access and printing successful

**Actions:**
- [ ] Disable `f1cleanroom` account in Active Directory
- [ ] Remove from all groups (except one backup terminal, if designated)
- [ ] Log deactivation in security handover report

**Owner:** AD Admin + Security Ops

---

## 🚨 Known Challenges & Mitigation

| Challenge                         | Mitigation Strategy                                              |
|----------------------------------|------------------------------------------------------------------|
| Resistance to login change       | Frame as cyber/audit requirement – not punishment                |
| Workflow slowdown                | Offer side-by-side user walk-throughs during handover            |
| Forgotten credentials            | Pre-warn users about login support & offer quick reset options   |
| Manager pushback on extra work   | Get formal sign-off of user list and security alignment          |

---

## 📆 Key Milestones

| Milestone                        | Owner              | ETA         |
|----------------------------------|--------------------|-------------|
| Confirm user list               | Composites Manager | [TBC]       |
| AD user account creation        | Infra + AD Admin   | [TBC]       |
| Device GPO configuration        | Infra Team         | [TBC]       |
| SharePoint & shortcuts setup    | Curtis + Infra     | [TBC]       |
| Outlook/Teams config            | Collaboration Team | [TBC]       |
| Print access testing            | Print Support       | [TBC]       |
| f1cleanroom deactivation        | AD Admin + Security| [TBC]       |

---

## 🔐 Security Audit Note

The Cleanroom sits within a production-sensitive area tied to Composites operations. Shared logins in this space pose an unacceptable risk under:
- Williams Racing Cybersecurity Policy
- Audit compliance for traceability of operator actions

This remediation provides:
- Named accountability
- Log tracking
- Reduced exposure to compromised credentials
- Improved email & Teams ownership

---
