# Purpose: WF1 Group Deep-Audit (Self-contained, ASCII-safe)
# Reports group identity, scope/type/SID; direct + nested members; parent groups;
# GPO User Rights where the group is a trustee; GPP Drive/Printer ILTs targeting the group.
# Outputs JSON, CSV, HTML; per-run folder under C:\WF1GroupAudit\Results\<stamp>
# Requirements: RSAT (ActiveDirectory + GroupPolicy). Read-only.

$ErrorActionPreference = 'Stop'

# --- Elevation check (GPMC + AD tools behave better elevated) ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) { throw "Run PowerShell as Administrator." }

# --- Paths / Run folder ---
$Base   = 'C:\WF1GroupAudit'
$Stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
$RunDir = Join-Path $Base ("Results\" + $Stamp)
New-Item -ItemType Directory -Path $Base,$RunDir -Force | Out-Null
Start-Transcript -Path (Join-Path $RunDir "group_audit_$Stamp.log") -NoClobber | Out-Null

# --- Required modules ---
Import-Module ActiveDirectory -ErrorAction Stop
Import-Module GroupPolicy     -ErrorAction Stop

# --- Output files ---
$jsonOut      = Join-Path $RunDir "wf1_group_audit_$Stamp.json"
$csvOut       = Join-Path $RunDir "wf1_group_audit_$Stamp.csv"
$htmlOut      = Join-Path $RunDir "wf1_group_audit_$Stamp.html"
$membersCsv   = Join-Path $RunDir "members_$Stamp.csv"
$nestingCsv   = Join-Path $RunDir "nesting_$Stamp.csv"
$gpoHitsCsv   = Join-Path $RunDir "gpo_user_rights_$Stamp.csv"
$gppHitsCsv   = Join-Path $RunDir "gpp_targets_$Stamp.csv"

# --- Prompt for target group ---
Write-Host ""
$groupInput = Read-Host "Enter group (sam/name or DOMAIN\name or distinguishedName)"
if ([string]::IsNullOrWhiteSpace($groupInput)) { throw "No group provided." }

# --- Resolve group robustly ---
try {
    if ($groupInput -match '\\') {
        $name  = $groupInput.Split('\')[-1]
        $Group = Get-ADGroup -Identity $name -Properties *
    } elseif ($groupInput -match '^CN=') {
        $Group = Get-ADGroup -Identity $groupInput -Properties *
    } else {
        $Group = Get-ADGroup -Identity $groupInput -Properties *
    }
} catch {
    Stop-Transcript | Out-Null
    throw "Could not resolve group '$groupInput' in AD. $_"
}
if (-not $Group) { Stop-Transcript | Out-Null; throw "Group '$groupInput' not found." }

# --- Helpers ---
function Get-OUPath([string]$dn) {
    ($dn -split ',') | Where-Object { $_ -like 'OU=*' } -join ','
}
function Resolve-SIDName([string]$sid) {
    try {
        (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
    } catch { $null }
}

# --- Identity block ---
$domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name
$groupSid = (Get-ADGroup $Group.DistinguishedName -Properties objectSid).objectSid.Value

$identity = [pscustomobject]@{
    Name              = $Group.Name
    SamAccountName    = $Group.SamAccountName
    DistinguishedName = $Group.DistinguishedName
    OUPath            = Get-OUPath $Group.DistinguishedName
    GroupCategory     = $Group.GroupCategory  # Security / Distribution
    GroupScope        = $Group.GroupScope     # Global / DomainLocal / Universal
    SID               = $groupSid
    Description       = $Group.Description
    WhenCreated       = $Group.WhenCreated
    WhenChanged       = $Group.WhenChanged
    ManagedBy         = $Group.ManagedBy
}

# --- Direct members + nested expansion (full list) ---
# Capture both a hierarchical view and a flattened view with type
$seen = [System.Collections.Generic.HashSet[string]]::new()
$cycles = @()

function Get-GroupTree {
    param([string]$GroupDN,[int]$Depth=0,[string]$Path="")
    $children = @()
    try {
        $members = Get-ADGroupMember -Identity $GroupDN -ErrorAction Stop
    } catch {
        return @()
    }
    foreach ($m in $members) {
        $node = [pscustomobject]@{
            ParentDN  = $GroupDN
            DN        = $m.DistinguishedName
            Name      = $m.Name
            Sam       = $m.SamAccountName
            ObjectClass = $m.objectClass  # user/computer/group
            Depth     = $Depth
        }
        $children += $node
        if ($m.objectClass -eq 'group') {
            if ($seen.Add($m.DistinguishedName) -eq $false) {
                # cycle detected
                $cycles += $m.DistinguishedName
            } else {
                $children += Get-GroupTree -GroupDN $m.DistinguishedName -Depth ($Depth+1)
            }
        }
    }
    return $children
}

$seen.Add($Group.DistinguishedName) | Out-Null
$tree = Get-GroupTree -GroupDN $Group.DistinguishedName -Depth 1

# Flattened list with resolved properties for users/computers/groups
$flatMembers = foreach ($n in $tree) {
    if ($n.ObjectClass -eq 'user') {
        try {
            $u = Get-ADUser -Identity $n.DN -Properties Enabled,UserPrincipalName
            [pscustomobject]@{
                Type   = 'User'
                Name   = $u.Name
                Sam    = $u.SamAccountName
                UPN    = $u.UserPrincipalName
                DN     = $u.DistinguishedName
                Enabled= $u.Enabled
            }
        } catch {}
    } elseif ($n.ObjectClass -eq 'computer') {
        try {
            $c = Get-ADComputer -Identity $n.DN -Properties Enabled
            [pscustomobject]@{
                Type   = 'Computer'
                Name   = $c.Name
                Sam    = $c.SamAccountName
                UPN    = $null
                DN     = $c.DistinguishedName
                Enabled= $c.Enabled
            }
        } catch {}
    } elseif ($n.ObjectClass -eq 'group') {
        [pscustomobject]@{
            Type   = 'Group'
            Name   = $n.Name
            Sam    = $n.Sam
            UPN    = $null
            DN     = $n.DN
            Enabled= $null
        }
    }
}

# --- Parent groups (where this group is a member) ---
$parentGroups = @()
try {
    $parentGroups = (Get-ADPrincipalGroupMembership -Identity $Group.DistinguishedName | Sort-Object Name)
    $parentGroups = $parentGroups | Select-Object Name,SamAccountName,DistinguishedName,GroupCategory,GroupScope
} catch {}

# --- User Rights Assignment (GPO Computer policy trustees) where group SID appears ---
# We scan all GPOs (fast locally) and look for UserRightsAssignment trustees matching this group SID.
$gpoRightsHits = @()
try {
    $allGpos = Get-GPO -All
    foreach ($g in $allGpos) {
        try {
            $x = [xml](Get-GPOReport -Guid $g.Id -ReportType Xml)
            $rights = $x.SelectNodes("//UserRightsAssignment/Right")
            foreach ($r in $rights) {
                foreach ($m in $r.Members.Member) {
                    if ($m.SID -and ($m.SID -eq $groupSid)) {
                        $gpoRightsHits += [pscustomobject]@{
                            GPOName = $g.DisplayName
                            GPOId   = $g.Id
                            Right   = $r.Name
                            Trustee = $m.Name
                            SID     = $m.SID
                        }
                    }
                }
            }
        } catch {}
    }
} catch {}

# --- GPP ILT (Drive Maps / Printers) targeting this group by name (best-effort) ---
# Note: GPP stores ILT groups by name, not SID. We match case-insensitively on Name/Sam.
$gppTargets = @()
function Collect-GPP {
    param([guid]$GpoId)
    try {
        $x = [xml](Get-GPOReport -Guid $GpoId -ReportType Xml)
        $gpoName = $x.GPO.Name
        # Drives
        foreach ($d in $x.SelectNodes("//DriveMapSettings/Drive")) {
            $ilt = @($d.Filters.FilterGroup | ForEach-Object { $_.Name })
            if ($ilt.Count -gt 0) {
                foreach ($tg in $ilt) {
                    if ($tg -and ($tg -ieq $Group.Name -or $tg -ieq $Group.SamAccountName)) {
                        $gppTargets += [pscustomobject]@{
                            GPOName = $gpoName; Type='DriveMap'; Letter=$d.Properties.Letter; Path=$d.Properties.Path; Target=$tg
                        }
                    }
                }
            }
        }
        # Printers
        foreach ($p in $x.SelectNodes("//Printers/SharedPrinter")) {
            $ilt = @($p.Filters.FilterGroup | ForEach-Object { $_.Name })
            if ($ilt.Count -gt 0) {
                foreach ($tg in $ilt) {
                    if ($tg -and ($tg -ieq $Group.Name -or $tg -ieq $Group.SamAccountName)) {
                        $gppTargets += [pscustomobject]@{
                            GPOName = $gpoName; Type='Printer'; Letter=$null; Path=$p.Properties.Path; Target=$tg
                        }
                    }
                }
            }
        }
    } catch {}
}
try {
    foreach ($g in (Get-GPO -All)) { Collect-GPP -GpoId $g.Id }
} catch {}

# --- Assemble object ---
$result = [pscustomobject]@{
    Meta = [pscustomobject]@{
        GeneratedAt = (Get-Date)
        Tool        = 'WF1 Group Deep-Audit'
        Host        = $env:COMPUTERNAME
        Domain      = $domain
        RunFolder   = $RunDir
    }
    Identity          = $identity
    ParentGroups      = $parentGroups
    MembersFlat       = $flatMembers
    NestingTree       = $tree
    CyclesDetected    = ($cycles | Sort-Object -Unique)
    GPOUserRightsHits = $gpoRightsHits
    GPPTargets        = $gppTargets
}

# --- CSVs (flattened views) ---
$csvRows = @()
# Identity (key/value)
$csvRows += [pscustomobject]@{ Section='Identity'; Key='Name';              Value=$identity.Name }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='SamAccountName';    Value=$identity.SamAccountName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='GroupCategory';     Value=$identity.GroupCategory }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='GroupScope';        Value=$identity.GroupScope }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='SID';               Value=$identity.SID }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='OUPath';            Value=$identity.OUPath }

