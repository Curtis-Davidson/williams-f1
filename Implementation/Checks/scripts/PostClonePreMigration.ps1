# =====================================================================
# E5-PreDetach.ps1 (corp-safe path)
# Purpose:
#   Cleanly detach CURRENT USER from Entra ID / Work or School accounts
#   on a Windows 10/11 domain-joined machine BEFORE profile migration.
# =====================================================================

$ErrorActionPreference = 'Stop'

# 1) Setup logging
$Root    = 'C:\Scripts\PreMig'   # <- only hardcoded location
$LogFile = Join-Path $Root ("E5-PreDetach-" + (Get-Date -f yyyyMMdd-HHmmss) + ".log")
New-Item -ItemType Directory -Path $Root -Force | Out-Null
function Log($m) {
    $line = "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')  $m"
    $line | Tee-Object -FilePath $LogFile -Append | Out-Null
}
Log "=== E5-PreDetach START ==="
Log "User = $env:USERNAME  Profile = $env:USERPROFILE  Computer = $env:COMPUTERNAME"

# 2) Baseline: current device/user join state
Log "--- dsregcmd /status (before) ---"
$dsBefore = dsregcmd /status 2>&1
$dsBefore | Out-File -FilePath (Join-Path $Root 'dsregcmd-before.txt') -Encoding UTF8
$dsBefore -split "`r?`n" | Where-Object {$_ -match 'AzureAdJoined|WorkplaceJoined|WamDefaultSet|DomainJoined'} | ForEach-Object { Log $_ }

# 3) Stop apps that hold MSAL tokens
$procs = 'OUTLOOK','WINWORD','EXCEL','POWERPNT','Teams','msedge','OneDrive','TokenBroker','Microsoft.AAD.BrokerPlugin'
foreach ($p in $procs) {
    Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
        Log "Stopping $($p) (PID=$($_.Id))"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# 4) Try to disconnect Work/School via supported API first
try {
    Log "Invoking WorkplaceLeave()..."
    $dm = New-Object -ComObject "Workplace.JoinManager"
    $dm.WorkplaceLeave() | Out-Null
    Log "WorkplaceLeave() invoked."
} catch {
    Log "WorkplaceLeave() not available on this build: $_"
}

# 5) Leave Entra (AAD) for THIS user/device
try {
    Log "Running dsregcmd /leave ..."
    dsregcmd /leave | Out-Null
    Log "dsregcmd /leave completed."
} catch {
    Log "dsregcmd /leave failed: $_"
}

# 6) Clear WAM / AAD Broker / TokenBroker caches
$WamBase  = "$env:LOCALAPPDATA\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\TokenBroker"
$WamCache = Join-Path $WamBase 'Cache'
$TokenDir = "$env:LOCALAPPDATA\Microsoft\TokenBroker"
$OneAuth  = "$env:LOCALAPPDATA\Microsoft\OneAuth"

if (Test-Path $WamCache) {
    Log "Clearing WAM cache at $WamCache"
    Remove-Item $WamCache -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Log "WAM cache not found (skip)."
}

if (Test-Path $TokenDir) {
    Log "Clearing TokenBroker at $TokenDir"
    Remove-Item $TokenDir -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $OneAuth) {
    Log "Clearing OneAuth at $OneAuth"
    Remove-Item $OneAuth -Recurse -Force -ErrorAction SilentlyContinue
}

# 7) Clear Office identity
$OfficeIdKey = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
if (Test-Path $OfficeIdKey) {
    Log "Removing Office Identity registry key $OfficeIdKey"
    Remove-Item $OfficeIdKey -Recurse -Force -ErrorAction SilentlyContinue
}
$OfficeLic = "$env:LOCALAPPDATA\Microsoft\Office\16.0\Licensing"
if (Test-Path $OfficeLic) {
    Log "Removing Office Licensing dir $OfficeLic"
    Remove-Item $OfficeLic -Recurse -Force -ErrorAction SilentlyContinue
}

# 8) Purge Credential Manager entries
Log "Enumerating Credential Manager stored targets..."
$credRaw = cmdkey /list 2>&1
$credRaw | Out-File -FilePath (Join-Path $Root 'CredMan-before.txt') -Encoding UTF8
$patterns = @('MicrosoftOffice','MSOffice','aad:','msteams','msonline','OneAuth','passport')
$targets = ($credRaw -split "`r?`n") | Where-Object {$_ -like ' *Target:*'} | ForEach-Object {
    ($_ -split 'Target:\s*')[1].Trim()
}
$targetsToDelete = @()
foreach ($t in $targets) {
    foreach ($pat in $patterns) {
        if ($t -like "*$pat*") { $targetsToDelete += $t; break }
    }
}
$targetsToDelete = $targetsToDelete | Sort-Object -Unique
foreach ($t in $targetsToDelete) {
    Log "Deleting credman target: $t"
    cmdkey /delete:$t | Out-Null
}

# 9) Edge / Teams
$EdgeBase = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
if (Test-Path $EdgeBase) {
    Log "Clearing Edge sign-in artefacts under $EdgeBase"
    Remove-Item "$EdgeBase\Web Data" -Force -ErrorAction SilentlyContinue
    Remove-Item "$EdgeBase\Login Data" -Force -ErrorAction SilentlyContinue
}
$TeamsBase = "$env:APPDATA\Microsoft\Teams"
if (Test-Path $TeamsBase) {
    Log "Clearing Teams cache at $TeamsBase"
    Remove-Item $TeamsBase -Recurse -Force -ErrorAction SilentlyContinue
}

# 10) Re-register Broker plugin
try {
    Log "Resetting Microsoft.AAD.BrokerPlugin package..."
    Get-AppxPackage Microsoft.AAD.BrokerPlugin | Reset-AppxPackage
} catch {
    Log "Reset-AppxPackage failed (older build?) : $_"
}

# 11) Final state
Log "--- dsregcmd /status (after) ---"
$dsAfter = dsregcmd /status 2>&1
$dsAfter | Out-File -FilePath (Join-Path $Root 'dsregcmd-after.txt') -Encoding UTF8
$dsAfter -split "`r?`n" | Where-Object {$_ -match 'AzureAdJoined|WorkplaceJoined|WamDefaultSet|DomainJoined'} | ForEach-Object { Log $_ }

Log "=== E5-PreDetach END ==="
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " PRE-DETACH DONE" -ForegroundColor Green
Write-Host " 1. REBOOT this machine." -ForegroundColor Yellow
Write-Host " 2. After reboot, run:  dsregcmd /status" -ForegroundColor Yellow
Write-Host " 3. Verify: AzureAdJoined=NO, WorkplaceJoined=NO" -ForegroundColor Yellow
Write-Host " 4. Then do your profile migration + re-add new work/school." -ForegroundColor Yellow
Write-Host "Logs: $LogFile" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan