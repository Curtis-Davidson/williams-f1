# ===========================================================
# Script: Test-EnvironmentReadiness.ps1
# Purpose: Verifies that the system has the required modules
# and environment readiness to run GroupDeepAudit.ps1 safely.
# Author: Paul R Davidson (Urbantek)
# ===========================================================

function Test-EnvironmentReadiness {

    $errors = @()

    # === Check for RSAT AD Module ===
    if (-not (Get-Command Get-ADUser -ErrorAction SilentlyContinue)) {
        $errors += "Missing RSAT: Active Directory PowerShell module (Get-ADUser not found)."
    }

    # === Check for ActiveDirectory PSDrive (AD:\) ===
    if (-not (Test-Path "AD:\") -and (Get-Module -Name ActiveDirectory -ListAvailable)) {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        } catch {
            $errors += " ActiveDirectory module failed to import."
        }
    }

    # === Check for Git (optional) ===
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
        $errors += "Git CLI not found – versioning exports will be disabled."
    }

    # === Check Export Paths Writeable ===
    $testPath = Join-Path $PSScriptRoot "..\exports\_test_write.txt"
    try {
        "test" | Out-File -FilePath $testPath -Encoding UTF8 -Force
        Remove-Item $testPath -Force
    } catch {
        $errors += " Cannot write to exports folder. Check permissions: $testPath"
    }

    # === Display Result ===
    if ($errors.Count -eq 0) {
        Write-Host "`n Environment is fully ready to run GroupDeepAudit.ps1" -ForegroundColor Green
        return $true
    } else {
        Write-Host "`n Environment readiness failed:`n" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
        return $false
    }
}

# === Invoke if standalone ===
if ($MyInvocation.InvocationName -eq '.') {
    Test-EnvironmentReadiness
}
