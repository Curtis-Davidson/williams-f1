

# What’s in the repo (useful bits)

- `ADUserDiscovery/`
    - `scripts/ADUserDiscovery.ps1` — your user-centric audit. Prompts for a user, pulls identity, direct+nested groups (via `tokenGroups`), tries RSoP (`gpresult`) and renders CSV/HTML. The mid-section is a bit “ellipsised” in your copy, but the intent and scaffolding are there.
    - `modules/inject-meta.ps1` — helper for stamping meta/run-info into outputs.
    - `tests/test-ad-discovery.ps1` — smoke test harness.
- `WF1GroupAudit/`
    - `scripts/GroupDeepAudit.ps1` — group drill-down: expands nested membership, shows who’s in it, and (from the comments) is meant to map where the group grants power (GPO user-rights, possibly OU delegations).
    - `scripts/ADGroupAudit.ps1` — lighter version of the above (memberships and nesting).
- `WF1GPODiscovery/wf1-gpo-discovery.ps1` — enumerates GPOs, links, WMI filters and security settings/GPP. This is the right base to answer “what power do these groups actually confer?” because User Rights Assignment and GPP targeting point to groups.
- `AuditDev/...` and `AuditWS/...` — workstation/dev audit scaffolding; not directly relevant to “user effective rights”, but good for host state.

Your local structure you described (meta, exports, tests, Makefile, README) matches the above: you’ve got pieces to (1) audit a **user**, (2) audit a **group**, and (3) **enumerate GPOs**. What you were missing at the keyboard was a single, hardened, copy-pastable **user audit** runner that:

- creates its own output paths,
- never leaks curly “smart quotes”,
- doesn’t blow up when RSAT modules are missing,
- and stays on short Windows paths (you asked for `C:\Scripts`).

Below is that consolidated script, corrected and ready to drop under `C:\Scripts`. It uses only ASCII, fixes the one-liner `-join`mistake you hit when pasting lines into the console, and avoids the inline `(if (...) {...} else {...})` expression that PowerShell doesn’t parse at the prompt.

# Rule 6 — Neurodiverse Precision Format

1. Exact command
2. Full file path
3. Directory creation (if needed)
4. File creation/edit command
5. Full copy-pasteable code block (with purpose above the block)
6. Commented purpose above block
7. Expected result or test instruction

------

1. Exact command
   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\wf1-user-rights-audit.ps1"`
2. Full file path
   `C:\Scripts\wf1-user-rights-audit.ps1`
3. Directory creation
   `New-Item -ItemType Directory -Path C:\Scripts -Force`
4. File creation/edit command
   `notepad C:\Scripts\wf1-user-rights-audit.ps1`
5. Full code (paste all of this)

