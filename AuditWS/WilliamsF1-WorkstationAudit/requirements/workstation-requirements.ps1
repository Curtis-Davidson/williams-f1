# =============================================
# Williams F1 Workstation Module Requirements
# File: /requirements/workstation-requirements.ps1
# Author: Paul R Davidson & Urbantek
# =============================================

# === Logging Setup ===
$logDir = "$PSScriptRoot\..\logs"
$log = Join-Path $logDir 'requirements-workstation.log'
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
"=== [$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] START: Workstation Requirements Check ===" | Out-File $log -Append

function Log {
    param (
        [ValidateSet("INFO", "WARN", "ERROR", "FAIL", "SUCCESS")]
        [string]$Level,
        [Parameter(Mandatory)][string]$Message
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$Level] $timestamp :: $Message"
    $entry | Out-File $log -Append

    switch ($Level) {
        "INFO"     { Write-Host $entry -ForegroundColor Gray }
        "WARN"     { Write-Warning $entry }
        "ERROR"    { Write-Error $entry }
        "FAIL"     { Write-Host $entry -ForegroundColor Red }
        "SUCCESS"  { Write-Host $entry -ForegroundColor Green }
    }
}

# === STEP 1: Admin Rights Check ===
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Log -Level "ERROR" -Message "Script not running as Administrator. Please re-run as admin."
    exit 1001
}

# === STEP 2: Execution Policy Check ===
$policy = Get-ExecutionPolicy
Log -Level "INFO" -Message "Execution Policy: $policy"
if ($policy -eq 'Restricted') {
    Log -Level "ERROR" -Message "Execution Policy is 'Restricted'. Must be 'RemoteSigned' or 'Bypass'."
    exit 1002
}

# === STEP 3: Required Module Installer ===
function Install-RequiredModule {
    param (
        [Parameter(Mandatory)][string]$ModuleName
    )

    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Log -Level "INFO" -Message "Attempting to install missing module: ${ModuleName}"
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Log -Level "SUCCESS" -Message "Installed module: ${ModuleName}"
        } catch {
            Log -Level "FAIL" -Message "Failed to install ${ModuleName}: $($_.Exception.Message)"
        }
    } else {
        Log -Level "INFO" -Message "Module already present: ${ModuleName}"
    }
}

# === STEP 4: Define & Validate Required Modules ===
$requiredModules = @(
    'Microsoft.PowerShell.LocalAccounts',
    'CimCmdlets',
    'ImportExcel'
)

foreach ($mod in $requiredModules) {
    Install-RequiredModule -ModuleName $mod
}

# === STEP 5: Module Summary Table ===
Write-Host "`n=== [REQUIREMENTS CHECK SUMMARY] ===`n"
Log -Level "INFO" -Message "Generating final module summary"
$summary = @()
foreach ($mod in $requiredModules) {
    $status = if (Get-Module -ListAvailable -Name $mod) { "✓ Present" } else { "✗ Missing" }
    $emoji = if ($status -eq "✓ Present") { "🟢" } else { "🔴" }
    $summary += [PSCustomObject]@{
        Module  = $mod
        Status  = $status
        Check   = $emoji
    }
}

$summary | Format-Table -AutoSize | Tee-Object -Variable _summaryOut | Out-String | ForEach-Object { Write-Host $_ }
Log -Level "SUCCESS" -Message "Workstation requirements validated and logged"

exit 0