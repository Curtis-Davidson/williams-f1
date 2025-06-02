# =============================================
# Williams F1 Workstation Audit – Local User + Software + Rights
# File: /scripts/williamsf1-workstation-audit.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.6.4
# =============================================

# === REQUIREMENTS CHECK ===
$reqScript = "$PSScriptRoot\..\requirements\workstation-requirements.ps1"
if (Test-Path $reqScript) {
    Write-Host "[INIT] Running workstation requirements check..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$reqScript`"" -Wait
    Start-Sleep -Seconds 2
} else {
    Write-Warning "[WARN] Requirements script not found: $reqScript"
}

# === IMPORT ===
. "$PSScriptRoot\..\config\workstation-config.ps1"
. "$PSScriptRoot\..\lib\workstation-core.ps1"

Write-Host "`n[INFO] Starting Williams F1 Workstation Audit..." -ForegroundColor Cyan

# === OUTPUT SETUP ===
if (!(Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

# === INIT CSV + Markdown ===
"Hostname,Username,ProfilePath,Groups,LastLogon,Drives,Apps,Rights" | Out-File $csvOut -Encoding UTF8

@"
# Williams F1 – Workstation Profile + Rights Audit
**Generated:** $ts
**Hostname:** $(hostname)
**Scope:** Local Workstation Bindings, Shared Accounts, Apps, Rights

---

| Username | ProfilePath | Last Logon | Drives | Applications |
|----------|-------------|------------|--------|--------------|
"@ | Out-File $mdOut -Encoding UTF8

$htmlHeader = @"
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<title>Williams F1 Workstation Audit</title>
<style>
  body { font-family: Segoe UI, sans-serif; background: #1e1e1e; color: #ccc; padding: 16px; }
  table { width: 100%; border-collapse: collapse; margin-top: 16px; }
  th, td { border: 1px solid #444; padding: 8px; }
  th { background: #007acc; color: white; }
  tr:nth-child(even) { background-color: #2a2a2a; }
</style>
</head>
<body>
<h1>Williams F1 – Workstation User & App Audit</h1>
<p><b>Generated:</b> $ts</p>
<table>
<tr><th>Username</th><th>Profile</th><th>LastLogon</th><th>Drives</th><th>Applications</th><th>Rights</th></tr>
"@
$htmlHeader | Out-File $htmlOut -Encoding UTF8

$jsonData = @()

# === MAIN LOOP ===
$profiles = Get-UserProfiles
foreach ($profile in $profiles) {
    $user     = $profile.UserName
    $path     = $profile.Path
    $lastSeen = $profile.LastUseTime
    $apps     = Get-InstalledApplications
    $drives   = Get-MappedDrives -username $user
    $rights   = Get-UserRightsAssignments -username $user
    $groups   = Get-LoggedInUsers | Where-Object { $_ -eq $user }

    # === CSV ===
    "$env:COMPUTERNAME,$user,$path,$($groups -join ';'),$lastSeen,$($drives -join ';'),$($apps -join ';'),$($rights -join ';')" |
            Out-File $csvOut -Append -Encoding UTF8

    # === Markdown ===
    "| $user | $path | $lastSeen | $($drives.Count) | $($apps.Count) |" | Out-File $mdOut -Append -Encoding UTF8

    # === HTML ===
    "<tr><td>$user</td><td>$path</td><td>$lastSeen</td><td>$($drives.Count)</td><td>$($apps.Count)</td><td>$($rights -join '<br>')</td></tr>" |
            Out-File $htmlOut -Append -Encoding UTF8

    # === JSON ===
    $jsonData += [PSCustomObject]@{
        Hostname     = $env:COMPUTERNAME
        Username     = $user
        ProfilePath  = $path
        LastSeen     = $lastSeen
        Groups       = $groups
        Drives       = $drives
        Applications = $apps
        Rights       = $rights
    }
}

# === CLOSE HTML TABLE + EXPORT JSON ===
"</table></body></html>" | Out-File $htmlOut -Append -Encoding UTF8
$jsonData | ConvertTo-Json -Depth 5 | Out-File $jsonOut -Encoding UTF8

# === STATUS ===
Write-Host "[DONE] Workstation audit complete:"
Write-Host " CSV     : $csvOut"
Write-Host " Markdown: $mdOut"
Write-Host " HTML    : $htmlOut"
Write-Host " JSON    : $jsonOut"
Write-Host " Log     : $log"