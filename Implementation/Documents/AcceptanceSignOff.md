# Handover to Support – Checklist
**Account:** Model Shop (`shr-modelshop`)  
**Project:** Shared Account Remediation

---

## 1. Project Completion Confirmation
- [ ] Legacy shared account migrated to new clean account (`shr-modelshop`)
- [ ] Business Owner sign-off obtained (name/date to be recorded)
- [ ] All identified users successfully log in with new account and access applications as expected
- [ ] No outstanding issues or open tickets remain relating to this migration (ServiceNow/Jira reference)

---

## 2. Documentation
- [ ] Confluence pages updated with:
    - Migration summary (old vs new account details, impacted systems, rollback plan reference)
    - User communication log
    - Technical configuration changes (OU, GPO, Keeper, 2FA, logonWorkstations)
- [ ] Associated Change Request (CAB reference ID) closed in line with governance

---

## 3. Access & Permissions
- [ ] Password for new shared account stored in Keeper under the correct folder (Shared Accounts > Model Shop)
- [ ] Named users granted access to Keeper for 2FA requests (membership reviewed and confirmed)
- [ ] Old shared account disabled in AD (date/time stamp of disablement logged)
- [ ] Account restrictions in place:
    - `LogonWorkstations` applied to authorised Model Shop PCs only
    - Group memberships reviewed and minimised
    - GPO lockdown confirmed applied

---

## 4. Handover & Support
- [ ] Hypercare period completed (start/end dates recorded)
- [ ] Support Team Leads briefed (meeting notes or confirmation email attached)
- [ ] Knowledge transfer completed:
    - Support notes added to Confluence (including reset/escalation steps)
    - Contact details for escalation (Infra, AD Admin, Keeper Admin) documented

---

## 5. Final Sign-Off

**Business Owner:**  
&nbsp;  
&nbsp;
_____________________________  
*(Name / Signature / Date)*

---

**Project Lead:**  
&nbsp;  
&nbsp;
_____________________________  
*(Name / Signature / Date)*

---

**Support Lead:**  
&nbsp;  
&nbsp;
_____________________________  
*(Name / Signature / Date)*