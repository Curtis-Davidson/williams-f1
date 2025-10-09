# Scope of Works

**Account to be Created**
- shr-tunops-wtp2 (standard Shared Account).
- No admin Shared Account required at this stage.

**Device**
- WTP2 workstation (recently replaced during shutdown).
- Device must be Intune-enrolled and fully aligned with E5 licensing.
- **Note:** This workstation forms part of the Wind Tunnel Planner Countdown Machine system.

**Phone**
- Dedicated Android business phone.
- **Requirement:** must be capable of photographing the Formula 1 model in the wind tunnel and syncing images directly to the shr-tunops-wtp2 account profile on the WTP2 workstation via OneDrive.
- Must be Intune-enrolled, MFA-enabled, and secured in line with Williams standards.

**Applications Required**
- NX
- TeamCenter (web-based)
- Microsoft Office (E5 suite)
- MPart
- Teams
- Wind Tunnel Planner application
- VLC Player (ensure migration)
- Two SharePoint sites (to be confirmed) pinned as desktop/browser apps

**Cut-over Requirement**
- During migration, confirm all application paths are correct and application data is mapped properly (e.g. config files, local data, network data mappings).

**Groups / Access**
- Add shr-tunops-wtp2 to correct AD groups in line with WF1 standards.
- Lockdown login using logonWorkstations attribute: restrict shr-tunops-wtp2 to the WTP2 device only.

**Email & Collaboration**
- Shared mailbox: shr-tunops-wtp2@williamsf1.com.
- Enable Teams functionality.
- Enable OneDrive sync with Android phone.

**MFA / Security**
- Keeper MFA mandatory for account.
- Authenticator app also configured on the Android business phone.

**Data Migration**
- Migrate all desktop, documents, and application data from TunnelOps Generic Account to shr-tunops-wtp2.
- Validate mapped drives, SharePoint shortcuts, and app configs post-migration.

---

# Implementation Plan

**Create Shared Account shr-tunops-wtp2 in AD**
- Apply Keeper MFA.
- Enforce password policy (E5 standards).
- Add notes in AD for ownership, password reset process, and business function.

**Mailbox & Collaboration Setup**
- Create shr-tunops-wtp2@williamsf1.com.
- Enable Teams licence (E5).

**Group Memberships**
- Add to RW/RO file share groups.
- Add to login access group (WTP2 only).
- Add to SharePoint access groups for specified sites.

**Device Configuration – WTP2 Workstation**
- Confirm Intune enrolment.
- Assign E5 licence.
- Install/configure: NX, TeamCenter (web), Office suite, MPart, Teams, Wind Tunnel Planner, VLC.
- Pin required SharePoint sites as apps on desktop/browser.
- During cut-over, validate that all application paths and application data mappings are correct.
- Lock account to device via logonWorkstations.

**Phone Setup – Android**
- Enrol in Intune.
- Apply device compliance and app protection policies.
- Configure OneDrive so that all wind tunnel model photos taken on the device automatically sync into the shr-tunops-wtp2 account profile on the WTP2 workstation.
- Install and configure Microsoft Authenticator for shr-tunops-wtp2.

**Data Migration**
- Copy data from TunnelOps Generic profile to shr-tunops-wtp2.
- Validate mapped drives, SharePoint shortcuts, and app configs post-migration.

**Testing / UAT**
- Confirm login to device restricted to shr-tunops-wtp2.
- Validate app launch and functionality (including correct paths and data mappings).
- Validate mapped drives, SharePoint links, and email/Teams access.
- Take test photos of the F1 wind tunnel model using the Android device and confirm immediate sync to the WTP2 workstation under shr-tunops-wtp2.
- Confirm MFA (Keeper + Authenticator).

**8. Hypercare Phase**
- Provide a full week of hypercare monitoring with rapid response to any issues raised.
- During this period, capture and log all results, ensuring functionality and stability are demonstrated in live use.
- At the end of the week, obtain formal stakeholder sign-off confirming that the account, device, phone integration, and application setup meet requirements.
- Following sign-off, handover to IT Support by creating and publishing a Confluence support document, ensuring the ongoing support model is documented and in place.  