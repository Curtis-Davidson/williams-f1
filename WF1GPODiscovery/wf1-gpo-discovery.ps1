# ======================================================
# Williams F1 | GPO Discovery Module – Enhanced v2025.6.4
# File: /WF1GPODiscovery/wf1-gpo-discovery.ps1
# Author: Paul R Davidson & Urbantek
# Purpose: Enumerate, summarise, and export GPO data
# Output: JSON + HTML (Collapsible) + Markdown + CSV
# ======================================================

Import-Module GroupPolicy
Import-Module ActiveDirectory

# === Setup Paths & Timestamps ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportBase   = "$PSScriptRoot\Results"
$htmlArchive  = Join-Path $exportBase "html_reports_$ts"
$jsonOut      = Join-Path $exportBase "wf1_gpo_summary_$ts.json"
$htmlOut      = Join-Path $exportBase "wf1_gpo_summary_$ts.html"
$csvOut       = Join-Path $exportBase "wf1_gpo_dashboard_$ts.csv"
$mdOut        = Join-Path $exportBase "wf1_gpo_summary_$ts.md"

# === Create Needed Folders ===
@($exportBase, $htmlArchive) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -Path $_ -ItemType Directory | Out-Null }
}

Write-Host "[INFO] Pulling all GPOs in AD domain..." -ForegroundColor Cyan
$gpos        = Get-GPO -All
$ous         = Get-ADOrganizationalUnit -Filter * -Properties gPLink
$gpoSummary  = @()
$dashboard   = @{}
$linkedOUs   = @{}

# === Main GPO Enumeration Loop ===
foreach ($gpo in $gpos) {
    $xmlReport = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    $htmlReport = Get-GPOReport -Guid $gpo.Id -ReportType Html
    $xml = [xml]$xmlReport

    $safeName = $gpo.DisplayName -replace '[^a-zA-Z0-9\-]', '_'
    $htmlPath = Join-Path $htmlArchive "$safeName.html"
    $htmlReport | Out-File -Encoding utf8 -FilePath $htmlPath

    $settings = $xml.GPO.Computer.ExtensionData | ForEach-Object { $_.Name }
    $linkedThisGpo = @()

    foreach ($ou in $ous) {
        if ($ou.gPLink -and $ou.gPLink -match $gpo.Id.Guid) {
            $linkedOUs[$ou.DistinguishedName] = $true
            $linkedThisGpo += $ou.DistinguishedName
        }
    }

    $securityFilter = (Get-GPPermissions -Guid $gpo.Id -All -ErrorAction SilentlyContinue) |
            Where-Object { $_.Permission -match "GpoApply" } |
            Select-Object -ExpandProperty Trustee

    foreach ($type in $settings) {
        if ($type) {
            $dashboard[$type] = $dashboard[$type] + 1
        }
    }

    $gpoSummary += [PSCustomObject]@{
        Name          = $gpo.DisplayName
        GUID          = $gpo.Id
        Owner         = $gpo.Owner
        Created       = $gpo.CreationTime
        Modified      = $gpo.ModificationTime
        LinkedOUs     = $linkedThisGpo.Count
        SecurityScope = ($securityFilter -join ", ")
        Settings      = ($settings -join ", ")
        HTMLReport    = $htmlPath
    }
}

# === OU Coverage Reporting ===
Write-Host "[INFO] Detecting OUs without GPOs..." -ForegroundColor Cyan
$allOUs   = $ous | Select-Object -ExpandProperty DistinguishedName
$noGpoOUs = $allOUs | Where-Object { -not $linkedOUs.ContainsKey($_) }

# === Output JSON ===
$exportData = @{
    Timestamp = $ts
    Summary   = $gpoSummary
    NoGpoOUs  = $noGpoOUs
}
$exportData | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOut -Encoding UTF8

# === Output CSV ===
$dashboard.GetEnumerator() | Sort-Object Name | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# === Output HTML Summary (with collapsible sections) ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Williams F1 – GPO Dashboard</title>
<style>
body { font-family: Segoe UI, sans-serif; background: #f4f4f4; padding: 20px; color: #333; }
h1, h2 { color: #004B8D; }
details { margin-top: 10px; background: #fff; border: 1px solid #ccc; padding: 10px; }
summary { font-weight: bold; font-size: 1.1em; cursor: pointer; }
table { border-collapse: collapse; width: 100%; margin-top: 10px; }
th, td { border: 1px solid #aaa; padding: 8px; }
th { background-color: #004B8D; color: white; }
tr:nth-child(even) { background: #eef3f9; }
</style>
</head><body>
<h1>Williams F1 – Group Policy Summary</h1>
<p><b>Generated:</b> $(Get-Date)</p>

<details open><summary>Dashboard Summary</summary>
<table><tr><th>Category</th><th>Count</th></tr>
"@

foreach ($entry in $dashboard.GetEnumerator() | Sort-Object Name) {
    $html += "<tr><td>$($entry.Name)</td><td>$($entry.Value)</td></tr>"
}
$html += "</table></details>"

$html += "<details><summary>OUs Without GPO Links</summary><ul>"
foreach ($ou in $noGpoOUs) {
    $html += "<li>$ou</li>"
}
$html += "</ul></details></body></html>"

$html | Set-Content -Path $htmlOut -Encoding UTF8

# === Output GitHub Markdown Summary ===
$md = @"
# Williams F1 – Group Policy Report

**Generated:** $(Get-Date)

##  Dashboard Summary
| Category | Count |
|----------|-------|
"@
foreach ($entry in $dashboard.GetEnumerator() | Sort-Object Name) {
    $md += "| $($entry.Name) | $($entry.Value) |`n"
}

$md += @"

##  OUs Without Linked GPOs
"@
foreach ($ou in $noGpoOUs) {
    $md += "- $ou`n"
}
$md | Set-Content -Path $mdOut -Encoding UTF8

# === Completion ===
Write-Host "`n[SUCCESS] GPO Discovery Complete"
Write-Host " JSON Summary     : $jsonOut"
Write-Host " Dashboard CSV    : $csvOut"
Write-Host " HTML Summary     : $htmlOut"
Write-Host " Markdown Report  : $mdOut"
Write-Host " HTML Archive     : $htmlArchive\*.html"