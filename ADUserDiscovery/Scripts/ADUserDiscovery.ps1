# ==============================================================================
# Williams F1 | Forensic AD User Discovery – Rule 6 Compliant
# File: /scripts/ad-user-discovery.ps1
# Author: Curtis-Davidson & Urbantek
# Version: 2025.7.4
# ==============================================================================
# PURPOSE:
#   Enterprise-grade Active Directory discovery for audit, tribunal, or cyber
#   investigation use. Outputs CSV, JSON, Markdown, and HTML formats with
#   CAB/GitHub project metadata and export traceability.
# ==============================================================================

param (
    [Parameter(Mandatory)][string]$Username
)

# === [1] Environment Setup ===
$ts         = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir  = Join-Path $PSScriptRoot "..\exports\$Username"
$logFile    = Join-Path $exportDir "log_$ts.txt"
$csvFile    = Join-Path $exportDir "ad_user_summary_$ts.csv"
$jsonFile   = Join-Path $exportDir "ad_user_summary_$ts.json"
$mdFile     = Join-Path $exportDir "ad_user_summary_$ts.md"
$htmlFile   = Join-Path $exportDir "ad_user_summary_$ts.html"
$metaFile   = Join-Path $exportDir "meta_project.json"

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

# === [2] CAB Metadata Injection ===
$metadata = [PSCustomObject]@{
    Project      = "Remediate Generic Account Risk @WF1"
    CaseID       = "P-135901"
    'AD Object'  = $Username
    Timestamp    = $ts
    Type         = "Generic Account Discovery Export"
    CreatedBy    = "ADUserDiscovery.ps1 v2025.7.4"
}
$metadata | ConvertTo-Json -Depth 3 | Set-Content -Path $metaFile -Encoding UTF8

# === [3] ActiveDirectory Module Load ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT required)" "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === [4] Discover User Object ===
try {
    $user = Get-ADUser -Identity $Username -Properties * -ErrorAction Stop
    Log "User located: $($user.SamAccountName)"
} catch {
    Log "User not found: $Username" "ERROR"
    exit 2
}

# === [5] Collect Metadata ===
$groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}

$ouPath       = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouComponents = ($ouPath -split ',') -replace '^OU=',''
$ouFull       = ($ouComponents -join ' > ')

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

# === [6] GPO Inheritance ===
$ouDN = ($user.DistinguishedName -split ',', 2)[1]
$gpoNames = @()
try {
    $gpoLinks = Get-GPInheritance -Target $ouDN -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GpoLinks
    $gpoNames = $gpoLinks | ForEach-Object { "$($_.DisplayName) (Enabled: $($_.Enabled))" }
} catch {
    Log "GPO Inheritance failed for OU: $ouDN" "WARN"
}

# === [7] Build Final Object ===
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
}

# === [8] Export CSV ===
$result | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === [9] Export JSON ===
$result | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === [10] Export Markdown with CAB Header ===
$mdContent = @"
---
project: Remediate Generic Account Risk @WF1
case_id: P-135901
object: $Username
generated: $ts
generated_by: ADUserDiscovery.ps1 v2025.7.4
---

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

# === [11] Export HTML with Metadata Block ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<meta name='project' content='Remediate Generic Account Risk @WF1'>
<meta name='case_id' content='P-135901'>
<meta name='generated_by' content='ADUserDiscovery.ps1 v2025.7.4'>
<meta name='username' content='$Username'>
<meta name='timestamp' content='$ts'>
<title>AD User Report – $Username</title>
<style>
body { font-family: Segoe UI; background: #f4f4f4; padding: 20px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ccc; padding: 8px; }
</style>
</head><body>
<h2>AD Discovery Report – $Username</h2>
<p><b>Timestamp:</b> $ts</p>

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

# === [12] Final Logs ===
Log "AD Discovery complete for $Username" "SUCCESS"
Log "CSV     : $csvFile"
Log "JSON    : $jsonFile"
Log "Markdown: $mdFile"
Log "HTML    : $htmlFile"
Log "Meta    : $metaFile"