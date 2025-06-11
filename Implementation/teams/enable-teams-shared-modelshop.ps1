<#
===============================================================================
 Script:       enable-teams-shared-modelshop.ps1
 Purpose:      Enable Teams calendar integration for Modelshop shared mailbox
 Author:       Paul R Davidson
 Contact:      paul@urbantek.com
 Organisation: Urbantek
===============================================================================
#>

# === Connect to Exchange Online ===
Connect-ExchangeOnline -ErrorAction Stop

# === Enable Calendar Processing for Teams ===
Set-CalendarProcessing -Identity "modelshop@williamsf1.com" `
                       -AutomateProcessing AutoAccept `
                       -AddOrganizerToSubject $false `
                       -AllowConflicts $false `
                       -BookingWindowInDays 180 `
                       -DeleteComments $false `
                       -DeleteSubject $false `
                       -RemovePrivateProperty $false

# === Enable Mailbox for Teams Visibility ===
Set-Mailbox -Identity "modelshop@williamsf1.com" `
            -Type Shared `
            -MessageCopyForSendOnBehalfEnabled $true

# === Optional: Enable M365 Group if future Teams channel required ===
# New-UnifiedGroup -DisplayName "Modelshop Team" -Alias "modelshop-team" ...

# === Disconnect ===
Disconnect-ExchangeOnline -Confirm:$false
