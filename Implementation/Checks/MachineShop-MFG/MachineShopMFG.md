Project: Replace legacy CellA/CellB logins with domain-secured shr-machine-mfg account
Scope: 5 manufacturing machines (FR0021–FR0024 + FR0041)

 Phase 1: Preparation (Backend – AD)
1. Create the Shared AD Account
   Name: shr-machine-mfg

OU Location: OU=SharedAccounts,OU=Users,DC=corp,DC=company,DC=com

Account settings:

Strong password

Password never expires: No

Smartcard logon required: No

Store credentials in password manager (e.g. 1Password)

2. Create Supporting AD Security Groups
   Each group is used for distinct access control:

Group Name	Purpose
grp-machine-mfgRO	Read-only access to specific shares
grp-machine-mfgRW	Read-write access to files and apps
grp-machine-mfgLAC	Local login rights to assigned machines
grp-machine-mfgRDC	Remote Desktop rights (if applicable)

powershell
Copy
Edit
New-ADGroup -Name "grp-machine-mfgRO" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgRW" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgLAC" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgRDC" -GroupScope Global -GroupCategory Security
3. Add Memberships
   Add shr-machine-mfg to RW and LAC groups:

powershell
Copy
Edit
Add-ADGroupMember -Identity "grp-machine-mfgRW" -Members "shr-machine-mfg"
Add-ADGroupMember -Identity "grp-machine-mfgLAC" -Members "shr-machine-mfg"
Add approved users (e.g. engineering staff) to RDC group:

powershell
Copy
Edit
Add-ADGroupMember -Identity "grp-machine-mfgRDC" -Members "mark.peers", "david.finch"
 Phase 2: Group Policy Enforcement (Backend – GPO)
4. Create and Link GPO: lockdown-shr-machine-mfg
   Scope: Target OU (e.g. OU=ManufacturingDevices)

Configure:

a. Allow Logon Locally:
plaintext
Copy
Edit
Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment > Allow log on locally
→ grp-machine-mfgLAC
b. Allow Logon via RDP (if used):
plaintext
Copy
Edit
→ grp-machine-mfgRDC
c. Restricted Groups:
plaintext
Copy
Edit
Remote Desktop Users → grp-machine-mfgRDC
Administrators → DPT Admins (no CellA/CellB!)
🖥 Phase 3: Machine Side Changes (Frontend – Workstation)
5. Remove Legacy Accounts (CellA / CellB)
   Run on each machine:

powershell
Copy
Edit

# Remove local legacy accounts
net user CellA /delete
net user CellB /delete
6. Add AD Groups to Local Groups (If not GPO-managed)
   powershell
   Copy
   Edit
# Add domain shared account groups locally
net localgroup "Administrators" "corp\DPT Admins" /add
net localgroup "Users" "corp\grp-machine-mfgLAC" /add
7. Repoint Application Shortcuts
   Verify that apps used on these machines are not hardcoded to CellA or CellB profiles

If necessary, create new desktop shortcuts for apps to function under shr-machine-mfg profile

8. Test Login & Application Behaviour
   Log in using shr-machine-mfg on all 5 machines

Confirm:

Apps work as expected

Shares and mapped drives are accessible

Printers available

User can log off/on and reconnect without issues

9. Finalise Drive & App Access via Group Permissions
   Add grp-machine-mfgRW to required folders in NTFS/Share permissions

Confirm shr-machine-mfg has RW access only where required

10. Document Ownership and Rotation
    Update the shared account with:

Owner: Name + email

Purpose: “Manufacturing shared login for 5 designated workstations”

Password Reset Frequency: Set reminder for annual change

 Final Checks
Confirm legacy accounts removed

shr-machine-mfg can log in locally

AD groups apply cleanly

All GPOs enforced correctly

No local shadow accounts remain

Logging, audit trail, and password storage compliant


--------------------------------------------------------------------

Implimentation MD

markdown_content = """
#  Shared Account Deployment – `shr-machine-mfg`

##  Objective
Securely implement and control the new shared AD account `shr-machine-mfg` across 5 manufacturing devices, replacing legacy CellA/CellB accounts.

---

##  Phase 1: Preparation (Backend – AD)

### 1. Create Shared AD Account
- **Account:** `shr-machine-mfg`
- **OU:** `OU=SharedAccounts,OU=Users,DC=corp,DC=company,DC=com`
- **Settings:**
    - Strong password
    - Password never expires: No
    - Smartcard: No
    - Store credentials in password manager

### 2. Create Supporting AD Groups

| Group Name            | Purpose                                 |
|-----------------------|------------------------------------------|
| grp-machine-mfgRO     | Read-only share access                   |
| grp-machine-mfgRW     | Read-write file/app access               |
| grp-machine-mfgLAC    | Local login access                       |
| grp-machine-mfgRDC    | Remote Desktop login rights              |


- **powershell:**

New-ADGroup -Name "grp-machine-mfgRO" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgRW" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgLAC" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "grp-machine-mfgRDC" -GroupScope Global -GroupCategory Security

---


### 3. Add Memberships


Add-ADGroupMember -Identity "grp-machine-mfgRW" -Members "shr-machine-mfg"
Add-ADGroupMember -Identity "grp-machine-mfgLAC" -Members "shr-machine-mfg"
Add-ADGroupMember -Identity "grp-machine-mfgRDC" -Members "mark.peers", "david.finch"


## Phase 2: Group Policy Enforcement (Backend – GPO)
### 4. GPO: lockdown-shr-machine-mfg

- **Scope:**
OU=ManufacturingDevices

- **Settings:**
Allow log on locally:

grp-machine-mfgLAC

Allow log on through RDP:

grp-machine-mfgRDC

Restricted Groups:

Remote Desktop Users → grp-machine-mfgRDC

Administrators → DPT Admins


## Phase 3: Machine-Side Implementation
### 5. Remove Legacy Accounts

net user CellA /delete
net user CellB /delete

### 6. Add Groups to Local Groups (if not done by GPO)

net localgroup "Administrators" "corp\\DPT Admins" /add
net localgroup "Users" "corp\\grp-machine-mfgLAC" /add


### 7. Repoint Application Shortcuts

- **Check apps do not reference CellA or CellB profile paths**
- **Update desktop/start menu shortcuts under shr-machine-mfg**


### 8. Test Login

- **Log in on all 5 machines using shr-machine-mfg**

## Confirm:

- **App access**

- **Mapped drives**

- **Print capability**

- **No roaming profile conflicts**

### 9. Finalise Drive/App Permissions

- **Add grp-machine-mfgRW to NTFS/Share permissions as needed**

### 10. Document Ownership
    Owner: [Insert Name]

- **Purpose: "Manufacturing shared login"**

- **Password rotation policy: Annual**

- **Stored securely: [Password vault]**

## Final Validation Checklist

- **Legacy CellA/CellB accounts removed**

- **shr-machine-mfg logs in successfully**

- **GPO settings applied**

### Apps and shares accessible

- **No shadow accounts remain**

- **Security groups enforce PoLP**
"""