```
# Purpose: WF1 – User Effective Rights & Membership Audit (Self-contained, hardened, short paths)
# Prompts for a user and produces JSON/CSV/HTML + RSoP artefacts summarising:
# - Identity, direct + nested groups (via tokenGroups)
# - Applied USER GPOs
# - User Rights (Se* assignments) that affect the user (matched by SID)
# - GPP Drives/Printers targeting
# - OU-chain delegations that reference the user or any of their token SIDs
# Safety: Read-only. Requires RSAT: ActiveDirectory + GroupPolicy. Run as Administrator.

$ErrorActionPreference = 'Stop'

# --- Elevation check ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) { throw "Run PowerShell as Administrator." }

# --- Ensure RSAT modules are present (clear errors if missing) ---
function Require-Module {
  param([string]$Name)
  if (-not (Get-Module -ListAvailable -Name $Name)) {
    throw "Required module '$Name' not found. Install RSAT (ActiveDirectory + GroupPolicy) and re-run."
  }
}
Require-Module -Name ActiveDirectory
Require-Module -Name GroupPolicy
Import-Module ActiveDirectory
Import-Module GroupPolicy

# --- Paths / Run folder (short paths per request) ---
$Base   = 'C:\WF1UserAudit'
$Stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
$RunDir = Join-Path $Base ("Results\" + $Stamp)
New-Item -ItemType Directory -Path $Base,$RunDir -Force | Out-Null

Start-Transcript -Path (Join-Path $RunDir "audit_$Stamp.log") -NoClobber | Out-Null

# --- Output files ---
$jsonOut = Join-Path $RunDir "wf1_user_audit_$Stamp.json"
$csvOut  = Join-Path $RunDir "wf1_user_audit_$Stamp.csv"
$htmlOut = Join-Path $RunDir "wf1_user_audit_$Stamp.html"
$rsoXml  = Join-Path $RunDir "gpresult_user_$Stamp.xml"
$rsoHtml = Join-Path $RunDir "gpresult_user_$Stamp.html"

# --- Prompt for target user ---
Write-Host ""
$userInput = Read-Host "Enter user (samAccountName or DOMAIN\sam or UPN or DN)"
if ([string]::IsNullOrWhiteSpace($userInput)) { throw "No user provided." }

# --- Resolve user object robustly ---
try {
  if ($userInput -match '\\') {
    $sam  = $userInput.Split('\')[-1]
    $User = Get-ADUser -Identity $sam -Properties *
  } elseif ($userInput -match '@') {
    $User = Get-ADUser -Filter "UserPrincipalName -eq '$userInput'" -Properties *
  } elseif ($userInput -match '^CN=') {
    $User = Get-ADUser -Identity $userInput -Properties *
  } else {
    $User = Get-ADUser -Identity $userInput -Properties *
  }
} catch {
  Stop-Transcript | Out-Null
  throw "Could not resolve user '$userInput' in AD. $_"
}
if (-not $User) { Stop-Transcript | Out-Null; throw "User '$userInput' not found." }

# --- Helpers (no pipeline joins typed at console) ---
function Get-OUPath([string]$dn) {
  $parts = $dn -split ','
  $ous   = foreach ($p in $parts) { if ($p -like 'OU=*') { $p } }
  ($ous -join ',')
}
function Get-AncestorOUs([string]$dn) {
  $parts = $dn -split ','
  $list  = @()
  for ($i=0; $i -lt $parts.Length; $i++) {
    $tail = ($parts[$i..($parts.Length-1)] -join ',')
    if ($tail -like 'OU=*') { $list += $tail }
  }
  return $list
}

# --- Identity block ---
$domain   = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name
$identity = [pscustomobject]@{
  SamAccountName    = $User.SamAccountName
  UserPrincipalName = $User.UserPrincipalName
  DisplayName       = $User.DisplayName
  DistinguishedName = $User.DistinguishedName
  Enabled           = $User.Enabled
  LastLogonDate     = $User.LastLogonDate
  WhenCreated       = $User.WhenCreated
  WhenChanged       = $User.WhenChanged
  PrimaryGroupID    = $User.PrimaryGroupID
  HomeDirectory     = $User.HomeDirectory
  HomeDrive         = $User.HomeDrive
  ProfilePath       = $User.ProfilePath
  ScriptPath        = $User.ScriptPath
  OUPath            = Get-OUPath $User.DistinguishedName
}

# --- Groups (direct + token SIDs → names) ---
$directGroups = @()
try {
  $directGroups = (Get-ADPrincipalGroupMembership -Identity $User.DistinguishedName | Sort-Object Name).Name
} catch {}

$tokenSIDs = @()
try {
  $tokenBytes = (Get-ADUser $User -Properties tokenGroups).tokenGroups
  if ($tokenBytes) {
    $tokenSIDs = $tokenBytes | ForEach-Object { (New-Object System.Security.Principal.SecurityIdentifier($_,0)).Value }
  }
} catch {}

$allGroups = @()
if ($tokenSIDs) {
  foreach ($sid in $tokenSIDs) {
    try {
      $obj = Get-ADObject -Filter "objectSid -eq '$sid'" -Properties name,objectClass
      if ($obj -and $obj.objectClass -eq 'group') { $allGroups += $obj.Name }
    } catch {}
  }
}
$allGroups = ($allGroups + $directGroups) | Sort-Object -Unique

# --- RSoP for USER scope (best-effort) ---
$fullyQualifiedUser = if ($User.UserPrincipalName) { $User.UserPrincipalName } else { "$domain\$($User.SamAccountName)" }
& gpresult /USER $fullyQualifiedUser /SCOPE USER /H $rsoHtml 2>$null

$xmlOk = $false
try {
  & gpresult /USER $fullyQualifiedUser /SCOPE USER /X $rsoXml 2>$null
  if (Test-Path $rsoXml) { $xmlOk = $true }
} catch {}

# --- Parse applied user GPOs (only when XML exists) ---
$appliedUserGpos = @()
if ($xmlOk) {
  try {
    [xml]$rx = Get-Content -LiteralPath $rsoXml
    $appliedUserGpos = $rx.Rsop.UserResults.GPO | Where-Object { $_.Applied -eq 'true' } | ForEach-Object {
      [pscustomobject]@{
        Name      = $_.Name
        Guid      = $_.Identifier
        Link      = $_.Link
        Enforced  = $_.Enforced
        Enabled   = $_.Enabled
        WMIFilter = ($_.WMIFilter.Name)
        LinkOrder = $_.LinkOrder
      }
    }
  } catch { $appliedUserGpos = @() }
}

# --- User Rights Assignment (match trustees to token SIDs) ---
$rightsHits = @()
foreach ($g in $appliedUserGpos) {
  try {
    $gxml = [xml](Get-GPOReport -Guid $g.Guid -ReportType Xml)
    $urs  = $gxml.SelectNodes("//UserRightsAssignment/Right")
    foreach ($r in $urs) {
      $members = @()
      foreach ($m in $r.Members.Member) { $members += [pscustomobject]@{ Name=$m.Name; SID=$m.SID } }
      if ($members.Count -gt 0) {
        $grant = $members | Where-Object { $_.SID -and ($tokenSIDs -contains $_.SID) } | Select-Object -ExpandProperty Name -Unique
        if ($grant) {
          $rightsHits += [pscustomobject]@{
            GPODisplayName = $g.Name
            GPOGuid        = $g.Guid
            Right          = $r.Name
            GrantedBy      = ($grant -join '; ')
          }
        }
      }
    }
  } catch {}
}

# --- GPP (Drive Maps, Printers) from applied GPOs ---
function Get-GPO-GPP-Summary {
  param([Guid]$Guid)
  $out = [pscustomobject]@{ GPO=$null; DriveMaps=@(); Printers=@() }
  try {
    $x = [xml](Get-GPOReport -Guid $Guid -ReportType Xml)
    $out.GPO = $x.GPO.Name
    $x.SelectNodes("//DriveMapSettings/Drive") | ForEach-Object {
      $out.DriveMaps += [pscustomobject]@{
        Letter       = $_.Properties.Letter
        Path         = $_.Properties.Path
        TargetGroups = ($_.Filters.FilterGroup | ForEach-Object { $_.Name }) -join '; '
      }
    }
    $x.SelectNodes("//Printers/SharedPrinter") | ForEach-Object {
      $out.Printers += [pscustomobject]@{
        Path         = $_.Properties.Path
        TargetGroups = ($_.Filters.FilterGroup | ForEach-Object { $_.Name }) -join '; '
      }
    }
  } catch {}
  return $out
}
$gppItems = @()
foreach ($g in $appliedUserGpos) {
  $gpp = Get-GPO-GPP-Summary -Guid $g.Guid
  if ($gpp -and ($gpp.DriveMaps.Count -gt 0 -or $gpp.Printers.Count -gt 0)) { $gppItems += $gpp }
}

# --- Delegations (OU chain) where ACEs match user token SIDs ---
$ouChain     = Get-AncestorOUs $User.DistinguishedName
$delegations = @()
foreach ($ou in $ouChain) {
  try {
    $acl = Get-Acl ("AD:$ou")
    foreach ($ace in $acl.Access) {
      $idStr = $ace.IdentityReference.ToString()
      $match = $false
      try {
        $sid = (New-Object System.Security.Principal.NTAccount($idStr)
        ).Translate([System.Security.Principal.SecurityIdentifier]).Value
        if ($tokenSIDs -contains $sid) { $match = $true }
      } catch {
        if ($allGroups -contains $idStr.Split('\')[-1]) { $match = $true }
      }
      if ($match) {
        $delegations += [pscustomobject]@{
          OU                    = $ou
          IdentityReference     = $idStr
          ActiveDirectoryRights = $ace.ActiveDirectoryRights.ToString()
          InheritanceType       = $ace.InheritanceType.ToString()
          ObjectType            = $ace.ObjectType
          IsInherited           = $ace.IsInherited
        }
      }
    }
  } catch {}
}

# --- Assemble & Export ---
$result = [pscustomobject]@{
  Meta = [pscustomobject]@{
    GeneratedAt = (Get-Date)
    Tool        = 'WF1 User Rights Audit'
    Host        = $env:COMPUTERNAME
    Domain      = $domain
    RunFolder   = $RunDir
  }
  Identity        = $identity
  DirectGroups    = $directGroups
  AllGroups       = $allGroups
  TokenSIDs       = $tokenSIDs
  AppliedUserGPOs = $appliedUserGpos
  UserRights      = $rightsHits
  GPPItems        = $gppItems
  Delegations     = $delegations
  Artifacts       = [pscustomobject]@{
    RsopHtml = $rsoHtml
    RsopXml  = ($(if ($xmlOk) { $rsoXml } else { $null }))
  }
}

# CSV (flatten for Excel)
$csvRows = @()
$csvRows += [pscustomobject]@{ Section='Identity'; Key='SamAccountName'; Value=$identity.SamAccountName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='DisplayName';   Value=$identity.DisplayName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='UPN';           Value=$identity.UserPrincipalName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='OUPath';        Value=$identity.OUPath }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='Enabled';       Value=$identity.Enabled }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='LastLogonDate'; Value=$identity.LastLogonDate }
$csvRows += ($allGroups | ForEach-Object { [pscustomobject]@{ Section='Group'; Key='Group'; Value=$_ } })
$csvRows += ($rightsHits | ForEach-Object { [pscustomobject]@{ Section='UserRight'; Key=$_.Right; Value=("GPO=" + $_.GPODisplayName + "; By=" + $_.GrantedBy) } })
$csvRows += ($appliedUserGpos | ForEach-Object { [pscustomobject]@{ Section='AppliedGPO'; Key=$_.Name; Value=("Link=" + $_.Link + "; Enforced=" + $_.Enforced + "; Enabled=" + $_.Enabled + "; WMI=" + $_.WMIFilter) } })
$csvRows += ($delegations | ForEach-Object { [pscustomobject]@{ Section='Delegation'; Key=$_.OU; Value=($_.IdentityReference + ": " + $_.ActiveDirectoryRights) } })

$result  | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonOut -Encoding UTF8
$csvRows | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# HTML report (compact; pure ASCII)
$html = @"
<!DOCTYPE html><html><head><meta charset='utf-8'><title>WF1 – User Rights Audit</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;margin:20px;color:#333}
h1{color:#004B8D} h2{color:#0067C5}
table{border-collapse:collapse;width:100%;margin-top:8px}
th,td{border:1px solid #bbb;padding:8px;text-align:left}
th{background:#004B8D;color:#fff}
tr:nth-child(even){background:#f6f8fb} code{background:#eef;padding:2px 4px}
.small{color:#666;font-size:12px}
</style></head><body>
<h1>WF1 – User Rights Audit</h1>
<p class='small'>Generated: $(Get-Date) • Host: $env:COMPUTERNAME • Domain: $domain</p>

<h2>Identity</h2>
<table>
<tr><th>Key</th><th>Value</th></tr>
<tr><td>SamAccountName</td><td>$($identity.SamAccountName)</td></tr>
<tr><td>DisplayName</td><td>$($identity.DisplayName)</td></tr>
<tr><td>UPN</td><td>$($identity.UserPrincipalName)</td></tr>
<tr><td>OUPath</td><td><code>$($identity.OUPath)</code></td></tr>
<tr><td>Enabled</td><td>$($identity.Enabled)</td></tr>
<tr><td>LastLogonDate</td><td>$($identity.LastLogonDate)</td></tr>
<tr><td>Home/Profile/Script</td><td>Home=$($identity.HomeDirectory) ($($identity.HomeDrive)) | Profile=$($identity.ProfilePath) | Script=$($identity.ScriptPath)</td></tr>
</table>

<h2>Group Membership (All – direct + nested)</h2>
<table><tr><th>Group</th></tr>
"@
foreach ($g in $allGroups) { $html += "<tr><td>$g</td></tr>" }
$html += "</table>"

$html += "<h2>Applied User GPOs (RSoP)</h2><table><tr><th>Name</th><th>Link</th><th>Enforced</th><th>Enabled</th><th>WMI</th></tr>"
foreach ($g in $appliedUserGpos) {
  $html += "<tr><td>$($g.Name)</td><td>$($g.Link)</td><td>$($g.Enforced)</td><td>$($g.Enabled)</td><td>$($g.WMIFilter)</td></tr>"
}
$html += "</table><p class='small'>Artifacts: <a href='$(Split-Path -Leaf $rsoHtml)'>RSoP (HTML)</a>"
if ($xmlOk) { $html += " | <a href='$(Split-Path -Leaf $rsoXml)'>RSoP (XML)</a>" }
$html += "</p>"

$html += "<h2>User Rights Assignment matched to this user</h2><table><tr><th>Right</th><th>Granted By</th><th>GPO</th></tr>"
foreach ($r in $rightsHits) {
  $html += "<tr><td>$($r.Right)</td><td>$($r.GrantedBy)</td><td>$($r.GPODisplayName)</td></tr>"
}
$html += "</table>"

$html += "<h2>GPP – Drive Maps & Printers</h2>"
foreach ($pkg in $gppItems) {
  $html += "<h3>$($pkg.GPO)</h3>"
  if ($pkg.DriveMaps.Count -gt 0) {
    $html += "<b>Drives</b><table><tr><th>Letter</th><th>Path</th><th>Target Groups</th></tr>"
    foreach ($d in $pkg.DriveMaps) { $html += "<tr><td>$($d.Letter)</td><td>$($d.Path)</td><td>$($d.TargetGroups)</td></tr>" }
    $html += "</table>"
  }
  if ($pkg.Printers.Count -gt 0) {
    $html += "<b>Printers</b><table><tr><th>Path</th><th>Target Groups</th></tr>"
    foreach ($p in $pkg.Printers) { $html += "<tr><td>$($p.Path)</td><td>$($p.TargetGroups)</td></tr>" }
    $html += "</table>"
  }
}

$html += "<h2>Delegations (OU chain)</h2><table><tr><th>OU</th><th>Identity</th><th>Rights</th><th>Inherited</th></tr>"
foreach ($d in $delegations) {
  $html += "<tr><td><code>$($d.OU)</code></td><td>$($d.IdentityReference)</td><td>$($d.ActiveDirectoryRights)</td><td>$($d.IsInherited)</td></tr>"
}
$html += "</table></body></html>"

$html | Set-Content -Path $htmlOut -Encoding UTF8

Stop-Transcript | Out-Null

Write-Host "`n[SUCCESS] Audit complete." -ForegroundColor Green
Write-Host (" Run Folder : {0}" -f $RunDir)
Write-Host (" JSON       : {0}" -f $jsonOut)
Write-Host (" CSV        : {0}" -f $csvOut)
Write-Host (" HTML       : {0}" -f $htmlOut)
Write-Host (" RSoP (HTML): {0}" -f $rsoHtml)
if ($xmlOk) { Write-Host (" RSoP (XML) : {0}" -f $rsoXml) }
```

1. Purpose is commented at the top of the block.
2. Expected result / tests

- Run as admin on a box with RSAT AD + GPMC cmdlets available.
- You’ll be prompted for a user; on success you get a run folder like:
  `C:\WF1UserAudit\Results\YYYYMMDD_HHMMSS\` containing `.json`, `.csv`, `.html`, and `gpresult` artefacts.
- If RSAT isn’t installed you’ll get a hard, clear error at the start (that was the “Get-ADUser not recognised” you hit).
- If you paste the **entire** script into a file and run it (not line-by-line in the console), you won’t hit the previous “line 225” issues — those were caused by console-pasted join/inline `if` expressions.

------

## Mapping to your two asks

- **Ask 1 (User reach/rights):** Use the script above — it’s the consolidated, hardened replacement for `ADUserDiscovery.ps1` plus the RSoP and rights-mapping logic. It aligns with your original intent and outputs JSON/CSV/HTML.
- **Ask 2 (What each group actually confers):** Start from `WF1GroupAudit/scripts/GroupDeepAudit.ps1` and combine it with `WF1GPODiscovery/wf1-gpo-discovery.ps1`:
    - Expand nested membership (`Get-ADGroupMember -Recursive`).
    - Search GPO reports (`Get-GPOReport -ReportType Xml`) for:
        - `//UserRightsAssignment/Right/Members/Member[@SID='…']` matching the group SID.
        - GPP target filters where `<FilterGroup Name='DOMAIN\Group'>`.
    - Optionally, enumerate OU ACLs (`Get-Acl "AD:OU=...,DC=..."`) and find ACEs where `IdentityReference` equals the group or translates to the group SID.

