# =========================================================
# Williams F1 | Enterprise AD Group Discovery (Class-based)
# File: /scripts/ADGroupDiscovery.ps1
# Author: Paul R Davidson
# Version: 2025.8.0
# =========================================================

param (
    [Parameter(Mandatory)][string]$GroupName
)

# === Setup ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = Join-Path $PSScriptRoot "..\exports\$GroupName"
New-Item -Path $exportDir -ItemType Directory -Force | Out-Null

$logFile   = Join-Path $exportDir "log_$ts.txt"
$jsonFile  = Join-Path $exportDir "group_snapshot_$ts.json"
$diffFile  = Join-Path $exportDir "diff_summary.md"
$mdFile    = Join-Path $exportDir "group_report_$ts.md"
$htmlFile  = Join-Path $exportDir "group_report_$ts.html"
$cacheFile = Join-Path $exportDir "last_snapshot.json"

function Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")] [string]$Level = "INFO"
    )
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$Level] $stamp :: $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

# === Class: ADGroupProfile ===
class ADGroupProfile {
    [string]$GroupName
    [string]$Description
    [string]$GroupScope
    [string]$GroupType
    [string[]]$Members
    [object[]]$ACLs

    ADGroupProfile([pscustomobject]$raw) {
        $this.GroupName   = $raw.GroupName
        $this.Description = $raw.Description
        $this.GroupScope  = $raw.GroupScope
        $this.GroupType   = $raw.GroupType
        $this.Members     = $raw.Members
        $this.ACLs        = $raw.ACLs
    }

    [string[]] CompareMembers([ADGroupProfile]$other) {
        return Compare-Object -ReferenceObject $this.Members -DifferenceObject $other.Members -PassThru
    }

    [string[]] CompareACLs([ADGroupProfile]$other) {
        $old = $other.ACLs | ConvertTo-Json -Depth 5
        $new = $this.ACLs  | ConvertTo-Json -Depth 5
        if ($old -ne $new) { return @("ACLs changed") }
        return @()
    }
}

# === Import AD Module ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing ActiveDirectory RSAT module" "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === Fetch Group Info ===
try {
    $group = Get-ADGroup -Identity $GroupName -Properties * -ErrorAction Stop
    Log "Group found: $GroupName"
} catch {
    Log "Group not found: $GroupName" "ERROR"
    exit 2
}

# === Resolve Members Recursively ===
function Resolve-GroupMembers {
    param ([string]$DN)
    $members = @()
    $queue = @($DN)
    while ($queue.Count -gt 0) {
        $current = $queue[0]
        $queue = $queue[1..($queue.Count - 1)]
        $entries = Get-ADGroupMember -Identity $current -ErrorAction SilentlyContinue
        foreach ($entry in $entries) {
            if ($entry.objectClass -eq "group") {
                $queue += $entry.DistinguishedName
                $members += "$($entry.Name) (Group)"
            } else {
                $members += "$($entry.SamAccountName) (User)"
            }
        }
    }
    return $members | Sort-Object -Unique
}
$resolvedMembers = Resolve-GroupMembers -DN $group.DistinguishedName

# === Get ACLs ===
$aclData = @()
try {
    $gacl = Get-Acl -Path ("AD:\" + $group.DistinguishedName)
    $aclData = $gacl.Access | ForEach-Object {
        [PSCustomObject]@{
            Identity   = $_.IdentityReference
            Rights     = $_.ActiveDirectoryRights
            Type       = $_.AccessControlType
            Inherited  = $_.IsInherited
            ObjectType = $_.ObjectType
        }
    }
} catch {
    Log "Failed to retrieve ACLs for group" "WARN"
}

# === Construct Object ===
$rawGroup = [pscustomobject]@{
    GroupName   = $group.Name
    Description = $group.Description
    GroupScope  = $group.GroupScope
    GroupType   = $group.GroupCategory
    Members     = $resolvedMembers
    ACLs        = $aclData
}
$currentProfile = [ADGroupProfile]::new($rawGroup)
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Compare with Previous Snapshot ===
if (Test-Path $cacheFile) {
    $previous = Get-Content $cacheFile | ConvertFrom-Json
    $oldProfile = [ADGroupProfile]::new($previous)
    $diffs = @()
    $diffs += $currentProfile.CompareMembers($oldProfile)
    $diffs += $currentProfile.CompareACLs($oldProfile)

    if ($diffs.Count -gt 0) {
        Log "Changes detected since last run" "WARN"
        $diffs | Set-Content -Path $diffFile -Encoding UTF8
    } else {
        Log "No changes detected"
    }
}
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $cacheFile -Encoding UTF8

# === Markdown Export ===
$md = @"
# AD Group Report – $GroupName

**Timestamp:** $ts
**Description:** $($group.Description)
**Scope:** $($group.GroupScope)
**Type:** $($group.GroupCategory)

## Members
$($resolvedMembers | ForEach-Object { "- $_" } | Out-String)

## ACL Summary
| Identity | Rights | Type | Inherited | ObjectType |
|----------|--------|------|-----------|------------|
$($aclData | ForEach-Object {
    "| $($_.Identity) | $($_.Rights) | $($_.Type) | $($_.Inherited) | $($_.ObjectType) |"
} | Out-String)
"@
$md | Set-Content -Path $mdFile -Encoding UTF8

# === HTML Export ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<title>AD Group Report – $GroupName</title>
<style>
body { font-family: sans-serif; padding: 20px; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
</style></head><body>
<h1>AD Group Report – $GroupName</h1>
<p><b>Timestamp:</b> $ts</p>
<p><b>Description:</b> $($group.Description)</p>
<p><b>Scope:</b> $($group.GroupScope)</p>
<p><b>Type:</b> $($group.GroupCategory)</p>

<h2>Members</h2>
<ul>$($resolvedMembers | ForEach-Object { "<li>$_</li>" } | Out-String)</ul>

<h2>ACL Summary</h2>
<table><tr><th>Identity</th><th>Rights</th><th>Type</th><th>Inherited</th><th>ObjectType</th></tr>
$($aclData | ForEach-Object {
    "<tr><td>$($_.Identity)</td><td>$($_.Rights)</td><td>$($_.Type)</td><td>$($_.Inherited)</td><td>$($_.ObjectType)</td></tr>"
} | Out-String)
</table>
</body></html>
"@
$html | Set-Content -Path $htmlFile -Encoding UTF8

# === Done ===
Log "AD Group discovery complete for $GroupName" "SUCCESS"