# Canon uniFLOW – AD Group Delegation for Access Card Print Release

## Purpose
To enable individual users in the Machine Shop to release print jobs using their own building access cards, while jobs are submitted centrally using a shared account (e.g. `shr-machine-mfg`). This ensures secure, auditable release without requiring multiple users to log in with the shared account directly.

---

## Scenario Summary

- All staff in the Machine Shop have building access cards.
- Print jobs are submitted from a shared PC using the `shr-machine-mfg` account.
- Users will authenticate at the Canon device using their own access card.
- A dedicated AD group (`uniFLOW-MachineShop-Delegates`) will control who is authorised to release jobs from the print queue.
- This avoids shared PINs or passwords and enables individual accountability.

---

## Systems Involved

- Active Directory Domain Controller
- Canon uniFLOW Admin Console: `https://<uniflow-server>/uniflow`
- Target printer: `shr-machine-mfg`
- Canon MFDs with card readers
- Existing building access control system (card-based)

---

## Step 1: Create the AD Group (if not already present)

1. Open `Active Directory Users and Computers`.
2. Navigate to the correct Organisational Unit.
3. Right-click > `New > Group`.
4. Group Name: `uniFLOW-MachineShop-Delegates`
5. Group Type: Security, Scope: Global.
6. Add all Machine Shop staff to this group under the `Members` tab.
7. Click Apply and OK.

---

## Step 2: Confirm uniFLOW Card Registration

1. Ensure all users have their card registered within uniFLOW:
    - Users must have their card number linked to their AD account in uniFLOW.
    - This may be done by self-registration at device or bulk import via admin.
2. Test card login at any uniFLOW-enabled device.
3. Users must see their own print jobs (if any) and be able to log in.

---

## Step 3: Log into the uniFLOW Admin Console

1. Go to: `https://<uniflow-server>/uniflow`
2. Log in with a user account that has rights to manage devices and queues.

---

## Step 4: Configure the Shared Queue for Delegated Release

1. Navigate to `Queue Management` or `Devices > Queues`.
2. Select the `shr-machine-mfg` queue.
3. Go to `Access Rights` or `Authorised Users`.
4. Add the AD group `uniFLOW-MachineShop-Delegates`.
5. Set appropriate rights:
    - Can release print jobs submitted by `shr-machine-mfg`
    - Cannot delete jobs from other users
6. Save and apply changes.

---

## Step 5: Test Delegated Access via Access Cards

1. Submit a print job from the shared PC (logged in as `shr-machine-mfg`).
2. Walk to the Canon device.
3. Tap the building access card.
4. Confirm the print job is visible and can be released.
5. Confirm other users’ jobs are not visible (unless configured otherwise).

---

## Optional Enhancements

- Enable PIN fallback if card is unavailable.
- Set uniFLOW to default to "Secure Print" queues only.
- Use reporting to monitor which users are releasing from shared queues.

---

## Reversion Plan

If delegation or card release fails:

1. Revert to using personal user logins temporarily.
2. Check AD group membership and sync status.
3. Recheck that user cards are registered to correct AD accounts in uniFLOW.
4. Use uniFLOW logs to trace login or print job mismatches.

---

## Summary

This implementation allows staff in the Machine Shop to release print jobs submitted from a shared account using their personal access cards. 
It ensures secure, auditable release without relying on shared passwords or multiple login sessions. The use of an AD group (`uniFLOW-MachineShop-Delegates`) 
provides scalable, maintainable access control in line with enterprise security best practices.