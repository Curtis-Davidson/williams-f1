# ==========================================================
# Williams F1 - Makefile Wrapper
# File: /Scripts/Makefile.ps1
# Description: Trigger logon audit or other modules cleanly
# Author: Paul R Davidson & Urbantek
# ==========================================================

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("logon-audit", "shared-audit", "export-reports")]
    [string]$Target
)

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = "$basePath\.."

switch ($Target) {

    "logon-audit" {
        Write-Host "`n==> [LOGON AUDIT INITIATED]"

        $reqScript = Join-Path $root "Requirements\logon-requirements.ps1"
        $mainScript = Join-Path $root "Security\Get-LogonAuditReport.ps1"

        if (Test-Path $reqScript) {
            Write-Host "→ Checking system requirements..."
            powershell -ExecutionPolicy Bypass -File $reqScript
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Aborting logon audit due to failed requirement check."
                exit $LASTEXITCODE
            }
        }

        if (Test-Path $mainScript) {
            Write-Host "→ Running logon audit..."
            powershell -ExecutionPolicy Bypass -File $mainScript
        } else {
            Write-Error "Audit script not found: $mainScript"
            exit 127
        }
    }

    "shared-audit" {
        Write-Host "→ Shared account audit not implemented yet"
    }

    "export-reports" {
        Write-Host "→ Export logic to be implemented"
    }

    default {
        Write-Host "No valid target provided"
    }
}