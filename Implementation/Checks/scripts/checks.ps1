Use Get-AzureADUser -SearchString "shr-modelshop" or check Entra ID directly.

Run this to ensure groups don’t already exist (avoids shadow logic):

# Check in local AD
Get-ADGroup -Filter {Name -like "grp-modelshop*"} | Select-Object Name

# Optional: Check in Entra
Get-AzureADGroup | Where-Object { $_.DisplayName -like "grp-modelshop*" }


Your script must reference a valid OU, e.g.:

$ouPath = "OU=Groups,OU=Factory,DC=williamsf1,DC=com"


Required Permissions to Run Group Script
To successfully run the PowerShell group creation script:

You must have Domain Admin, Account Operator, or a delegated permission to:

Create security groups in the designated OU

Set group scope (usually Global or Universal depending on replication scope)

Set ManagedBy if included

For On-Prem AD Group Creation
You'll be running scripts to create:

grp-modelshopRW

grp-modelshopRO

grp-modelshopLAC

grp-modelshopRDC

Item	Description
PowerShell v5.1+	Preinstalled on Windows Server 2016+
RSAT: Active Directory Module	Required to run New-ADGroup, Get-ADGroup, etc.
Domain Admin or Delegated Rights	Must have write access to the target OU in AD
Correct OU path	E.g. OU=Groups,OU=Factory,DC=williamsf1,DC=com

Import-Module ActiveDirectory

Add-WindowsFeature RSAT-AD-PowerShell


2. For Exchange Online Shared Mailbox (Cloud)

You're creating and managing the shared mailbox:
shr-modelshop@williamsf1.com

PowerShell v5.1 or PowerShell Core	For Exchange Online Module
Exchange Online PowerShell V3	Required for Connect-ExchangeOnline, New-Mailbox, etc.
PIM Activated Role: Exchange Administrator	Must be active before running commands
Internet connectivity + MFA login	Required to connect securely

Install Module:

Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force

Connect-ExchangeOnline -UserPrincipalName paul.davidson@admin.williamsf1.com



# Must run in an elevated PowerShell session
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"



Confirm working:

Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties SamAccountName | Select-Object -First 1


Rule 6 Step – Confirm OU Before Group Creation
You must verify that this exact OU path exists:

Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=OU=Modelshop,OU=WF1-Resources,DC=Factory,DC=WF1)"

Get-ADOrganizationalUnit -Filter * | Where-Object {
    ($_.DistinguishedName -split ',').Count -eq 3
} | Select Name, DistinguishedName




Get-ADGroup -Filter * -Properties DistinguishedName |
        Select-Object Name, DistinguishedName |
        Sort-Object DistinguishedName



Get-ADGroup -Filter * -Properties DistinguishedName |
        Where-Object { $_.DistinguishedName -like "*OU=Modelshop,*" } |
        Select-Object Name, DistinguishedName |
        Sort-Object Name


Get-Mailbox -Identity "modelshop@williamsf1.com" -ErrorAction SilentlyContinue


if (Get-Mailbox -Identity "modelshop@williamsf1.com" -ErrorAction SilentlyContinue) {
    Write-Host "Shared mailbox already exists." -ForegroundColor Green
} else {
    Write-Host "Shared mailbox does not exist." -ForegroundColor Yellow
}


1. Install Exchange Online Management Module (Only Once)
Run this from elevated PowerShell (Run as Administrator):

Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Force



2. Import Module Before Use (Every Session)

Import-Module ExchangeOnlineManagement



3. Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName paul.davidson@admin.williamsf1.com



4. Run the Shared Mailbox Provisioning Script
Assuming your script is located at:

5. Confirm Mailbox Was Created
After the script runs, confirm mailbox creation:


Get-Mailbox -Identity "modelshop@williamsf1.com" | Format-List Name,PrimarySmtpAddress,RecipientTypeDetails

