# ==================================================================
# Williams F1 | GroupDeepAudit.ps1 – Canonical Group Insight Extractor
# File: /scripts/GroupDeepAudit.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.9.1
# ==================================================================

# Prompt for group name interactively
param (
    [string]$GroupName = $(Read-Host -Prompt "Enter AD Group Name")
)

# === Setup Paths ===
$ts         = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportBase = Join-Path $PSScriptRoot "..\exports\$GroupName"
New-Item -Path $exportBase -ItemType Directory -Force | Out-Null

$logFile   = Join-Path $exportBase "log_$ts.txt"
$jsonFile  = Join-Path $exportBase "snapshot_$ts.json"
$diffFile  = Join-Path $exportBase "diff_summary.md"
$mdFile    = Join-Path $exportBase "report_$ts.md"
$htmlFile  = Join-Path $exportBase "report_$ts.html"
$cacheFile = Join-Path $exportBase "last_snapshot.json"

function Log {
    param ([string]$Message, [ValidateSet("INFO","WARN","ERROR","SUCCESS")][string]$Level = "INFO")
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$Level] $stamp :: $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

# === Check Prereqs ===
if (-not (Get-Command Get-ADGroup -ErrorAction SilentlyContinue)) {
    Log "ActiveDirectory module is missing. Install RSAT tools." "ERROR"
    exit 1
}
Import-Module ActiveDirectory -ErrorAction Stop

# === Class Definition ===
class ADGroupProfile {
    [string]$Name
    [string]$Description
    [string]$Scope
    [string]$Type
    [string[]]$Members
    [object[]]$ACLs

    ADGroupProfile([pscustomobject]$raw) {
        $this.Name        = $raw.Name
        $this.Description = $raw.Description
        $this.Scope       = $raw.Scope
        $this.Type        = $raw.Type
        $this.Members     = $raw.Members
        $this.ACLs        = $raw.ACLs
    }

    [string[]] CompareMembers([ADGroupProfile]$old) {
        return Compare-Object -ReferenceObject $this.Members -DifferenceObject $old.Members -PassThru
    }

    [string[]] CompareACLs([ADGroupProfile]$old) {
        $a = $this.ACLs | ConvertTo-Json -Depth 5
        $b = $old.ACLs  | ConvertTo-Json -Depth 5
        if ($a -ne $b) { return @("ACLs changed") }
        return @()
    }
}

# === Load Group ===
try {
    $group = Get-ADGroup -Identity $GroupName -Properties * -ErrorAction Stop
    Log "✔ Group located: $($group.Name)"
} catch {
    Log "✖ Group not found: $GroupName" "ERROR"
    exit 2
}

# === Recursive Member Resolution ===
function Resolve-Members {
    param ([string]$DN, [int]$MaxDepth = 5)
    $output = @()
    $queue = @(@{DN = $DN; Depth = 0})

    while ($queue.Count -gt 0) {
        $item = $queue[0]; $queue = $queue[1..($queue.Count - 1)]
        if ($item.Depth -ge $MaxDepth) { continue }

        try {
            $entries = Get-ADGroupMember -Identity $item.DN -ErrorAction Stop
            foreach ($entry in $entries) {
                if ($entry.objectClass -eq "group") {
                    $queue += @{DN = $entry.DistinguishedName; Depth = $item.Depth + 1}
                    $output += "$($entry.Name) (Group)"
                } else {
                    $output += "$($entry.SamAccountName) (User)"
                }
            }
        } catch {
            Log "⚠ Failed to resolve members of $($item.DN)" "WARN"
        }
    }
    return $output | Sort-Object -Unique
}
$members = Resolve-Members -DN $group.DistinguishedName

# === ACL Collection (with timeout) ===
$aclList = @()
try {
    $aclPath = "AD:\" + $group.DistinguishedName
    $job = Start-Job { param($p) Get-Acl -Path $p } -ArgumentList $aclPath
    $done = $job | Wait-Job -Timeout 5
    if ($done) {
        $acl = Receive-Job $job
        $aclList = $acl.Access | ForEach-Object {
            [pscustomobject]@{
                Identity   = $_.IdentityReference
                Rights     = $_.ActiveDirectoryRights
                Type       = $_.AccessControlType
                Inherited  = $_.IsInherited
                ObjectType = $_.ObjectType
            }
        }
    } else {
        Log "ACL retrieval timeout – skipping ACL details." "WARN"
    }
    Remove-Job $job -Force
} catch {
    Log "ACL error: $_" "WARN"
}

# === Snapshot Object Build ===
$raw = [pscustomobject]@{
    Name        = $group.Name
    Description = $group.Description
    Scope       = $group.GroupScope
    Type        = $group.GroupCategory
    Members     = $members
    ACLs        = $aclList
}
$profile = [ADGroupProfile]::new($raw)
$profile | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Diff Comparison ===
if (Test-Path $cacheFile) {
    $oldData = Get-Content $cacheFile | ConvertFrom-Json
    $oldProfile = [ADGroupProfile]::new($oldData)
    $changes = @()
    $changes += $profile.CompareMembers($oldProfile)
    $changes += $profile.CompareACLs($oldProfile)

    if ($changes.Count -gt 0) {
        Log "⚠ Group has changed since last snapshot" "WARN"
        $changes | ForEach-Object { "* $_" } | Set-Content -Path $diffFile
    } else {
        Log "No changes detected since last run"
    }
} else {
    Log "No previous snapshot found – skipping diff"
}
$profile | ConvertTo-Json -Depth 5 | Set-Content -Path $cacheFile -Encoding UTF8

# === Markdown Export ===
$md = @"
# AD Group Report: $GroupName

**Generated:** $ts
**Description:** $($group.Description)
**Scope:** $($group.GroupScope)
**Type:** $($group.GroupCategory)

## Members
$($members | ForEach-Object { "- $_" } | Out-String)

## ACL Summary
| Identity | Rights | Type | Inherited | ObjectType |
|----------|--------|------|-----------|------------|
$($aclList | ForEach-Object {
    "| $($_.Identity) | $($_.Rights) | $($_.Type) | $($_.Inherited) | $($_.ObjectType) |"
} | Out-String)
"@
$md | Set-Content -Path $mdFile -Encoding UTF8

# === HTML Export ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset='utf-8'>
<title>AD Group Report: $GroupName</title>
<style>
body { font-family: sans-serif; padding: 20px; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
</style></head><body>
<h1>AD Group Report – $GroupName</h1>
<p><strong>Generated:</strong> $ts</p>
<p><strong>Description:</strong> $($group.Description)</p>
<p><strong>Scope:</strong> $($group.GroupScope)</p>
<p><strong>Type:</strong> $($group.GroupCategory)</p>

<h2>Members</h2>
<ul>$($members | ForEach-Object { "<li>$_</li>" } | Out-String)</ul>

<h2>ACL Summary</h2>
<table><tr><th>Identity</th><th>Rights</th><th>Type</th><th>Inherited</th><th>ObjectType</th></tr>
$($aclList | ForEach-Object {
    "<tr><td>$($_.Identity)</td><td>$($_.Rights)</td><td>$($_.Type)</td><td>$($_.Inherited)</td><td>$($_.ObjectType)</td></tr>"
} | Out-String)
</table>
</body></html>
"@
$html | Set-Content -Path $htmlFile -Encoding UTF8

Log "Audit completed for group: $GroupName" "SUCCESS"