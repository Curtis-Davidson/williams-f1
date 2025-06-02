# ======================================================
# Williams F1 | GPO Discovery Module – v2025.6.4
# File: /WF1GPODiscovery/wf1-gpo-discovery.ps1
# Author: Paul R Davidson & Urbantek
# Purpose: Enumerate, summarise, and enhance GPO visibility
# Output: JSON + HTML Summary + Dashboard + Archive
# ======================================================

Import-Module GroupPolicy
Import-Module ActiveDirectory

# === Timestamp & Paths ===
$ts         = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportBase = "$PSScriptRoot\Results"
$jsonOut    = Join-Path $exportBase "wf1_gpo_summary_$ts.json"
$htmlOut    = Join-Path $exportBase "wf1_gpo_summary_$ts.html"
$csvOut     = Join-Path $exportBase "wf1_gpo_dashboard_$ts.csv"
$archiveOut = Join-Path $exportBase "html_reports_$ts"

# === Create Export Directories ===
if (-not (Test-Path $exportBase))  { New-Item -Path $exportBase -ItemType Directory | Out-Null }
if (-not (Test-Path $archiveOut))  { New-Item -Path $archiveOut -ItemType Directory | Out-Null }

# === Summary Storage
$gpoSummary = @()
$dashboard  = @{}
$linkedOUs  = @{}

# === Pull All OUs with gPLink
$ous = Get-ADOrganizationalUnit -Filter * -Properties gPLink

# === XML GPO Policy Summary Parser
function Get-GPOPolicySummary {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [xml]$GpoXml
    )

    $GpoXml.GPO.Computer.ExtensionData | 
        Where-Object { $_.Name -and $_.InnerXml } | 
        ForEach-Object {
            $normalizedValue = $_.InnerXml -replace '\s+', ' '
            "$($_.Name): $normalizedValue"
        }
}

Write-Host "[INFO] Pulling all GPOs in AD domain..." -ForegroundColor Cyan
$gpos = Get-GPO -All

foreach ($gpo in $gpos) {
    $xmlReport  = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    $htmlReport = Get-GPOReport -Guid $gpo.Id -ReportType Html
    $xml        = [xml]$xmlReport

    # === Save HTML Archive Copy
    $safeName = $gpo.DisplayName -replace '[^a-zA-Z0-9\-]', '_'
    $htmlPath = Join-Path $archiveOut "$safeName.html"
    $htmlReport | Out-File -Encoding utf8 -FilePath $htmlPath

    # === Extract GPO Settings & Summary
    $settings      = $xml.GPO.Computer.ExtensionData | ForEach-Object { $_.Name }
    $policySummary = Get-GPOPolicySummary -Xml $xml

    # === Linked OU Check
    $linkedThisGpo = @()
    foreach ($ou in $ous) {
        if ($ou.gPLink -and $ou.gPLink -match $gpo.Id.Guid) {
            $linkedOUs[$ou.DistinguishedName] = $true
            $linkedThisGpo += $ou.DistinguishedName
        }
    }

    # === Security Filtering
    $securityFilter = (Get-GPPermissions -Guid $gpo.Id -All -ErrorAction SilentlyContinue) |
            Where-Object { $_.Permission -match "GpoApply" } |
            Select-Object -ExpandProperty Trustee

    # === Dashboard Counter
    foreach ($type in $settings) {
        if ($type -and -not $dashboard.ContainsKey($type)) { $dashboard[$type] = 1 }
        elseif ($type) { $dashboard[$type]++ }
    }

    # === Final GPO Summary Entry
    $gpoSummary += [PSCustomObject]@{
        Name          = $gpo.DisplayName
        GUID          = $gpo.Id
        Owner         = $gpo.Owner
        Created       = $gpo.CreationTime
        Modified      = $gpo.ModificationTime
        LinkedOUs     = $linkedThisGpo.Count
        SecurityScope = ($securityFilter -join ", ")
        Settings      = ($settings -join ", ")
        PolicySummary = ($policySummary -join "`n")
        HTMLReport    = $htmlPath
    }
}

# === Identify Orphaned OUs
Write-Host "[INFO] Detecting OUs without GPOs..." -ForegroundColor Cyan
$allOUs   = $ous | Select-Object -ExpandProperty DistinguishedName
$noGpoOUs = $allOUs | Where-Object { -not $linkedOUs.ContainsKey($_) }

# === Export JSON
$exportData = @{
    Timestamp = $ts
    Summary   = $gpoSummary
    NoGpoOUs  = $noGpoOUs
}
$exportData | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOut -Encoding UTF8

# === Export Dashboard CSV
$dashboard.GetEnumerator() | Sort-Object Name |
        Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# === Export HTML Summary
$html = @"
<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Williams F1 – GPO Dashboard</title>
<style>
body { font-family: Segoe UI, sans-serif; background: #f4f4f4; padding: 20px; color: #333; }
h1, h2 { color: #004B8D; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #aaa; padding: 10px; }
th { background-color: #004B8D; color: white; }
tr:nth-child(even) { background: #eef3f9; }
pre { background: #eee; padding: 10px; overflow-x: auto; white-space: pre-wrap; }
</style>
</head><body>
<h1>Williams F1 – Group Policy Summary</h1>
<p><b>Generated:</b> $(Get-Date)</p>

<h2>Dashboard (By Setting Category)</h2>
<table><tr><th>Category</th><th>Count</th></tr>
"@

foreach ($entry in $dashboard.GetEnumerator() | Sort-Object Name) {
    $html += "<tr><td>$($entry.Name)</td><td>$($entry.Value)</td></tr>"
}
$html += "</table>"

$html += "<h2>OUs Without GPO Links</h2><ul>"
foreach ($ou in $noGpoOUs) {
    $html += "<li>$ou</li>"
}
$html += "</ul>"

$html += "<h2>Per-GPO Summary</h2>"
foreach ($gpo in $gpoSummary) {
    $html += "<h3>$($gpo.Name)</h3><ul>"
    $html += "<li><b>Owner:</b> $($gpo.Owner)</li>"
    $html += "<li><b>Linked OUs:</b> $($gpo.LinkedOUs)</li>"
    $html += "<li><b>Security Scope:</b> $($gpo.SecurityScope)</li>"
    $html += "<li><b>Settings:</b> $($gpo.Settings)</li>"
    $html += "<li><b>HTML:</b> <a href='$($gpo.HTMLReport)'>Open Report</a></li></ul>"
    $html += "<pre>$($gpo.PolicySummary)</pre>"
}
$html += "</body></html>"

$html | Set-Content -Path $htmlOut -Encoding UTF8

# === Completion
Write-Host "`n[SUCCESS] GPO Discovery Complete"
Write-Host " JSON Summary     : $jsonOut"
Write-Host " Dashboard CSV    : $csvOut"
Write-Host " HTML Summary     : $htmlOut"
Write-Host " GPO HTML Archive : $archiveOut\*.html"