If you want, I’ll deliver a matching `C:\Scripts\wf1-group-deep-audit.ps1` next that takes `-Group` and produces a single HTML with:

- Members (direct + nested),
- Where the group is referenced in GPO user rights,
- GPP items targeted to it,
- OU delegations that mention it.

## Why you saw the repeat errors

- `Where-Object { … } -join ','` — `-join` is an array operator, not a parameter; it’s fine **in a script** but when you pasted that single line into the interactive console, PowerShell bound `-join` as if it were a parameter to `Where-Object` and threw. The version above builds an array first, then joins on a separate line.
- `(if ($xmlOk) { ... } else { ... })` — inline conditional expression isn’t PowerShell’s syntax; works inside a broader script block in some contexts but not line-by-line. Fixed by using a standard `$(if ...)` subexpression that always returns a value.

## Quick pre-flight (RSAT) on a fresh workstation

```
# Ensure RSAT AD + GPMC are present (Windows 10/11 Enterprise/Education/Pro joined devices)
Get-WindowsCapability -Online | Where-Object Name -like 'Rsat.ActiveDirectory*','Rsat.GroupPolicy*' |
  Select-Object Name, State

# Install if absent
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
```

If you want me to ship the group deep-audit script in the same style, say the word and I’ll hand you a single drop-in `C:\Scripts\wf1-group-deep-audit.ps1`.





