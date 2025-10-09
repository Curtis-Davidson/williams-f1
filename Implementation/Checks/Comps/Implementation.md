from pathlib import Path

# Markdown content from the previous message
markdown_content = """# 🔧 Implementation Runbook – Shared Account Remediation  
**Department:** Composite Manufacturing  
**Shared Account:** `shr-comps-mfg`  
**Generic Account to Disable:** `FACTORY\\comps`  
**CAB Reference:** `[NOT SPECIFIED]`  
**Document Source:** `shr-comps-mfg.docx`  
**Status:** FINAL – Rule 6 Format  
**Date:** 02/09/2025

---

## 1. Preparation

- [ ] Confirm CAB approval reference: `[NOT SPECIFIED]`
- [ ] Identify all **Device Category 8** machines for shared account use (full list below)
- [ ] Identify all **users listed** as authorised shared account operators
- [ ] Export AD object for:
    - `FACTORY\\comps` (pre-disable snapshot)
- [ ] Export current group memberships for:
    - `FACTORY\\comps`
    - Any local groups on Cat 8 devices
- [ ] Notify operational leads and production floor managers of upcoming change window

---

## 2. Account Creation

- [ ] Create new Active Directory account: `shr-comps-mfg`
- [ ] AD properties:
  sAMAccountName: shr-comps-mfg

Display Name: Composite Manufacturing Shared Account

Description: Shared account replacing FACTORY\comps for authorised production device access

Account type: Standard user

Password: Set per policy (complexity, expiry enforced)

Logon Hours: [NOT SPECIFIED]

Logon Workstations: Restrict to Cat 8 device names

Smartcard Logon: Disabled

markdown
Always show details

Copy code
- [ ] Hide from Global Address List (GAL) if applicable
- [ ] Assign OU and GPO inheritance per standard for shared accounts
- [ ] Store password securely in Keeper or other enterprise vault: `[NOT SPECIFIED]`
- [ ] Assign ownership to: **Blake Dawe**

---

## 3. Group Creation & Membership

- [ ] Create or reuse the following AD groups:
- `grp-comps-mfg-RO` – Read-only share access
- `grp-comps-mfg-RW` – Read/write access
- `grp-comps-mfg-LAC` – Logon access control
- [ ] Add `shr-comps-mfg` to:
- `grp-comps-mfg-RW`
- `grp-comps-mfg-LAC`
- [ ] Populate `grp-comps-mfg-LAC` with the 34 Cat 8 device names
- [ ] Assign users (see Section 10) to applicable access groups per PoLP

---

## 4. Device Configuration

**Device Category 8 Devices – Permit Only `shr-comps-mfg`**

- [ ] Set **logonWorkstations** to permit `shr-comps-mfg` on:
  M8910, W10158, M8427, M3236, VIRTEK-FSZ39N2, VIRTEK-BX9ZCP2, VIRTEK-BX7ZCP2,
  W8698, W10624, W9449, W8697, W10902, W10218, L10449, W8830, W10823, W9433,
  W3194, W9444, L2175, L2155, SEIKI10, SEIKI11, W8762, W10824, W9436, T10175,
  T10177, W8656, W8753, T10179, L10118, T10178, L10333, W10437, WF1SHD-537Q084

yaml
Always show details

Copy code
- [ ] Remove `FACTORY\\comps` from:
- Local Administrators
- Remote Desktop Users
- All mapped local groups (check: `net localgroup`)
- [ ] Confirm each device:
- Has access to the correct mapped drives
- Has no conflicting legacy GPOs or login cache

---

## 5. Permissions & Resources

- [ ] Assign mapped network drives:
  V:\ = \\factory.wf1\wf1\Department1
  L:\ = \\factory.wf1\wf1\apps_win\licom

yaml
Always show details

Copy code
- [ ] Enable access to the following:
- SharePoint: https://williamsf1.sharepoint.com/sites/SPC-TheHub
- Web apps: Same access as `FACTORY\\comps`
- Internet: Standard organisational policy
- [ ] Restrict access to:
- OneDrive: Standard access only
- Email: No special configuration
- Teams: Not required
- [ ] No repository/storage requirement
- [ ] No new mailbox or distribution list required

---

## 6. MFA & Keeper Integration

- [ ] Register `shr-comps-mfg` for **MFA**: `[NOT SPECIFIED IN DOC]`
- [ ] Store credentials in enterprise vault: `[NOT SPECIFIED IN DOC]`
- [ ] Credential owner: **Blake Dawe**
- [ ] Confirm MFA reset process and responsible parties: `[NOT SPECIFIED]`

---

## 7. Disable Legacy Generic Account

- [ ] Disable AD object: `FACTORY\\comps`
- [ ] Rename to `zzz_DISABLED_factory_comps`
- [ ] Move to archival OU (e.g. `OU=DisabledAccounts`)
- [ ] Retain for rollback window (30 days unless CAB states otherwise)

---

## 8. Validation & Testing

- [ ] Validate logon with `shr-comps-mfg` across **all 34 Cat 8 devices**
- [ ] Confirm mapped drives `V:\\` and `L:\\` appear and are accessible
- [ ] Confirm SharePoint and Web Apps are accessible
- [ ] Check each device:
- LogonWorkstations restriction works
- No unexpected accounts have access
- [ ] Confirm apps launch correctly:
- MS Edge, Mestec, NX, Teamcenter, VLC Player, Tulip, Adobe Reader (View Only), Virtek Iris Client
- [ ] Record screenshots of successful login, drive access, and app launch per device group
- [ ] Store logs in CAB Evidence folder: `[NOT SPECIFIED]`

---

## 9. Handover

- [ ] Update CMDB:
- `shr-comps-mfg` AD object
- Linked groups and devices
- [ ] Upload final runbook to:
- `[NOT SPECIFIED – e.g., Confluence, SharePoint]`
- [ ] Notify:
- Blake Dawe
- IT Support
- Production floor leads

---

## 10. Named Users for Shared Account Access

_As per document section:  
All users below are approved for use of `shr-comps-mfg` on Cat 8 devices:_

Blake Dawe, Darren Kennet, Agnieszka Zielinska, Darren Gormley, James Howland, Matthew Miller,
Patrick Mahoney, Lisa Nicholls, Ross Allen, Stefan Nicholls, Steve Bradbury, Alistair White,
Dominic Grant, Jaime Weston, Louis Weston, Matt Taylor, Matthew Wright, Owen Hughes, Tyler Birks,
Alan Mansbridge, Andrew Harrison, Ben Abrey, Jacob Surman, Marcin Tchorz, Micheal Evans,
Nick Bass, Oliver Lavis, Ryan Jones, Sam Gibson, Alex Nuttall, Justin Turner, Joseph McKenna,
Luke Weston, Matthew Nicora, Patrick Kell, Tom Wood, Will McDonal, Alan Doyle, Liam O’Connor,
Mandy Major, Mark Duffy, David Williams, Russell Pearce, Ben Norton, Chris Pickett, Peter Hoyle,
Paulius Miseliunas, Linden Brewster, Lee White, Ben Partridge, Darren Partridge, Gary Wharton,
James Gale, Ken Fuentesfina, Maciej Zawadka, Paul Atkin, Paul Mackenzie, Sam Woods,
Tomasz Zaprawa, Andrew Clothier, Lee Revita, Lee Tarrant, Richard McNicholas, Steven Moss,
Tomasz Wozniak, Travis Radbourne, Adam Pringle, Ben Bryant, Harry Willoughby, Jamie Wilson,
Joe Bis, Edward Cutting, Leo Peacock, Daniel Leggett

yaml
Always show details

Copy code

---

**End of Document**
"""

# Save to markdown file
output_path = Path("/mnt/data/shr-comps-mfg-runbook.md")
output_path.write_text(markdown_content)

output_path.name
Result
'shr-comps-mfg-runbook.md'
 The Implementation Runbook for shr-comps-mfg has been exported in full Markdown format.

You can download it here:
shr-comps-mfg-runbook.md