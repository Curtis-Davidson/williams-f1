# ======================================================
# Williams F1 | AD Group Discovery Module – v2025.6.4
# File: /WF1GroupDiscovery/wf1-group-discovery.ps1
# Author: Paul R Davidson & Urbantek
# Purpose: Discover all AD groups, members, scopes, and ownership
# Output: JSON + HTML + Markdown + CSV + XML
# ======================================================

Import-Module ActiveDirectory

# === Timestamp & Export Paths ===
$ts        = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = "$PSScriptRoot\Results"
$jsonOut   = Join-Path $exportDir "wf1_group_summary_$ts.json"
$csvOut    = Join-Path $exportDir "wf1_group_acl_matrix_$ts.csv"
$mdOut     = Join-Path $exportDir "wf1_group_summary_$ts.md"
$htmlOut   = Join-Path $exportDir "wf1_group_summary_$ts.html"
$xmlOut    = Join-Path $exportDir "wf1_group_summary_$ts.xml"

# === Ensure Export Directory Exists ===
if (-not (Test-Path $exportDir)) {
    New-Item -Path $exportDir -ItemType Directory | Out-Null
}

# === Fetch Groups
Write-Host "[INFO] Fetching all AD groups..." -ForegroundColor Cyan
$groups = Get-ADGroup -Filter * -Properties *

# === Collect Data
$groupSummary = @()

foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group.DistinguishedName -Recursive -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty SamAccountName

    $groupSummary += [PSCustomObject]@{
        Name        = $group.Name
        Description = $group.Description
        Scope       = $group.GroupScope
        Type        = $group.GroupCategory
        Members     = ($members -join ", ")
        MemberCount = $members.Count
        Owner       = $group.ManagedBy
        Created     = $group.WhenCreated
        Modified    = $group.Modified
        DN          = $group.DistinguishedName
    }
}

# === Export JSON
$groupSummary | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOut -Encoding UTF8

# === Export CSV
$groupSummary | Export-Csv -Path $csvOut -Encoding UTF8 -NoTypeInformation

# === Export Markdown
$md = @"
#  WF1 AD Group Summary

**Generated:** $ts
**Total Groups:** $($groupSummary.Count)

| Group Name | Members | Scope | Owner |
|------------|---------|-------|--------|
"@

foreach ($group in $groupSummary) {
    $md += "| $($group.Name) | $($group.MemberCount) | $($group.Scope) | $($group.Owner) |`n"
}
$md | Set-Content -Path $mdOut -Encoding UTF8

# === Export HTML Summary
$html = @"
<!DOCTYPE html><html><head><meta charset="utf-8">
<title>WF1 AD Group Report</title>
<style>
body { font-family: Segoe UI; background: #f9f9f9; padding: 20px; color: #333; }
h1, h2 { color: #004B8D; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #aaa; padding: 8px; }
th { background-color: #004B8D; color: white; }
tr:nth-child(even) { background-color: #eef2f7; }
</style></head><body>
<h1>WF1 Active Directory Group Report</h1>
<p><b>Generated:</b> $(Get-Date)</p>
<table><tr>
<th>Name</th><th>Scope</th><th>Type</th><th>Owner</th><th>MemberCount</th></tr>
"@

foreach ($group in $groupSummary) {
    $html += "<tr><td>$($group.Name)</td><td>$($group.Scope)</td><td>$($group.Type)</td><td>$($group.Owner)</td><td>$($group.MemberCount)</td></tr>"
}
$html += "</table></body></html>"
$html | Set-Content -Path $htmlOut -Encoding UTF8

# === Export XML
$xmlDoc = New-Object System.Xml.XmlDocument
$root   = $xmlDoc.CreateElement("Groups")
$xmlDoc.AppendChild($root) | Out-Null

foreach ($group in $groupSummary) {
    $gNode = $xmlDoc.CreateElement("Group")
    foreach ($prop in $group.PSObject.Properties) {
        $child = $xmlDoc.CreateElement($prop.Name)
        $child.InnerText = $prop.Value
        $gNode.AppendChild($child) | Out-Null
    }
    $root.AppendChild($gNode) | Out-Null
}
$xmlDoc.Save($xmlOut)

# === Completion
Write-Host "`n[SUCCESS] AD Group Discovery Complete"
Write-Host " JSON Summary   : $jsonOut"
Write-Host " CSV Matrix     : $csvOut"
Write-Host " Markdown Table : $mdOut"
Write-Host " HTML Dashboard : $htmlOut"
Write-Host " XML Export     : $xmlOut"