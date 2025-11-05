<#
WF1 – User Effective Rights & Membership Audit (Self-contained)
Purpose: Prompt for a user and produce JSON/CSV/HTML + RSoP artefacts summarising identity, groups (direct+nested),
         applied USER GPOs, User Rights assignments that affect the user, GPP drives/printers, and OU-chain delegations.
Safety: Read-only. No changes to AD or local system. Requires RSAT (ActiveDirectory + GroupPolicy).
#>

$ErrorActionPreference = 'Stop'

# --- Elevation check (we need gpresult and AD tooling happily) ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) { throw "Run PowerShell as Administrator." }

# --- Paths / Run folder ---
$Base   = 'C:\WF1UserAudit'
$Stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
$RunDir = Join-Path $Base ("Results\" + $Stamp)
New-Item -ItemType Directory -Path $Base,$RunDir -Force | Out-Null
Start-Transcript -Path (Join-Path $RunDir "audit_$Stamp.log") -NoClobber | Out-Null

# --- Required modules (fail fast) ---
Import-Module ActiveDirectory -ErrorAction Stop
Import-Module GroupPolicy     -ErrorAction Stop

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

# --- Helpers ---
function Get-OUPath([string]$dn) {
    ($dn -split ',') | Where-Object { $_ -like 'OU=*' } -join ','
}
function Get-AncestorOUs([string]$dn) {
    $parts = $dn -split ','
    $list  = @()
    for ($i=0; $i -lt $parts.Length; $i++) {
        $tail = ($parts[$i..($parts.Length-1)] -join ',')
        if ($tail -like 'OU=*') { $list += $tail }
    }
    $list
}

# --- Identity block ---
$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$domain    = $domainObj.Name
$identity  = [pscustomobject]@{
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
try { $directGroups = (Get-ADPrincipalGroupMembership -Identity $User.DistinguishedName | Sort-Object Name).Name } catch {}

$tokenSIDs = @()
try {
    $tokenBytes = (Get-ADUser $User -Properties tokenGroups).tokenGroups
    if ($tokenBytes) { $tokenSIDs = $tokenBytes | ForEach-Object { (New-Object System.Security.Principal.SecurityIdentifier($_,0)).Value } }
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

# --- gpresult (RSoP) USER scope ---
$fullyQualifiedUser = if ($User.UserPrincipalName) { $User.UserPrincipalName } else { "$domain\$($User.SamAccountName)" }
& gpresult /USER $fullyQualifiedUser /SCOPE USER /H $rsoHtml 2>$null

$xmlOk = $false
try {
    & gpresult /USER $fullyQualifiedUser /SCOPE USER /X $rsoXml 2>$null
    if (Test-Path $rsoXml) { $xmlOk = $true }
} catch {}

# --- Parse applied user GPOs (best-effort) ---
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

# --- User Rights Assignment (map where user’s token intersects) ---
$rightsHits = @()
foreach ($g in $appliedUserGpos) {
    try {
        $gxml = [xml](Get-GPOReport -Guid $g.Guid -ReportType Xml)
        $urs  = $gxml.SelectNodes("//UserRightsAssignment/Right")
        foreach ($r in $urs) {
            $members = @()
            foreach ($m in $r.Members.Member) { $members += [pscustomobject]@{ Name=$m.Name; SID=$m.SID } }
            if ($members.Count -gt 0) {
                $hit = $members.Where({ $_.SID -and ($tokenSIDs -contains $_.SID) }, 'First').Count -gt 0
                if ($hit) {
                    $grant = $members | Where-Object { $_.SID -and ($tokenSIDs -contains $_.SID) } | Select-Object -ExpandProperty Name -Unique
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

# --- GPP (Drive Maps, Printers) summary from applied GPOs ---
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
    $out
}
$gppItems = @()
foreach ($g in $appliedUserGpos) {
    $gpp = Get-GPO-GPP-Summary -Guid $g.Guid
    if ($gpp -and ($gpp.DriveMaps.Count -gt 0 -or $gpp.Printers.Count -gt 0)) { $gppItems += $gpp }
}

# --- Delegations/ACLs on OU chain matching user/group SIDs ---
$ouChain     = Get-AncestorOUs $User.DistinguishedName
$delegations = @()
foreach ($ou in $ouChain) {
    try {
        $acl = Get-Acl ("AD:$ou")
        foreach ($ace in $acl.Access) {
            $idStr = $ace.IdentityReference.ToString()
            $match = $false
            try {
                $sidObj = (New-Object System.Security.Principal.NTAccount($idStr)
                ).Translate([System.Security.Principal.SecurityIdentifier])
                if ($tokenSIDs -contains $sidObj.Value) { $match = $true }
            } catch {
                if ($allGroups -contains $idStr.Split('\')[-1]) { $match = $true }
            }
            if ($match) {
                $delegations += [pscustomobject]@{
                    OU                     = $ou
                    IdentityReference      = $idStr
                    ActiveDirectoryRights  = $ace.ActiveDirectoryRights.ToString()
                    InheritanceType        = $ace.InheritanceType.ToString()
                    ObjectType             = $ace.ObjectType
                    IsInherited            = $ace.IsInherited
                }
            }
        }
    } catch {}
}

# --- Assemble + Exports ---
$result = [pscustomobject]@{
Meta            = [pscustomobject]@{
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
RsopHtml    = $rsoHtml
RsopXml     = (if ($xmlOk) { $rsoXml } else { $null })
}
}

# CSV (flattened for Excel)
$csvRows = @()
$csvRows += [pscustomobject]@{ Section='Identity'; Key='SamAccountName'; Value=$identity.SamAccountName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='DisplayName';   Value=$identity.DisplayName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='UPN';           Value=$identity.UserPrincipalName }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='OUPath';        Value=$identity.OUPath }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='Enabled';       Value=$identity.Enabled }
$csvRows += [pscustomobject]@{ Section='Identity'; Key='LastLogonDate'; Value=$identity.LastLogonDate }
$csvRows += ($allGroups   | ForEach-Object { [pscustomobject]@{ Section='Group';     Key='Group'; Value=$_ } })
$csvRows += ($rightsHits  | ForEach-Object { [pscustomobject]@{ Section='UserRight'; Key=$_.Right; Value=("GPO=" + $_.GPODisplayName + "; By=" + $_.GrantedBy) } })
$csvRows += ($appliedUserGpos | ForEach-Object { [pscustomobject]@{ Section='AppliedGPO'; Key=$_.Name; Value=("Link=" + $_.Link + "; Enforced=" + $_.Enforced + "; Enabled=" + $_.Enabled + "; WMI=" + $_.WMIFilter) } })
$csvRows += ($delegations | ForEach-Object { [pscustomobject]@{ Section='Delegation'; Key=$_.OU; Value=($_.IdentityReference + ": " + $_.ActiveDirectoryRights) } })

$result  | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonOut -Encoding UTF8
$csvRows | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# HTML (compact)
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