# ==========================================================
# Williams F1 | GPO Discovery Module – Refined v2025.6.3
# File: /WF1GPODiscovery/wf1-gpo-discovery.ps1
# Author: Paul R Davidson & Urbantek
# Purpose: Discover GPOs, extract settings, link/OU coverage
# Output: JSON Summary, HTML Dashboard, CSV Breakdown, GPO Archive
# ==========================================================

Import-Module GroupPolicy

# === Timestamp and Output Paths ===
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$root = "$PSScriptRoot\Results"
$jsonOut     = Join-Path $root "wf1_gpo_summary_$ts.json"
$htmlOut     = Join-Path $root "wf1_gpo_summary_$ts.html"
$csvOut      = Join-Path $root "wf1_gpo_dashboard_$ts.csv"
$archiveDir  = Join-Path $root "html_reports_$ts"

# === Ensure Required Directories Exist ===
@($root, $archiveDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory | Out-Null
    }
}

# === Init
$gpoSummary = @()
$dashboard = @{}
$linkedOUs = @{}
Write-Host "[INFO] Pulling all GPOs in AD domain..." -ForegroundColor Cyan
$gpos = Get-GPO -All

foreach ($gpo in $gpos) {
    try {
        $xmlRaw   = Get-GPOReport -Guid $gpo.Id -ReportType Xml -ErrorAction Stop
        $htmlRaw  = Get-GPOReport -Guid $gpo.Id -ReportType Html -ErrorAction Stop
        $xml      = [xml]$xmlRaw
    } catch {
        Write-Warning "Failed to process GPO: $($gpo.DisplayName)"
        continue
    }

    # === Save Full HTML Archive ===
    $safeName = $gpo.DisplayName -replace '[^a-zA-Z0-9_\-]', '_'
    $htmlFile = Join-Path $archiveDir "$safeName.html"
    $htmlRaw | Out-File -FilePath $htmlFile -Encoding UTF8

    # === Group Settings Summary ===
    $settings = @()
    if ($xml.GPO.Computer.ExtensionData) {
        $settings += $xml.GPO.Computer.ExtensionData.Extension | ForEach-Object { "Computer: $($_.Name)" }
    }
    if ($xml.GPO.User.ExtensionData) {
        $settings += $xml.GPO.User.ExtensionData.Extension | ForEach-Object { "User: $($_.Name)" }
    }

    # === Dashboard Summary
    foreach ($type in $settings) {
        if ($type) {
            if (-not $dashboard.ContainsKey($type)) {
                $dashboard[$type] = 1
            } else {
                $dashboard[$type]++
            }
        }
    }

    # === Linked OUs
    $links = Get-GPOLink -Guid $gpo.Id -Domain $gpo.DomainName -ErrorAction SilentlyContinue
    if ($links) {
        foreach ($l in $links) {
            $linkedOUs[$l.Target] = $true
        }
    }

    # === Security Filtering Summary
    $security = (Get-GPPermissions -Guid $gpo.Id -All -ErrorAction SilentlyContinue |
            Where-Object { $_.Permission -match "GpoApply" }) |
            Select-Object -ExpandProperty Trustee

    # === Summary Entry
    $gpoSummary += [PSCustomObject]@{
        Name          = $gpo.DisplayName
        GUID          = $gpo.Id
        Owner         = $gpo.Owner
        Created       = $gpo.CreationTime
        Modified      = $gpo.ModificationTime
        LinkedOUs     = ($links.Count)
        SecurityScope = ($security -join ", ")
        Settings      = ($settings -join ", ")
        HTMLReport    = $htmlFile
    }
}

# === OU Coverage Summary
Write-Host "[INFO] Scanning OUs for GPO coverage..." -ForegroundColor Cyan
$allOUs = Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
$noGpoOUs = $allOUs | Where-Object { -not $linkedOUs.ContainsKey($_) }

# === Export JSON Summary ===
$exportBlock = @{
    Timestamp = $ts
    Summary   = $gpoSummary
    NoGpoOUs  = $noGpoOUs
}
$exportBlock | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOut -Encoding UTF8

# === Export Dashboard CSV ===
$dashboard.GetEnumerator() | Sort-Object Name |
        Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

# === Build and Export HTML Summary ===
$html = @"
<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Williams F1 – GPO Dashboard</title>
<style>
body { font-family: Segoe UI, sans-serif; background: #f9f9f9; padding: 20px; color: #222; }
h1, h2 { color: #004b8d; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #ccc; padding: 8px; }
th { background: #004b8d; color: white; }
tr:nth-child(even) { background: #f1f1f1; }
</style></head><body>
<h1>Williams F1 – Group Policy Summary</h1>
<p><strong>Generated:</strong> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>

<h2>Settings Breakdown by Category</h2>
<table><tr><th>Setting Category</th><th>Count</th></tr>
"@

foreach ($entry in $dashboard.GetEnumerator() | Sort-Object Name) {
    $html += "<tr><td>$($entry.Name)</td><td>$($entry.Value)</td></tr>"
}

$html += @"
</table>
<h2>OUs Without GPO Links</h2>
<ul>
"@

foreach ($ou in $noGpoOUs) {
    $html += "<li>$ou</li>"
}

$html += "</ul></body></html>"
$html | Set-Content -Path $htmlOut -Encoding UTF8

# === Final Summary
Write-Host "`n[SUCCESS] GPO Discovery Complete" -ForegroundColor Green
Write-Host " → JSON Summary     : $jsonOut"
Write-Host " → HTML Dashboard   : $htmlOut"
Write-Host " → CSV Breakdown    : $csvOut"
Write-Host " → GPO HTML Archive : $archiveDir\*.html"