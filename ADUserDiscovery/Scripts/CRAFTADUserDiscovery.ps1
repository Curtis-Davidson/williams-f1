# =============================================
# Williams F1 | Enhanced AD User Discovery
# File: /scripts/ad-user-discovery.ps1
# Author: Curtis-Davidson & Urbantek
# Version: 2025.7.1
# Purpose: Full Active Directory enumeration for a given user, CAB export-ready
# =============================================

param (
    [Parameter(Mandatory)][string]$Username
)

# === Logging & Export Setup ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = "$PSScriptRoot\..\exports\$Username"
$logFile   = "$exportDir\log_$ts.txt"
$csvFile   = "$exportDir\ad_user_summary_$ts.csv"
$jsonFile  = "$exportDir\ad_user_summary_$ts.json"
$mdFile    = "$exportDir\ad_user_summary_$ts.md"
$htmlFile  = "$exportDir\ad_user_summary_$ts.html"

New-Item -Path $exportDir -ItemType Directory -Force | Out-Null

function Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")] [string]$Level = "INFO"
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$Level] $ts :: $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

# === Module Check ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT)." "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === Lookup User ===
try {
    $user = Get-ADUser -Identity $Username -Properties * -ErrorAction Stop
    Log "User located: $($user.SamAccountName)"
} catch {
    Log "User not found: $Username" "ERROR"
    exit 2
}

# === Collect Metadata ===
$groups = (Get-ADUser $Username -Properties MemberOf).MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}
$ouPath = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouComponents = ($ouPath -split ',') -replace '^OU=',''
$ouFull = ($ouComponents -join ' > ')

# === ACL Discovery ===
$acls = Get-Acl -Path ("AD:\$($user.DistinguishedName)")
$aclDetails = $acls.Access | ForEach-Object {
    [PSCustomObject]@{
        Identity       = $_.IdentityReference
        Type           = $_.AccessControlType
        Rights         = $_.ActiveDirectoryRights
        Inherited      = $_.IsInherited
        ObjectType     = $_.ObjectType
    }
}

# === GPO Discovery via OU (Recursive) ===
$ouObject = Get-ADObject -Identity "LDAP://$ouPath" -Properties distinguishedName -ErrorAction SilentlyContinue
$gpoLinks = if ($ouObject) {
    Get-GPInheritance -Target $ouObject.DistinguishedName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GpoLinks
} else { @() }

$gpoNames = $gpoLinks | ForEach-Object {
    "$($_.DisplayName) (Enabled: $($_.Enabled))"
}

# === Build Output Object ===
$result = [PSCustomObject]@{
    Timestamp        = $ts
    Username         = $user.SamAccountName
    DisplayName      = $user.DisplayName
    Email            = $user.EmailAddress
    DistinguishedName= $user.DistinguishedName
    OU               = $ouFull
    Enabled          = $user.Enabled
    LastLogon        = $user.LastLogonDate
    Groups           = $groups
    GPOs             = $gpoNames
    ACLs             = $aclDetails
}

# === Export: CSV ===
$result | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === Export: JSON ===
$result | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Export: Markdown ===
@"
# AD Discovery Report – $Username

**Timestamp:** $ts
**OU Path:** $ouFull

## Basic Info
- **Username**: $($result.Username)
- **Display Name**: $($result.DisplayName)
- **Email**: $($result.Email)
- **Enabled**: $($result.Enabled)
- **Last Logon**: $($result.LastLogon)

## Groups
$(($groups | ForEach-Object { "- $_" }) -join "`n")

## Linked GPOs
$(($gpoNames | ForEach-Object { "- $_" }) -join "`n")

## ACL Summary
| Identity | Type | Rights | Inherited | ObjectType |
|----------|------|--------|-----------|------------|
$($aclDetails | ForEach-Object {
    "| $($_.Identity) | $($_.Type) | $($_.Rights) | $($_.Inherited) | $($_.ObjectType) |"
} -join "`n")
"@ | Out-File -FilePath $mdFile -Encoding UTF8

# === Export: HTML ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<title>AD User Report – $Username</title>
<style>body {font-family:Segoe UI;background:#f4f4f4;padding:20px;} table{border-collapse:collapse;width:100%} th,td{border:1px solid #ccc;padding:8px}</style>
</head><body>
<h2>AD Discovery Report – $Username</h2>
<p><b>Timestamp:</b> $ts</p>
<h3>Groups</h3><ul>
$($groups | ForEach-Object { "<li>$_</li>" } -join "`n")
</ul>
<h3>Linked GPOs</h3><ul>
$($gpoNames | ForEach-Object { "<li>$_</li>" } -join "`n")
</ul>
<h3>ACL Summary</h3>
<table><tr><th>Identity</th><th>Type</th><th>Rights</th><th>Inherited</th><th>ObjectType</th></tr>
$($aclDetails | ForEach-Object {
    "<tr><td>$($_.Identity)</td><td>$($_.Type)</td><td>$($_.Rights)</td><td>$($_.Inherited)</td><td>$($_.ObjectType)</td></tr>"
})
</table>
</body></html>
"@
$html | Out-File -FilePath $htmlFile -Encoding UTF8

# === Completion ===
Log "AD Discovery complete for $Username" "SUCCESS"
Log "CSV     : $csvFile"
Log "JSON    : $jsonFile"
Log "Markdown: $mdFile"
Log "HTML    : $htmlFile"