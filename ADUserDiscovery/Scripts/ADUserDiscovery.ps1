# =========================================================
# Williams F1 | Enterprise AD User Discovery (Class-based)
# File: /scripts/ADUserDiscovery.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.8.0
# =========================================================

param (
    [Parameter(Mandatory)][string]$Username
)

# === Setup & Logging ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = Join-Path $PSScriptRoot "..\exports\$Username"
New-Item -Path $exportDir -ItemType Directory -Force | Out-Null

$logFile   = Join-Path $exportDir "log_$ts.txt"
$csvFile   = Join-Path $exportDir "ad_user_summary_$ts.csv"
$jsonFile  = Join-Path $exportDir "ad_user_summary_$ts.json"
$mdFile    = Join-Path $exportDir "ad_user_summary_$ts.md"
$htmlFile  = Join-Path $exportDir "ad_user_summary_$ts.html"
$diffFile  = Join-Path $exportDir "diff_summary.md"
$metaFile  = Join-Path $exportDir "meta_$ts.json"
$cacheFile = Join-Path $exportDir "last_snapshot.json"

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

# === Metadata Export ===
$meta = @{
    timestamp   = $ts
    user_input  = $Username
    executed_by = $env:USERNAME
    project     = "Remediate Generic Account Risk @WF1"
    cab_ref     = "P-135901"
    github_repo = "UrbantekDev/CloudHealthLink"
}
$meta | ConvertTo-Json -Depth 3 | Set-Content -Path $metaFile -Encoding UTF8

# === Prerequisite Check ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT required)" "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === Define ADUserProfile Class ===
class ADUserProfile {
    [string]$Username
    [string]$SID
    [string]$DisplayName
    [string]$Email
    [string]$OU
    [bool]$Enabled
    [datetime]$LastLogon
    [string]$LogonScript
    [string]$ProfilePath
    [bool]$FSLogixDetected
    [string[]]$Groups
    [string[]]$GPOs
    [object[]]$ACLs

    ADUserProfile([pscustomobject]$raw) {
        $this.Username         = $raw.Username
        $this.SID              = $raw.SID
        $this.DisplayName      = $raw.DisplayName
        $this.Email            = $raw.Email
        $this.OU               = $raw.OU
        $this.Enabled          = $raw.Enabled
        $this.LastLogon        = $raw.LastLogon
        $this.LogonScript      = $raw.LogonScript
        $this.ProfilePath      = $raw.ProfilePath
        $this.FSLogixDetected  = $raw.FSLogixDetected
        $this.Groups           = $raw.Groups
        $this.GPOs             = $raw.GPOs
        $this.ACLs             = $raw.ACLs
    }

    [string[]] CompareGroups([ADUserProfile]$other) {
        return Compare-Object -ReferenceObject $this.Groups -DifferenceObject $other.Groups -PassThru
    }

    [string[]] CompareGPOs([ADUserProfile]$other) {
        return Compare-Object -ReferenceObject $this.GPOs -DifferenceObject $other.GPOs -PassThru
    }

    [string[]] CompareOU([ADUserProfile]$other) {
        if ($this.OU -ne $other.OU) { return @("OU changed from '$($other.OU)' to '$($this.OU)'") }
        return @()
    }

    [string[]] CompareACLs([ADUserProfile]$other) {
        $oldACLs = $other.ACLs | ConvertTo-Json -Depth 5
        $newACLs = $this.ACLs  | ConvertTo-Json -Depth 5
        if ($oldACLs -ne $newACLs) { return @("ACLs changed") }
        return @()
    }
}

# === Pull AD Data ===
try {
    $user = Get-ADUser -Identity $Username -Properties * -ErrorAction Stop
    Log "User found: $($user.SamAccountName)"
} catch {
    Log "User not found: $Username" "ERROR"
    exit 2
}

