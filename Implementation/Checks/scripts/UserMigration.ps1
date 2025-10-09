# C:\Scripts\UT-Profile-Uplift-TunnelOps.ps1
# Safely clone userland profile data from C:\Backup\TunnelOps to C:\Users\shr-tunops-dia,
# then fix ownership/ACLs for domain account williamsf1\shr-tunops-dia.
# Excludes risky system/credential artefacts.

$ErrorActionPreference = 'Stop'

$Source        = 'C:\Backup\TunnelOps'
$Target        = 'C:\Users\shr-tunops-dia'
$TargetAccount = 'williamsf1\shr-tunops-dia'

$LogDir  = 'C:\Temp'
$LogFile = Join-Path $LogDir 'TunnelOps_to_shr-tunops-dia_safe.log'

if (-not (Test-Path $LogDir))   { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $Source))   { throw "Source path not found: $Source" }
if (-not (Test-Path $Target))   { throw "Target path not found: $Target (log on once as the new user to create it)" }
if ($Target -notmatch '^C:\\Users\\[^\\]+$') { throw "Target must be a single user profile folder under C:\Users (got: $Target)" }

Write-Host "Starting profile uplift..." -ForegroundColor Cyan
Write-Host " Source: $Source"
Write-Host " Target: $Target"
Write-Host " Account: $TargetAccount"
Write-Host ""

# Phase 1 — Safe copy
$robocopyArgs = @(
    "`"$Source`"", "`"$Target`"", "/MIR", "/COPY:DAT", "/XJ", "/R:1", "/W:1",
    "/XD",
    "AppData\Local\Microsoft\Credentials",
    "AppData\Local\Microsoft\Crypto",
    "AppData\Local\Temp",
    "AppData\Local\Packages",
    "AppData\LocalLow",
    "/XF",
    "NTUSER.DAT.LOG*",
    "UsrClass.dat.LOG*",
    "NTUSER.DAT{*}",
    "SAM","SECURITY","SYSTEM","SOFTWARE",
    "/LOG:$LogFile"
)

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "$env:SystemRoot\System32\robocopy.exe"
$psi.Arguments = ($robocopyArgs -join ' ')
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $false
$psi.CreateNoWindow = $true

Write-Host "Robocopy running..."
$p = [System.Diagnostics.Process]::Start($psi)
$p.WaitForExit()
$rc = $p.ExitCode
if ($rc -ge 8) { throw "Robocopy failed (ExitCode=$rc). See log: $LogFile" }
Write-Host "Robocopy completed with ExitCode=$rc (OK < 8). Log: $LogFile" -ForegroundColor Green

# Phase 2 — Ownership & ACLs
Write-Host "Fixing ownership and ACLs for $TargetAccount ..."
cmd.exe /c "icacls `"$Target`" /setowner `"$TargetAccount`" /T /C" | Out-Null
cmd.exe /c "icacls `"$Target`" /inheritance:e /grant `"$TargetAccount`":(OI)(CI)F /T /C" | Out-Null

# Phase 3 — Verification
Write-Host "Verifying ACL assignment..."
$expected = @('Desktop','Documents','AppData\Roaming','AppData\Local') |
        ForEach-Object { Join-Path $Target $_ } | Where-Object { Test-Path $_ }

if ($expected.Count -lt 2) {
    Write-Warning "Expected profile subfolders are not all present. Review the source and log at $LogFile."
}

$aclText = (cmd.exe /c "icacls `"$Target`"") 2>&1
if ($aclText -notmatch [Regex]::Escape($TargetAccount)) {
    Write-Warning "Did not see $TargetAccount in top-level ACL output. Inspect manually: icacls `"$Target`""
} else {
    Write-Host "ACL appears to include $TargetAccount." -ForegroundColor Green
}

Write-Host "`nDone. Next:" -ForegroundColor Cyan
Write-Host " 1) (Optional) Copy NTUSER.DAT + UsrClass.dat for desktop/app prefs."
Write-Host " 2) Run ForensIT Profile Wizard to remap registry SIDs (recommended)."
Write-Host " 3) Log in as $TargetAccount and validate apps/configs."