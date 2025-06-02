# =============================================
# Williams F1 | Enterprise AD User Discovery
# File: /scripts/ad-user-discovery.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.7.4
# =============================================

param (
    [Parameter(Mandatory)][string]$Username
)

# === Logging & Export Setup ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = Join-Path $PSScriptRoot "..\exports\$Username"
$logFile   = Join-Path $exportDir "log_$ts.txt"
$csvFile   = Join-Path $exportDir "ad_user_summary_$ts.csv"
$jsonFile  = Join-Path $exportDir "ad_user_summary_$ts.json"
$mdFile    = Join-Path $exportDir "ad_user_summary_$ts.md"
$htmlFile  = Join-Path $exportDir "ad_user_summary_$ts.html"
$metaFile  = Join-Path $exportDir "meta_$ts.json"

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

# === Metadata Injection ===
$meta = @{
    timestamp   = $ts
    user_input  = $Username
    executed_by = $env:USERNAME
    project     = "Remediate Generic Account Risk @WF1"
    cab_ref     = "P-135901"
    github_repo = "UrbantekDev/CloudHealthLink"
}
$meta | ConvertTo-Json -Depth 3 | Set-Content -Path $metaFile -Encoding UTF8

# === Module Check ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT required)" "ERROR"
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

# === Group Membership ===
$groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}

# === OU Breakdown ===
$ouPath = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouComponents = ($ouPath -split ',') -replace '^OU=',''
$ouFull = ($ouComponents -join ' > ')

# === ACL Summary ===
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

# === GPO Discovery (Fallback OU Recursion) ===
$ouDN = ($user.DistinguishedName -split ',', 2)[1]
$gpoNames = @()
try {
    $gpoLinks = Get-GPInheritance -Target $ouDN -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GpoLinks
    $gpoNames = $gpoLinks | ForEach-Object { "$($_.DisplayName) (Enabled: $($_.Enabled))" }
} catch {
    Log "GPO Inheritance failed for OU: $ouDN" "WARN"
}

# === SID Detection ===
$sid = (New-Object System.Security.Principal.NTAccount($user.SamAccountName)).Translate([System.Security.Principal.SecurityIdentifier]).Value

# === FSLogix & Profile Info ===
$fslogixProfilePath = "\\fslogix\profiles\$Username"
$profileExists = Test-Path $fslogixProfilePath

# === Build Result Object ===
$result = [PSCustomObject]@{
    Timestamp        = $ts
    Username         = $user.SamAccountName
    SID              = $sid
    DisplayName      = $user.DisplayName
    Email            = $user.EmailAddress
    DistinguishedName= $user.DistinguishedName
    OU               = $ouFull
    Enabled          = $user.Enabled
    LastLogon        = $user.LastLogonDate
    LogonScript      = $user.ScriptPath
    ProfilePath      = $user.ProfilePath
    FSLogixDetected  = $profileExists
    Groups           = $groups
    GPOs             = $gpoNames
    ACLs             = $aclDetails
}

# === Export CSV ===
$result | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon,LogonScript,ProfilePath,FSLogixDetected |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === Export JSON ===
$result | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Export Markdown ===
$mdContent = @"
# AD Discovery Report – $Username

**Project:** Remediate Generic Account Risk @WF1
**CAB Ref:** P-135901
**Timestamp:** $ts
**OU Path:** $ouFull

## Basic Info
- **Username**: $($result.Username)
- **Display Name**: $($result.DisplayName)
- **Email**: $($result.Email)
- **Enabled**: $($result.Enabled)
- **SID**: $($result.SID)
- **Last Logon**: $($result.LastLogon)
- **Logon Script**: $($result.LogonScript)
- **Profile Path**: $($result.ProfilePath)
- **FSLogix Detected**: $($result.FSLogixDetected)

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

# === Export HTML ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<title>AD Report – $Username</title>
<style>
body { font-family: 'Segoe UI', sans-serif; background: #ffffff; color: #111; padding: 30px; }
h1 { background-color: #005aff; color: #fff; padding: 10px; }
h2, h3 { color: #005aff; }
table { border-collapse: collapse; width: 100%; margin-top: 15px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
ul { padding-left: 20px; }
</style>
</head><body>
<h1>AD Discovery Report – $Username</h1>
<p><b>Project:</b> Remediate Generic Account Risk @WF1</p>
<p><b>CAB Ref:</b> P-135901</p>
<p><b>Timestamp:</b> $ts</p>
<p><b>OU Path:</b> $ouFull</p>

<h2>Basic Info</h2>
<ul>
<li><b>Username:</b> $($result.Username)</li>
<li><b>Display Name:</b> $($result.DisplayName)</li>
<li><b>Email:</b> $($result.Email)</li>
<li><b>SID:</b> $($result.SID)</li>
<li><b>Enabled:</b> $($result.Enabled)</li>
<li><b>Last Logon:</b> $($result.LastLogon)</li>
<li><b>Logon Script:</b> $($result.LogonScript)</li>
<li><b>Profile Path:</b> $($result.ProfilePath)</li>
<li><b>FSLogix Detected:</b> $($result.FSLogixDetected)</li>
</ul>

<h2>Groups</h2>
<ul>$($groups | ForEach-Object { "<li>$_</li>" } | Out-String)</ul>

<h2>Linked GPOs</h2>
<ul>$($gpoNames | ForEach-Object { "<li>$_</li>" } | Out-String)</ul>

<h2>ACL Summary</h2>
<table><tr><th>Identity</th><th>Type</th><th>Rights</th><th>Inherited</th><th>ObjectType</th></tr>
$($aclDetails | ForEach-Object {
    "<tr><td>$($_.Identity)</td><td>$($_.Type)</td><td>$($_.Rights)</td><td>$($_.Inherited)</td><td>$($_.ObjectType)</td></tr>"
} | Out-String)
</table>
</body></html>
"@
$html | Set-Content -Path $htmlFile -Encoding UTF8

# === Completion ===
Log "AD Discovery complete for $Username" "SUCCESS"
Log "CSV     : $csvFile"
Log "JSON    : $jsonFile"
Log "Markdown: $mdFile"
Log "HTML    : $htmlFile"
Log "Meta    : $metaFile"