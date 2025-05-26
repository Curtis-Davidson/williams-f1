# =============================================
# Williams F1 Workstation Module Requirements
# File: /requirements/workstation-requirements.ps1
# Author: Curtis-Davidson & G
# =============================================

$log = "$PSScriptRoot\..\logs\requirements-workstation.log"
"=== [$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')] ===" | Out-File $log -Append

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# === STEP 1: Admin Rights Check ===
if (-not (Test-IsAdmin)) {
    Write-Warning "[ERROR] Script not running as Administrator"
    "ERROR: Not running as admin" | Out-File $log -Append
    exit 1
}

# === STEP 2: Execution Policy Check ===
$policy = Get-ExecutionPolicy
if ($policy -eq 'Restricted') {
    Write-Warning "[ERROR] Execution Policy is 'Restricted'. Change to 'RemoteSigned' or 'Bypass'"
    "ERROR: Execution policy = Restricted" | Out-File $log -Append
    exit 1
}

# === STEP 3: Required Modules Check ===
$requiredModules = @(
    'Microsoft.PowerShell.LocalAccounts',
    'CimCmdlets',
    'ImportExcel'
)

foreach ($mod in $requiredModules) {
    try {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            Write-Host "[INFO] Installing missing module: $mod"
            Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            "Installed module: $mod" | Out-File $log -Append
        } else {
            Write-Host "[OK] Module already installed: $mod"
        }
    } catch {
        Write-Warning "[FAIL] Failed to install $mod: $_"
        "FAIL: $mod => $_" | Out-File $log -Append
    }
}

Write-Host "[SUCCESS] Workstation requirements verified."
"SUCCESS: Workstation requirements validated" | Out-File $log -Append