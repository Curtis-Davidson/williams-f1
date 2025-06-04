# ==================================================================
# Williams F1 | Enterprise AD Group Discovery – Canonical Edition
# File: /scripts/ADGroupDiscovery.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.9.0
# Purpose: Department-agnostic AD group auditing with ACL diffing
# ==================================================================

param (
    [Parameter(Mandatory)][string]$GroupName
)

# === Setup paths ===
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

# === Define ADGroupProfile class ===
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

# === Pre-flight checks ===
if (-not (Get-Command Get-ADGroup -ErrorAction SilentlyContinue)) {
    Log "ActiveDirectory module not available. RSAT tools missing." "ERROR"
    exit 1
}

# === Load AD module ===
Import-Module ActiveDirectory -ErrorAction Stop

# === Resolve Group ===
try {
    $group = Get-ADGroup -Identity $GroupName -Properties * -ErrorAction Stop
    Log "Found AD group: $GroupName"
} catch {
    Log "Group not found: $GroupName" "ERROR"
    exit 2
}

# === Resolve members recursively with depth guard ===
function Resolve-GroupMembers {
    param (
        [string]$DN,
        [int]$MaxDepth = 5
    )
    $members = @()
    $queue = @(@{DN = $DN; Depth = 0})

    while ($queue.Count -gt 0) {
        $item = $queue[0]
        $queue = $queue[1..($queue.Count - 1)]

        if ($item.Depth -ge $MaxDepth) {
            Log "Max depth reached: $($item.DN)" "WARN"
            continue
        }

        $entries = Get-ADGroupMember -Identity $item.DN -ErrorAction SilentlyContinue
        foreach ($entry in $entries) {
            if ($entry.objectClass -eq "group") {
                $queue += @{DN = $entry.DistinguishedName; Depth = $item.Depth + 1}
                $members += "$($entry.Name) (Group)"
            } else {
                $members += "$($entry.SamAccountName) (User)"
            }
        }
    }
    return $members | Sort-Object -Unique
}
$resolvedMembers = Resolve-GroupMembers -DN $group.DistinguishedName

# === Get ACLs (timeout-wrapped) ===
$aclData = @()
try {
    $aclPath = "AD:\" + $group.DistinguishedName
    $job = Start-Job { param($p) Get-Acl -Path $p } -ArgumentList $aclPath
    $completed = $job | Wait-Job -Timeout 5
    if ($completed) {
        $gacl = Receive-Job $job
        $aclData = $gacl.Access | ForEach-Object {
            [PSCustomObject]@{
                Identity   = $_.IdentityReference
                Rights     = $_.ActiveDirectoryRights
                Type       = $_.AccessControlType
                Inherited  = $_.IsInherited
                ObjectType = $_.ObjectType
            }
        }
    } else {
        Log "ACL query timed out. Skipping ACL data." "WARN"
    }
    Remove-Job $job -Force
} catch {
    Log "ACL extraction failed." "WARN"
}

# === Build profile object ===
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

# === Compare snapshot ===
if (Test-Path $cacheFile) {
    $previous = Get-Content $cacheFile | ConvertFrom-Json
    $oldProfile = [ADGroupProfile]::new($previous)
    $diffs = @()
    $diffs += $currentProfile.CompareMembers($oldProfile)
    $diffs += $currentProfile.CompareACLs($oldProfile)

    if ($diffs.Count -gt 0) {
        Log "Differences found since last snapshot." "WARN"
        $diffs | ForEach-Object { "* $_" } | Set-Content -Path $diffFile -Encoding UTF8
    } else {
        Log "No differences detected."
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

Log "AD Group Audit complete for $GroupName" "SUCCESS"