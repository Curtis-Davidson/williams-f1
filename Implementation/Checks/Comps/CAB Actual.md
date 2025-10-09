








Account Creation

shr-comps-mfg

Create AD account shr-comps-mfg.

Description: Composite Manufacturing Shared Account (excluding Virtek).

Restrict logon to designated non-Virtek PCs.

Enforce password policy and MFA.

Store credentials securely.

Owner: Blake Dawe.

shr-virtek

Create AD account shr-virtek.

Description: Shared Account for Virtek Laser PCs.

Restrict logon to 14 Virtek PCs.

Enforce password policy and MFA.

Store credentials securely.

Owner: Blake Dawe.

Group Creation & Membership

Create groups:

grp-comps-mfg-RO, grp-comps-mfg-RW, grp-comps-mfg-LAC

grp-virtek-RO, grp-virtek-RW, grp-virtek-LAC

Add shr-comps-mfg to RW + LAC for composite PCs.

Add shr-virtek to RW + LAC for Virtek PCs.

Populate each LAC group with the correct hostnames.

4. Device Configuration

Remove FACTORY\comps from Local Admin, RDP, and other groups.

Apply workstation logon restrictions:

shr-comps-mfg will only authenticate on authorised Composite Manufacturing PCs.

shr-virtek will only authenticate on the 14 Virtek Laser PCs.

Confirm mapped drives and GPOs apply correctly.

Permissions & Resources

Map drives:

V:\ = \\factory.wf1\wf1\Department1  
L:\ = \\factory.wf1\wf1\apps_win\licom

Grant SharePoint access: https://williamsf1.sharepoint.com/sites/SPC-TheHub

Internet access per org policy.

Data Migration

Backup user profile data, cached files, and local settings currently associated with FACTORY\comps.

Backup mapped drive access and permissions (V:, L:) from FACTORY\comps.

Migrate data and reapply permissions to shr-comps-mfg and shr-virtek as appropriate.

Confirm no residual files or permissions remain tied exclusively to the old account.

MFA & Keeper

Register both accounts for MFA.

Store passwords and MFA tokens in enterprise vault.

Verify reset and recovery process.

Legacy Account Removal

Disable FACTORY\comps.

Validation

Test logon with shr-comps-mfg on composite PCs.

Test logon with shr-virtek on Virtek PCs.

Confirm MFA challenge, drive mapping, SharePoint access.

Launch and validate applications.

Virtek-specific validation:

Ensure Virtek Iris Client runs correctly under shr-virtek.

Confirm laser projection software authenticates and initialises with no licence errors.

Send Luminos lines from each Virtek workstation to confirm lasers run correctly under the new account.

Capture and store evidence (screenshots, logs, Luminos validation outputs)

Sign-off

By signing below, the Head of Composites confirms:

The remediation has been delivered successfully.

All required systems and applications function as expected.

Ownership of day-to-day use of shr-comps-mfg and shr-virtek is accepted.

Handover to support teams is complete.

Handover

Support document uploaded to JIRA/Confluence.

Support sign-off and handover.