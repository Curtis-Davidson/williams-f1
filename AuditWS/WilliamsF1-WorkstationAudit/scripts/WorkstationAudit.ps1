# =====================================================================
# Title: Williams F1 Workstation Audit
# Purpose: Full workstation environment audit with FSLogix + GPO + Git
# Author: Paul R Davidson (Urbantek)
# Version: 2025.6.4
# Rule 6 Compliant:
# =====================================================================

# === ENVIRONMENT PREP ===
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRoot\..\config\workstation-config.ps1"
. "$PSScriptRoot\..\lib\workstation-core.ps1"
. "$PSScriptRoot\..\lib\workstation-model.ps1"

# === REQUIREMENTS CHECK ===
$reqScript = "$PSScriptRoot\..\requirements\workstation-requirements.ps1"
if (Test-Path $reqScript) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$reqScript`"" -Wait
}

# === OUTPUT INIT ===
if (!(Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
"Hostname,Username,ProfilePath,Groups,LastLogon,Drives,Apps,Rights,FSLogix,GPO" | Out-File $csvOut -Encoding UTF8

# === HTML INIT ===
$html = @"
<!DOCTYPE html>
<html>
<head>
<title>Williams F1 Workstation Audit</title>
<style>
body { font-family: Segoe UI; background: #111; color: #eee; }
table { border-collapse: collapse; width: 100%; }
th, td { padding: 8px; border: 1px solid #444; }
th { background: #007acc; color: white; }
tr:nth-child(even) { background: #222; }
</style>
</head>
<body>
<h1>Williams F1 Workstation Audit</h1>
<p>Generated: $ts</p>
<table><tr>
<th>User</th><th>Profile</th><th>Last Logon</th><th>Drives</th><th>Apps</th><th>Rights</th><th>FSLogix</th><th>GPO</th>
</tr>
"@

# === MAIN LOOP ===
$jsonData = @()
$profiles = Get-UserProfiles
foreach ($profile in $profiles) {
    $user     = $profile.UserName
    $path     = $profile.Path
    $lastSeen = $profile.LastUseTime
    $apps     = Get-InstalledApplications
    $drives   = Get-MappedDrives -username $user
    $rights   = Get-UserRightsAssignments -username $user
    $groups   = Get-LoggedInUsers | Where-Object { $_ -eq $user }
    $fslogix  = Test-FSLogixProfilePresence -username $user
    $gpo      = Get-GPOReportForUser -username $user

    # === OUTPUT TO CSV ===
    "$env:COMPUTERNAME,$user,$path,$($groups -join ';'),$lastSeen,$($drives -join ';'),$($apps -join ';'),$($rights -join ';'),$fslogix,$gpo" |
            Out-File $csvOut -Append -Encoding UTF8

    # === JSON ===
    $jsonData += [WorkstationAuditRecord]::new($user, $path, $lastSeen, $groups, $drives, $apps, $rights, $fslogix, $gpo)

    # === HTML ===
    $html += "<tr><td>$user</td><td>$path</td><td>$lastSeen</td><td>$($drives.Count)</td><td>$($apps.Count)</td><td>$($rights.Count)</td><td>$fslogix</td><td>$gpo</td></tr>"
}

$html += "</table></body></html>"
$html | Out-File $htmlOut -Encoding UTF8
$jsonData | ConvertTo-Json -Depth 5 | Out-File $jsonOut -Encoding UTF8

# === GIT VERSIONING ===
if (Get-Command git -ErrorAction SilentlyContinue) {
    git -C $OutDir init
    git -C $OutDir add *.json
    git -C $OutDir commit -m "Audit snapshot $ts" --quiet
    git -C $OutDir tag -a "audit-$ts" -m "Audit snapshot $ts"
}

Write-Host "[DONE] Audit complete: $OutDir" -ForegroundColor Green