# Parent groups
foreach ($p in $parentGroups) {
    $csvRows += [pscustomobject]@{ Section='ParentGroup'; Key=$p.Name; Value=("Scope=" + $p.GroupScope + "; Category=" + $p.GroupCategory) }
}

# GPO User Rights hits
foreach ($h in $gpoRightsHits) {
    $csvRows += [pscustomobject]@{ Section='UserRight'; Key=$h.Right; Value=("GPO=" + $h.GPOName) }
}

# GPP targets
foreach ($t in $gppTargets) {
    $csvRows += [pscustomobject]@{ Section='GPP'; Key=$t.Type; Value=("GPO=" + $t.GPOName + "; Path=" + $t.Path + "; Target=" + $t.Target) }
}

# Export JSON + CSV
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonOut -Encoding UTF8
$csvRows | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# Export detailed lists
$flatMembers | Export-Csv -Path $membersCsv -NoTypeInformation -Encoding UTF8
$tree        | Export-Csv -Path $nestingCsv -NoTypeInformation -Encoding UTF8
$gpoRightsHits | Export-Csv -Path $gpoHitsCsv -NoTypeInformation -Encoding UTF8
$gppTargets    | Export-Csv -Path $gppHitsCsv -NoTypeInformation -Encoding UTF8

# --- HTML summary (compact) ---
$html = @"
<!DOCTYPE html><html><head><meta charset='utf-8'><title>WF1 – Group Deep-Audit</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;margin:20px;color:#333}
h1{color:#004B8D} h2{color:#0067C5}
table{border-collapse:collapse;width:100%;margin-top:8px}
th,td{border:1px solid #bbb;padding:8px;text-align:left}
th{background:#004B8D;color:#fff}
tr:nth-child(even){background:#f6f8fb}
code{background:#eef;padding:2px 4px}
.small{color:#666;font-size:12px}
.mono{font-family:Consolas,monospace}
</style></head><body>
<h1>WF1 – Group Deep-Audit</h1>
<p class='small'>Generated: $(Get-Date) • Host: $env:COMPUTERNAME • Domain: $domain</p>

<h2>Identity</h2>
<table>
<tr><th>Key</th><th>Value</th></tr>
<tr><td>Name</td><td>$($identity.Name)</td></tr>
<tr><td>SamAccountName</td><td>$($identity.SamAccountName)</td></tr>
<tr><td>GroupCategory</td><td>$($identity.GroupCategory)</td></tr>
<tr><td>GroupScope</td><td>$($identity.GroupScope)</td></tr>
<tr><td>SID</td><td class='mono'>$($identity.SID)</td></tr>
<tr><td>OUPath</td><td><code>$($identity.OUPath)</code></td></tr>
<tr><td>ManagedBy</td><td>$($identity.ManagedBy)</td></tr>
<tr><td>Description</td><td>$($identity.Description)</td></tr>
</table>

<h2>Parent Groups</h2>
<table><tr><th>Name</th><th>Sam</th><th>Scope</th><th>Category</th><th>DN</th></tr>
"@
foreach ($p in $parentGroups) {
    $html += "<tr><td>$($p.Name)</td><td>$($p.SamAccountName)</td><td>$($p.GroupScope)</td><td>$($p.GroupCategory)</td><td class='mono'>$($p.DistinguishedName)</td></tr>"
}
$html += "</table>"

$html += "<h2>Members (Flattened)</h2><table><tr><th>Type</th><th>Name</th><th>Sam</th><th>UPN</th><th>Enabled</th><th>DN</th></tr>"
foreach ($m in $flatMembers) {
    $html += "<tr><td>$($m.Type)</td><td>$($m.Name)</td><td>$($m.Sam)</td><td>$($m.UPN)</td><td>$($m.Enabled)</td><td class='mono'>$($m.DN)</td></tr>"
}
$html += "</table>"

$html += "<h2>Nesting Tree (Direct + Nested)</h2><table><tr><th>Depth</th><th>ObjectClass</th><th>Name</th><th>Sam</th><th>DN</th><th>ParentDN</th></tr>"
foreach ($n in $tree) {
    $html += "<tr><td>$($n.Depth)</td><td>$($n.ObjectClass)</td><td>$($n.Name)</td><td>$($n.Sam)</td><td class='mono'>$($n.DN)</td><td class='mono'>$($n.ParentDN)</td></tr>"
}
$html += "</table>"

if ($cycles.Count -gt 0) {
    $html += "<h2>Cycles Detected</h2><ul>"
    foreach ($c in ($cycles | Sort-Object -Unique)) { $html += "<li class='mono'>$c</li>" }
    $html += "</ul>"
}

$html += "<h2>GPO – User Rights Assignments (trustee is this group)</h2><table><tr><th>GPO</th><th>Right</th><th>Trustee</th><th>SID</th></tr>"
foreach ($h in $gpoRightsHits) {
    $html += "<tr><td>$($h.GPOName)</td><td>$($h.Right)</td><td>$($h.Trustee)</td><td class='mono'>$($h.SID)</td></tr>"
}
$html += "</table>"

$html += "<h2>GPP – Targets (Drive Maps / Printers with ILT matching this group)</h2><table><tr><th>GPO</th><th>Type</th><th>Letter</th><th>Path</th><th>Target</th></tr>"
foreach ($t in $gppTargets) {
    $html += "<tr><td>$($t.GPOName)</td><td>$($t.Type)</td><td>$($t.Letter)</td><td class='mono'>$($t.Path)</td><td>$($t.Target)</td></tr>"
}
$html += "</table>"

$html += "</body></html>"
$html | Set-Content -Path $htmlOut -Encoding UTF8

Stop-Transcript | Out-Null

Write-Host "`n[SUCCESS] Group audit complete." -ForegroundColor Green
Write-Host (" Run Folder : {0}" -f $RunDir)
Write-Host (" JSON       : {0}" -f $jsonOut)
Write-Host (" CSV        : {0}" -f $csvOut)
Write-Host (" Members    : {0}" -f $membersCsv)
Write-Host (" Nesting    : {0}" -f $nestingCsv)
Write-Host (" GPO Rights : {0}" -f $gpoHitsCsv)
Write-Host (" GPP ILT    : {0}" -f $gppHitsCsv)
Write-Host (" HTML       : {0}" -f $htmlOut)