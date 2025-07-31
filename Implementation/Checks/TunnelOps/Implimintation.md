Implementation Steps to Create & Configure shr-tunops-dia01 / shr-tunops-dia01Adm
1. Active Directory Accounts
   Create AD shared account shr-tunops-dia01 (standard user).

Create AD shared account shr-tunops-dia01Adm (administrative user).

2. Active Directory Groups
   Create AD group grp-tunops-dia01RO (read-only disk access).

Create AD group grp-tunops-dia01RW (read-write disk access).

Create AD group grp-tunops-dia01LAC (login access control for devices).

Create AD group grp-tunops-dia01Adm (local admin permissions).

Create AD group grp-tunops-dia01RDC (remote desktop access).

3. Memberships
   Add shr-tunops-dia01 and shr-tunops-dia01Adm to grp-tunops-dia01RW.

Add both accounts to grp-tunops-dia01LAC.

Add shr-tunops-dia01Adm to grp-tunops-dia01Adm.

Add identified DIA team users to grp-tunops-dia01RDC.

4. Permissions
   Grant grp-tunops-dia01RW read/write access to:

Network share: T:\ATF (\\smb.wf1-isil01.factory.wf1\department2)

Local disk: C:\Williams and relevant user directories on L2160.

Migrate files from C:\Users\TunnelOps\ to a shared location accessible by both TunnelOps and the new shared accounts.

Reconfigure any diagnostic software to write/read from the new shared account’s directory.

5. Diagnostics & Hardware
   Verify diagnostics apps and hardware continue to work with new accounts.

Validate USB hardware on L2160 is unaffected.

6. Local Admins
   Add grp-tunops-dia01Adm and DPT Admin to local Administrators on L2160.

Remove other unnecessary business groups from local Admins.

7. Testing
   Perform login tests for both accounts at L2160.

Ensure old TunnelOps account still works until cutover.

Test read/write access to specified directories and network shares.

Test admin-level activities with shr-tunops-dia01Adm.

Test RDC access to L2160 using grp-tunops-dia01RDC.

Confirm applications operate identically to TunnelOps account.

8. Account Notes & Password Management
   Enforce yearly password change for both accounts.

Store passwords securely (e.g., in 1Password).

Add notes in AD:

Business owner name

Password policy reminders

Account purpose description

9. Internet Access
   Restrict both accounts from general Internet access.

Allow access to:

https://dev.azure.com/F1Technical/

https://miro.com/

10. Housekeeping & Rollback
    Prepare rollback plan to revert to TunnelOps if needed.

Communicate to business teams to lock screens when leaving the device.

11. Code & Roadmap
    Audit and remove hardcoded credentials in any apps.

Submit security changes for review and approval.

Schedule and track roadmap for code changes and software licensing.

