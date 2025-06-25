Markdown file content, fully aligned to Rule 6 and enterprise-grade AD best practices for implementing the shr-modelshop shared account strategy.


#  shr-modelshop – Shared Account AD Implementation Plan
**Author:** Microsoft Systems Architect  
**Client:** Williams F1 – Modelshop  
**Date:** 2025-06-17  
**Version:** 1.0  
**Purpose:** Strategic implementation of a shared account for secure access control, replacing legacy `modelshop` generic use.

---

##  Overview

This document defines the **step-by-step Active Directory and Governance implementation** for the `shr-modelshop` shared account, including:

- Account creation and M365 integration
- AD group structure (RW, RO, LAC, RDC)
- Device login and RDP restrictions
- Governance, documentation, and password lifecycle

---

## 🔹 Step 1: Create Shared AD User – `shr-modelshop`

**Path:** `OU=SharedAccounts,DC=factory,DC=wf1`

```

## powershell

New-ADUser -Name "shr-modelshop" `
           -SamAccountName "shr-modelshop" `
           -UserPrincipalName "shr-modelshop@williamsf1.com" `
           -Path "OU=SharedAccounts,DC=factory,DC=wf1" `
           -DisplayName "Modelshop Shared Account" `
           -Description "Shared account for Modelshop team operations" `
           -AccountPassword (Read-Host -AsSecureString "Set initial password") `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true `
           -UserMustChangePassword $false
🔹 Step 2: Create Required AD Groups
Path: OU=SecurityGroups,DC=factory,DC=wf1

powershell
Copy
Edit
New-ADGroup -Name "grp-modelshopRW" -GroupScope Global -GroupCategory Security -Description "RW Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopRO" -GroupScope Global -GroupCategory Security -Description "RO Access to Modelshop Network Resources"
New-ADGroup -Name "grp-modelshopLAC" -GroupScope Global -GroupCategory Security -Description "Login Access Control for shr-modelshop"
New-ADGroup -Name "grp-modelshopRDC" -GroupScope Global -GroupCategory Security -Description "Remote Desktop Control to Category 8 Devices"
🔹 Step 3: Assign Group Memberships
powershell
Copy
Edit
Add-ADGroupMember -Identity "grp-modelshopRW" -Members "shr-modelshop"
Add-ADGroupMember -Identity "grp-modelshopLAC" -Members "shr-modelshop"

# Add named users to RDC group
$rdcUsers = @("mark.peers", "julian.davies")
$rdcUsers | ForEach-Object { Add-ADGroupMember -Identity "grp-modelshopRDC" -Members $_ }
🔹 Step 4: Enforce Local Login Restrictions via GPO
GPO: WF1-Modelshop-Device-LAC

Allow log on locally → grp-modelshopLAC, Administrators

Deny log on locally → remove modelshop

Use Restricted Groups to remove all legacy local admins

🔹 Step 5: Restrict RDP Access to Category 8 Devices
GPO: WF1-Modelshop-RDC-Access

Allow log on through Remote Desktop Services → grp-modelshopRDC, DPT-Admin

Confirm service enabled:

powershell
Copy
Edit
(Get-WmiObject -Class Win32_TerminalServiceSetting).AllowTSConnections
🔹 Step 6: Identity Governance & AD Metadata
powershell
Copy
Edit
Set-ADUser -Identity "shr-modelshop" `
    -Add @{
        info="Business Owner: Mark Peers; Must update password annually; Use IT vault on change"
        description="Modelshop shared account for Category 8 device access and shared workflows"
    }
Enforce password update every 12 months via GPO or CA

Store in approved IT password vault (e.g., 1Password)

Require secure vault update on password change

🔹 Step 7: Validation Procedure
Action	Expectation
Login to Category 8 device with shr-modelshop	✅ Success
Login to Category 3 device with shr-modelshop	❌ Blocked
RDP as unapproved user	❌ Blocked
RDP as mark.peers	✅ Success
Shared drives and apps	✅ Accessible
modelshop login	❌ Disabled

 Result
shr-modelshop fully compliant, secure shared account

Only approved devices and users allowed

Full PoLP enforcement via AD and GPO

















