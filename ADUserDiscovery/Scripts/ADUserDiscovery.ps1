# =============================================
# Williams F1 | Enhanced AD User Discovery
# File: /ADUserDiscovery/Scripts/ADUserDiscovery.ps1
# Author: Curtis-Davidson & Urbantek
# Version: 2025.7.3
# =============================================

param (
    [Parameter(Mandatory)][string]$Username,
    [switch]$SimulateDisable
)

# === Logging & Export Setup ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = Join-Path $PSScriptRoot "..\exports\$Username"
$logFile   = Join-Path $exportDir "log_$ts.txt"
$csvFile   = Join-Path $exportDir "ad_user_summary_$ts.csv"
$jsonFile  = Join-Path $exportDir "ad_user_summary_$ts.json"
$mdFile    = Join-Path $exportDir "ad_user_summary_$ts.md"
$htmlFile  = Join-Path $exportDir "ad_user_summary_$ts.html"
$metaFile  = Join-Path $exportDir "meta_project.json"

New-Item -Path $exportDir -ItemType Directory -Force | Out-Null

function Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")] [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$Level] $timestamp :: $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

# === Module Check ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT required)" "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === User Lookup ===
try {
    $user = Get-ADUser -Identity $Username -Properties * -ErrorAction Stop
    Log "User located: $($user.SamAccountName)"
} catch {
    Log "User not found: $Username" "ERROR"
    exit 2
}

# === Group Membership ===
$groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}

# === OU Breakdown ===
$ouPath = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouComponents = ($ouPath -split ',') -replace '^OU=',''
$ouFull = ($ouComponents -join ' > ')

# === ACL Discovery ===
$acls = Get-Acl -Path ("AD:\$($user.DistinguishedName)")
$aclDetails = $acls.Access | ForEach-Object {
    [PSCustomObject]@{
        Identity   = $_.IdentityReference
        Type       = $_.AccessControlType
        Rights     = $_.ActiveDirectoryRights
        Inherited  = $_.IsInherited
        ObjectType = $_.ObjectType
    }
}

# === GPO Discovery ===
$ouDN = ($user.DistinguishedName -split ',', 2)[1]
$gpoNames = @()
try {
    $gpoLinks = Get-GPInheritance -Target $ouDN -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GpoLinks
    $gpoNames = $gpoLinks | ForEach-Object { "$($_.DisplayName) (Enabled: $($_.Enabled))" }
} catch {
    Log "GPO Inheritance lookup failed for OU: $ouDN" "WARN"
}

# === Simulation Warning (What would break if disabled) ===
if ($SimulateDisable) {
    Log "Simulation: You requested a dry-run disable check" "INFO"
    Log "Groups impacting critical systems:" "INFO"
    $groups | Where-Object { $_ -match 'Admin|Critical|Remote|Delegation|VDI' } | ForEach-Object {
        Log " -> $($_)" "WARN"
    }
}

# === Build Export Object ===
$result = [PSCustomObject]@{
    Timestamp         = $ts
    Username          = $user.SamAccountName
    DisplayName       = $user.DisplayName
    Email             = $user.EmailAddress
    DistinguishedName = $user.DistinguishedName
    OU                = $ouFull
    Enabled           = $user.Enabled
    LastLogon         = $user.LastLogonDate
    Groups            = $groups
    GPOs              = $gpoNames
    ACLs              = $aclDetails
    Notes             = "Tagged for: Remediate Generic Account Risk @WF1 | P-135901"
    SimulateDisable   = $SimulateDisable.IsPresent
}

# === Export: CSV ===
$result | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === Export: JSON ===
$result | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Export: Markdown ===
$mdContent = @"
# AD Discovery Report – $Username

**Timestamp:** $ts
**OU Path:** $ouFull
**CAB Ref:** P-135901
**Project:** Remediate Generic Account Risk @WF1
**Simulate Disable Mode:** $($SimulateDisable.IsPresent)

## Basic Info
- **Username**: $($result.Username)
- **Display Name**: $($result.DisplayName)
- **Email**: $($result.Email)
- **Enabled**: $($result.Enabled)
- **Last Logon**: $($result.LastLogon)

## Groups
$($groups | ForEach-Object { "- $_" } | Out-String)

## Linked GPOs
$($gpoNames | ForEach-Object { "- $_" } | Out-String)

## ACL Summary
| Identity | Type | Rights | Inherited | ObjectType |
|----------|------|--------|-----------|------------|
$($aclDetails | ForEach-Object {
    "| $($_.Identity) | $($_.Type) | $($_.Rights) | $($_.Inherited) | $($_.ObjectType) |"
} | Out-String)
"@
$mdContent | Set-Content -Path $mdFile -Encoding UTF8

# === Export: HTML ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<title>AD User Report – $Username</title>
<style>
body { font-family: Segoe UI; background: #f4f4f4; padding: 20px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ccc; padding: 8px; }
</style></head><body>
<h2>AD Discovery Report – $Username</h2>
<p><b>Timestamp:</b> $ts</p>
<p><b>Project:</b> Remediate Generic Account Risk @WF1</p>
<p><b>CAB Ref:</b> P-135901</p>
<p><b>OU Path:</b> $ouFull</p>
<p><b>Simulate Disable:</b> $($SimulateDisable.IsPresent)</p>

<h3>Groups</h3><ul>
$($groups | ForEach-Object { "<li>$_</li>" } | Out-String)
</ul>

<h3>Linked GPOs</h3><ul>
$($gpoNames | ForEach-Object { "<li>$_</li>" } | Out-String)
</ul>

<h3>ACL Summary</h3>
<table><tr><th>Identity</th><th>Type</th><th>Rights</th><th>Inherited</th><th>ObjectType</th></tr>
$($aclDetails | ForEach-Object {
    "<tr><td>$($_.Identity)</td><td>$($_.Type)</td><td>$($_.Rights)</td><td>$($_.Inherited)</td><td>$($_.ObjectType)</td></tr>"
} | Out-String)
</table>
</body></html>
"@
$html | Set-Content -Path $htmlFile -Encoding UTF8

# === Project Metadata (Optional) ===
$meta = [PSCustomObject]@{
    Project       = "WilliamsF1"
    CAB_Ref       = "P-135901"
    Purpose       = "Remediation & Audit of Generic AD Account Usage"
    Author        = "Curtis-Davidson"
    Exports       = @($csvFile, $jsonFile, $mdFile, $htmlFile)
    Simulation    = $SimulateDisable.IsPresent
    Timestamp     = $ts
    TargetUser    = $Username
}
$meta | ConvertTo-Json -Depth 4 | Set-Content -Path $metaFile -Encoding UTF8

# === Completion ===
Log "AD Discovery complete for $Username" "SUCCESS"
Log "CSV     : $csvFile"
Log "JSON    : $jsonFile"
Log "Markdown: $mdFile"
Log "HTML    : $htmlFile"
Log "Meta    : $metaFile"