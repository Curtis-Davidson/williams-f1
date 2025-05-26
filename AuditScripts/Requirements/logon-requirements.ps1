# ==========================================================
# Williams F1 - Pre-Run Requirements Check for Logon Audit
# File: /Requirements/logon-requirements.ps1
# Author: Curtis-Davidson & Urbantek
# ==========================================================

$log = "$PSScriptRoot\..\Logs\logon-requirements.log"
"=== [$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting logon audit requirements check ===" | Out-File $log -Append

function Log {
    param (
        [string]$Level,
        [string]$Message
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $msg = "[$Level] $ts :: $Message"
    $msg | Out-File $log -Append
    if ($Level -eq "FAIL" -or $Level -eq "ERROR") {
        Write-Warning $msg
    } else {
        Write-Host $msg
    }
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Log -Level "ERROR" -Message "Script not running as Administrator. Required for audit."
    exit 111
}

$policy = Get-ExecutionPolicy
Log -Level "INFO" -Message "Execution policy is $policy"
if ($policy -eq "Restricted") {
    Log -Level "ERROR" -Message "Execution policy is Restricted. Set to RemoteSigned or Bypass."
    exit 112
}

$modules = @(
    'Microsoft.PowerShell.LocalAccounts',
    'CimCmdlets',
    'ImportExcel'
)

foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        try {
            Log -Level "INFO" -Message "Installing missing module: $mod"
            Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Log -Level "SUCCESS" -Message "$mod installed successfully"
        } catch {
            $errMsg = $_.Exception.Message
            $failMessage = "Failed to install ${mod}: ${errMsg}"
            Log -Level "FAIL" -Message $failMessage
            exit 113
        }
    } else {
        Log -Level "INFO" -Message "Module present: $mod"
    }
}

Log -Level "SUCCESS" -Message "All logon audit requirements met"
exit 0