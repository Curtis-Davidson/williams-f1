<#
===============================================================================
 Script:       create-shared-mailbox-modelshop.ps1
 Purpose:      Creates Exchange shared mailbox for shr-modelshop and assigns
               group-based access following WN-FR9041 guidance
 Author:       Paul R Davidson
 Contact:      paul@urbantek.com
 Organisation: Urbantek
 Version:      2025.06.11
 Location:     implementation/mail/create-shared-mailbox-modelshop.ps1
===============================================================================
#>

# === Connect to Exchange Online ===
Write-Host "`n Connecting to Exchange Online..."
Connect-ExchangeOnline -ErrorAction Stop

# === Variables ===
$mailboxName     = "shr-modelshop"
$mailboxDisplay  = "Modelshop Shared Mailbox"
$mailboxAlias    = "shr-modelshop"
$mailboxEmail    = "modelshop@williamsf1.com"

$rwGroup         = "grp-modelshopRW"
$roGroup         = "grp-modelshopRO"

# === Create Mailbox ===
Write-Host "`n Creating shared mailbox: $mailboxEmail ..."
New-Mailbox -Name $mailboxName `
            -DisplayName $mailboxDisplay `
            -Alias $mailboxAlias `
            -Shared `
            -PrimarySmtpAddress $mailboxEmail

# === Assign FullAccess to RW Group ===
Write-Host "`n Assigning FullAccess to $rwGroup with AutoMapping ON..."
Add-MailboxPermission -Identity $mailboxEmail `
                      -User $rwGroup `
                      -AccessRights FullAccess `
                      -InheritanceType All `
                      -AutoMapping:$true

# === Assign Send on Behalf rights to RW Group ===
Write-Host "`n Granting SendOnBehalf rights to $rwGroup..."
Set-Mailbox -Identity $mailboxEmail -GrantSendOnBehalfTo $rwGroup

# === Assign FullAccess to RO Group (no send) ===
Write-Host "`n Assigning FullAccess to $roGroup with AutoMapping OFF..."
Add-MailboxPermission -Identity $mailboxEmail `
                      -User $roGroup `
                      -AccessRights FullAccess `
                      -InheritanceType All `
                      -AutoMapping:$false

# === Optional: Audit / Compliance Enhancements ===
Write-Host "`n Ensuring mailbox is visible in address lists (unhidden)..."
Set-Mailbox -Identity $mailboxEmail -HiddenFromAddressListsEnabled $false

Write-Host "`n Setting custom description attribute for audit trace..."
Set-Mailbox -Identity $mailboxEmail -CustomAttribute1 "Modelshop Shared Mailbox for factory"

# === Verification Output ===
Write-Host "`n Verifying mailbox configuration..."
Get-Mailbox $mailboxEmail | Format-List Name,PrimarySmtpAddress,RecipientTypeDetails,HiddenFromAddressListsEnabled,CustomAttribute1

Write-Host "`n Listing group mailbox permissions..."
Get-MailboxPermission $mailboxEmail | Where-Object { $_.User -like "grp-*" }

Write-Host "`n Checking SendOnBehalf delegation..."
Get-Mailbox | Where-Object { $_.Name -eq $mailboxName } | Select-Object Name,GrantSendOnBehalfTo

# === Disconnect Session ===
Write-Host "`n Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline -Confirm:$false

Write-Host "`n Mailbox provisioning complete. Modelshop is ready.`n"