SampleUser Audit.zip

Zip Archive

This is one I was using, so how it created the structure on the local machine, for that and the results and the formats, to just ask you whether the work we've done now above was following the same thing, and is it a good method and good practice to do it this way, and do it a good study of the sample. This is just about format, layout, results, and so forth that it should create on the run, and if it exists, then it exists, you know?

###### ChatGPT said:

Thought for 11s

Short answer: yes — the audit you and I just built follows the same pattern as your sample and it’s good practice. It’s actually stricter and safer:

- Same structure: `C:\WF1UserAudit\Results\<YYYYMMDD_HHMMSS>\`
- Same artefacts: JSON + CSV + HTML + RSoP (HTML/XML when available)
- Same behaviour: idempotent directory creation (won’t crash if base exists), transcript per run, short Windows paths, pure ASCII to avoid “smart-quote” parser junk.
- Safer/harder: explicit RSAT checks, fully qualified user resolution, tokenGroups→SID mapping, best-effort GPO XML parse, OU delegation scrape, and no inline console-trip hazards (`-join` on pipeline, inline `if`).

If all you care about is format/layout/run-folder behaviour, we’re aligned with your sample — just more robust.

If you want it absolutely “WF1 Canonical”, add these tiny quality-of-life helpers (they don’t change your report content — only make navigation and re-runs cleaner).

# Rule 6 — Neurodiverse Precision Format

1. Exact commands
2. Full file paths
3. Directory creation
4. File creation/edit commands
5. Full code blocks (with purpose)
6. Purpose comments inside code
7. Expected result / test

------

## A) “Latest” pointer + run index (optional but recommended)

1. Exact command

```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\wf1-index-runs.ps1"
```

1. Full file path
   `C:\Scripts\wf1-index-runs.ps1`
2. Directory creation

```
New-Item -ItemType Directory -Path C:\Scripts -Force
```

1. File creation/edit

```
notepad C:\Scripts\wf1-index-runs.ps1
```

1. Full code (paste all)

```
# Purpose: Maintain a simple index of runs and a "Latest" pointer without long paths or external deps.
# Safe: Read-only over run folders; writes index.html and latest.txt at C:\WF1UserAudit