$ouPath = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouFull = ($ouPath -split ',') -replace '^OU='''',''' -join ' > '
$sid = (New-Object System.Security.Principal.NTAccount($user.SamAccountName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$fslogixProfilePath = "\\fslogix\profiles\$Username"
$profileExists = Test-Path $fslogixProfilePath

$groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}

try {
    $ouDN = ($user.DistinguishedName -split ',', 2)[1]
    $gpoLinks = Get-GPInheritance -Target $ouDN -ErrorAction Stop | Select-Object -ExpandProperty GpoLinks
    $gpoNames = $gpoLinks | ForEach-Object { "$($_.DisplayName) (Enabled: $($_.Enabled))" }
} catch {
    $gpoNames = @()
    Log "Failed to get GPO inheritance for $ouDN" "WARN"
}

$aclDetails = @()
try {
    $userAcl = Get-Acl -Path ("AD:\" + $user.DistinguishedName)
    $aclDetails = $userAcl.Access | ForEach-Object {
        [PSCustomObject]@{
            Identity    = $_.IdentityReference
            Type        = $_.AccessControlType
            Rights      = $_.ActiveDirectoryRights
            Inherited   = $_.IsInherited
            ObjectType  = $_.ObjectType
        }
    }
} catch {
    Log "ACL extraction failed" "WARN"
}

# === Build and Export Object ===
$rawResult = [PSCustomObject]@{
    Timestamp        = $ts
    Username         = $user.SamAccountName
    SID              = $sid
    DisplayName      = $user.DisplayName
    Email            = $user.EmailAddress
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
$currentProfile = [ADUserProfile]::new($rawResult)

# === Export JSON ===
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Compare with Previous Run (if exists) ===
if (Test-Path $cacheFile) {
    $previous = Get-Content -Path $cacheFile | ConvertFrom-Json
    $oldProfile = [ADUserProfile]::new($previous)
    $diffs = @()
    $diffs += $currentProfile.CompareGroups($oldProfile)
    $diffs += $currentProfile.CompareGPOs($oldProfile)
    $diffs += $currentProfile.CompareACLs($oldProfile)
    $diffs += $currentProfile.CompareOU($oldProfile)

    if ($diffs.Count -gt 0) {
        Log "Changes detected since last run." "WARN"
        $diffs | Set-Content -Path $diffFile -Encoding UTF8
    } else {
        Log "No differences detected since last snapshot."
    }
}
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $cacheFile -Encoding UTF8

# === Export CSV ===
$currentProfile | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon,LogonScript,ProfilePath,FSLogixDetected |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === Export Markdown ===
$mdContent = @"
# AD Discovery Report – $Username

**Project:** Remediate Generic Account Risk @WF1
**CAB Ref:** P-135901
**Timestamp:** $ts
**OU Path:** $ouFull

## Basic Info
- **Username**: $($currentProfile.Username)
- **Display Name**: $($currentProfile.DisplayName)
- **Email**: $($currentProfile.Email)
- **Enabled**: $($currentProfile.Enabled)
- **SID**: $($currentProfile.SID)
- **Last Logon**: $($currentProfile.LastLogon)
- **Logon Script**: $($currentProfile.LogonScript)
- **Profile Path**: $($currentProfile.ProfilePath)
- **FSLogix Detected**: $($currentProfile.FSLogixDetected)

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
<li><b>Username:</b> $($currentProfile.Username)</li>
<li><b>Display Name:</b> $($currentProfile.DisplayName)</li>
<li><b>Email:</b> $($currentProfile.Email)</li>
<li><b>SID:</b> $($currentProfile.SID)</li>
<li><b>Enabled:</b> $($currentProfile.Enabled)</li>
<li><b>Last Logon:</b> $($currentProfile.LastLogon)</li>
<li><b>Logon Script:</b> $($currentProfile.LogonScript)</li>
<li><b>Profile Path:</b> $($currentProfile.ProfilePath)</li>
<li><b>FSLogix Detected:</b> $($currentProfile.FSLogixDetected)</li>
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