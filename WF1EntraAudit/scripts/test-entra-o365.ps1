# ========================================
# Purpose: Quick check of Entra + M365 presence
# File: test-entra-o365.ps1
# ========================================

# === Connect to Microsoft Graph ===
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All" -ErrorAction Stop

# === Check for any Entra users ===
$users = Get-MgUser -Top 5
if ($users) {
    Write-Host " Entra ID users found:" -ForegroundColor Green
    $users | Select-Object DisplayName, UserPrincipalName
} else {
    Write-Host " No users found in Entra ID" -ForegroundColor Red
}

# === Check for any Entra groups ===
$groups = Get-MgGroup -Top 5
if ($groups) {
    Write-Host "`n Entra ID groups found:" -ForegroundColor Green
    $groups | Select-Object DisplayName, MailEnabled, SecurityEnabled
} else {
    Write-Host " No groups found in Entra ID" -ForegroundColor Red
}

# === Connect to Exchange Online ===
Connect-ExchangeOnline -ErrorAction Stop

# === Check for any shared mailboxes ===
$shared = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize 5
if ($shared) {
    Write-Host "`n Shared mailboxes found:" -ForegroundColor Green
    $shared | Select-Object DisplayName, PrimarySmtpAddress
} else {
    Write-Host " No shared mailboxes found" -ForegroundColor Yellow
}