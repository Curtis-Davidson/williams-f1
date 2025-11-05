# -----------------------------------------------
# WF1 Bootstrap – ensures elevation + runs audit
# -----------------------------------------------
$ErrorActionPreference = 'Stop'
$Base = 'C:\WF1UserAudit'
$Main = Join-Path $Base 'wf1-user-rights-audit.ps1'

# 1) Ensure base folder
New-Item -ItemType Directory -Path $Base -Force | Out-Null

# 2) Ensure we are elevated
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "[INFO] Relaunching elevated..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File",$PSCommandPath `
    -Verb RunAs
    exit
}

# 3) Sanity: main exists
if (-not (Test-Path $Main)) {
    Write-Error "Missing $Main. Create it first, then re-run this bootstrap."
}

# 4) Run the main script (this will prompt for the user)
& $Main