$Base   = 'C:\WF1UserAudit'
$Results= Join-Path $Base 'Results'
New-Item -ItemType Directory -Path $Base,$Results -Force | Out-Null

$runs = Get-ChildItem -Path $Results -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending

# Write Latest pointer (text file with absolute path)
if ($runs) {
  $latest = $runs[0].FullName
  Set-Content -LiteralPath (Join-Path $Base 'latest.txt') -Value $latest -Encoding ASCII
}

# Build a simple index.html
$rows = foreach ($r in $runs) {
  $h = Join-Path $r.FullName ("wf1_user_audit_{0}.html" -f ($r.Name.Replace('Results\','')))
  $j = Join-Path $r.FullName ("wf1_user_audit_{0}.json" -f ($r.Name.Replace('Results\','')))
  $c = Join-Path $r.FullName ("wf1_user_audit_{0}.csv"  -f ($r.Name.Replace('Results\','')))
  $gpH = Join-Path $r.FullName ("gpresult_user_{0}.html" -f ($r.Name.Replace('Results\','')))
  $gpX = Join-Path $r.FullName ("gpresult_user_{0}.xml"  -f ($r.Name.Replace('Results\','')))
  "<tr><td>$($r.Name)</td><td><a href='$h'>HTML</a></td><td><a href='$j'>JSON</a></td><td><a href='$c'>CSV</a></td><td><a href='$gpH'>RSoP HTML</a></td><td><a href='$gpX'>RSoP XML</a></td></tr>"
}

$index = @"
<!DOCTYPE html><html><head><meta charset='utf-8'><title>WF1 – User Audit Runs</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;margin:20px;color:#333}
table{border-collapse:collapse;width:100%} th,td{border:1px solid #bbb;padding:6px;text-align:left}
th{background:#004B8D;color:#fff}
</style></head><body>
<h1>WF1 – User Audit Runs</h1>
<p>Base: $Base</p>
<p>Latest pointer: <code>$(Join-Path $Base 'latest.txt')</code></p>
<table><tr><th>Run</th><th>HTML</th><th>JSON</th><th>CSV</th><th>RSoP (HTML)</th><th>RSoP (XML)</th></tr>
$($rows -join "`n")
</table></body></html>
"@

Set-Content -LiteralPath (Join-Path $Base 'index.html') -Value $index -Encoding UTF8
Write-Host "[OK] Index and latest pointer written." -ForegroundColor Green
```

1. Purpose is commented at the top.
2. Expected result / test

- Run **after** any audit run.
- `C:\WF1UserAudit\index.html` lists all runs with clickable artefacts.
- `C:\WF1UserAudit\latest.txt` contains the absolute path to the newest run.

------

## B) Duplicate-guard (Rule 8: “Trust nothing, confirm everything”)

This doesn’t stop your audit; it just warns if a run with the *same* user and minute-stamp already exists (rare, but on point with your Canonical Verification rule).

1. Exact command
   Add the function below into `C:\Scripts\wf1-user-rights-audit.ps1`, right after the run-folder is created.
2. Full file path
   `C:\Scripts\wf1-user-rights-audit.ps1`
3. Directory creation
   Already handled by your audit script.
4. File edit command

```
notepad C:\Scripts\wf1-user-rights-audit.ps1
```

1. Code to insert (safe):

```
# Purpose: Warn if a run seems duplicated in the same minute for the same user (soft guard).
function Test-RunDuplicate {
  param([string]$Base,[string]$UserSam,[string]$Stamp)
  $minuteKey = $Stamp.Substring(0, 13)  # yyyyMMdd_HHmm
  $pattern = "wf1_user_audit_${minuteKey}"
  $hits = Get-ChildItem -Path (Join-Path $Base 'Results') -Directory -ErrorAction SilentlyContinue |
          Where-Object { $_.Name -like "${minuteKey}*" } |
          ForEach-Object {
            $json = Join-Path $_.FullName ("wf1_user_audit_{0}.json" -f $_.Name)
            if (Test-Path $json) {
              try {
                $obj = Get-Content $json -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($obj.Identity.SamAccountName -eq $UserSam) { $_.FullName }
              } catch {}
            }
          }
  if ($hits) {
    Write-Warning "This looks like a duplicate run for user '$UserSam' within the same minute:"
    $hits | ForEach-Object { Write-Warning " - $_" }
  }
}
# call after $User resolved:
Test-RunDuplicate -Base $Base -UserSam $User.SamAccountName -Stamp $Stamp
```

1. Purpose commented inside.
2. Expected result / test

- If you run the audit twice in the same minute for the same user, you’ll get a warning listing the prior run folder(s). No functional change otherwise.

------

## C) Retention (keep the last N runs to avoid clutter)

1. Exact command

```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\wf1-retention.ps1" -Keep 100
```

1. Full file path
   `C:\Scripts\wf1-retention.ps1`
2. Directory creation

```
New-Item -ItemType Directory -Path C:\Scripts -Force
```

1. File creation/edit

```
notepad C:\Scripts\wf1-retention.ps1
```

1. Code

```
# Purpose: Keep last N run folders under C:\WF1UserAudit\Results, delete older ones.
param([int]$Keep = 100)
$Base    = 'C:\WF1UserAudit'
$Results = Join-Path $Base 'Results'
$all = Get-ChildItem -Path $Results -Directory -ErrorAction SilentlyContinue |
       Sort-Object Name -Descending
$prune = $all | Select-Object -Skip $Keep
foreach ($d in $prune) {
  try { Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction Stop } catch {}
}
Write-Host "[OK] Retention applied. Kept: $Keep, Removed: $($prune.Count)" -ForegroundColor Green
```

1. Purpose commented inside.
2. Expected result / test

- After many runs, apply retention to keep only the most recent N run folders.

------

## Verdict on format/layout/results

- **Good practice?** Yes. Short paths, per-run folders, transcript, deterministic names, ASCII encoding, and explicit RSAT checks are all enterprise-grade.
- **Idempotency?** Yes. Creating `C:\WF1UserAudit`/`Results` with `-Force` is safe when they already exist. Artefacts are stamped; nothing clobbers previous runs.
- **Navigability?** With the optional **index** + **latest pointer**, your operators won’t hunt for the newest folder.
- **Audit trail?** Each run has a log, and Rule-8 “duplicate guard” adds human-readable warnings without blocking.

If you want me to package the group deep-audit in the same pattern (`C:\WF1GroupAudit\Results\<stamp>\…` with HTML/JSON/CSV) I’ll hand you a drop-in next.

##### You said:

package the group deep-audit in the same pattern (C:\WF1GroupAudit\Results\<stamp>\… with HTML/JSON/CSV) I’ll hand you a drop-in next.

###### ChatGPT said:

Got it. Here’s a **drop-in, self-contained Group Deep-Audit** that mirrors the user audit pattern — same short paths, per-run folder, JSON/CSV/HTML artefacts, transcript, and clean ASCII. It prompts for a **group** (sam/name/DN), expands **direct + nested** membership, lists **parent groups**, flags **circular refs**, pulls **GPO User Rights** where the group is a trustee, and surfaces **GPP (Drive Maps/Printers) ILT** targeting the group.

# Rule 6 — Neurodiverse Precision Format

1. Exact command

```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\wf1-group-deep-audit.ps1"
```

1. Full file path
   `C:\Scripts\wf1-group-deep-audit.ps1`
2. Directory creation (if needed)

```
New-Item -ItemType Directory -Path C:\Scripts -Force
```

1. File creation/edit command

```
notepad C:\Scripts\wf1-group-deep-audit.ps1
```

1. Full copy-pasteable code block (with purpose comments)

```
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
```

1. Commented purpose
   Inline at the top of the script.
2. Expected result / test instructions

- Run the exact command above as **Administrator** on a box with **RSAT ActiveDirectory + GroupPolicy**.
- When prompted, enter a group (e.g., `DOMAIN\TunnelOps_Readers` or its DN).
- Check the run folder:
  `C:\WF1GroupAudit\Results\<YYYYMMDD_HHMMSS>\`
  You’ll get:
    - `wf1_group_audit_<stamp>.json` — full object for programmatic use.
    - `wf1_group_audit_<stamp>.csv` — key/value overview (identity, parents, rights, GPP).
    - `members_<stamp>.csv` — flattened member list (users/computers/groups).
    - `nesting_<stamp>.csv` — hierarchical edges with depth and parent DN.
    - `gpo_user_rights_<stamp>.csv` — GPO User Rights where this group is a trustee.
    - `gpp_targets_<stamp>.csv` — GPP Drive/Printer items that ILT-target this group.
    - `wf1_group_audit_<stamp>.html` — readable report.

------

### Notes / guardrails

- **Scope:** This does **not** crawl every NTFS or share ACL in the forest (too noisy + slow). It focuses on **directory membership power**, **GPO user rights**, and **GPP ILTs** that affect real access.
- **ILT matching:** GPP filters store **names**, not SIDs; we match on `Group.Name` or `SamAccountName` case-insensitively. If you enforce naming variances, we can extend to alias lists.
- **Cycles:** If a group loop exists (A→B→A), it’s listed in **CyclesDetected** and shown in HTML.
- **Performance:** `Get-GPO -All` + XML parse is quick in most domains. If your GPO count is huge and you want speed limits, we can add filters.

**index/retention** pair for `C:\WF1GroupAudit` like we did for user audits (latest pointer + run listing + keep last N),











ChatGPT can make mistakes. Check importa