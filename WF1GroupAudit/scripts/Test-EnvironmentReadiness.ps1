# ====================================================================
# Script: Test-EnvironmentReadiness.ps1
# Author: Paul R Davidson & Urbantek
# Purpose: Ensures environment is ready to run GroupDeepAudit.ps1
# Location: /scripts/Test-EnvironmentReadiness.ps1
# Usage: .\Test-EnvironmentReadiness.ps1 or via Makefile: make verify-env
# ====================================================================

Write-Host "`n[VERIFY] Starting environment dependency check..." -ForegroundColor Cyan

# --- Internal test wrapper ---
function Test-Check {
    param (
        [string]$Description,
        [scriptblock]$Test
    )

    try {
        if (& $Test) {
            Write-Host "[OK] $Description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[FAIL] $Description" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[ERROR] $Description - $_" -ForegroundColor Red
        return $false
    }
}

# --- Run required checks ---
$results = @()

$results += Test-Check "ActiveDirectory module is available" {
    Get-Module -ListAvailable -Name ActiveDirectory | Out-Null
}

$results += Test-Check "Can resolve Get-ADGroup" {
    Get-Command Get-ADGroup -ErrorAction SilentlyContinue | Out-Null
}

$results += Test-Check "Can resolve Get-ADGroupMember" {
    Get-Command Get-ADGroupMember -ErrorAction SilentlyContinue | Out-Null
}

$results += Test-Check "Can resolve Get-Acl" {
    Get-Command Get-Acl -ErrorAction SilentlyContinue | Out-Null
}

$results += Test-Check "Can write to ./exports" {
    $testFile = ".\exports\__test__"
    New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null
    Remove-Item $testFile -Force
    $true
}

$results += Test-Check "Can write to ./results" {
    $testFile = ".\results\__test__"
    New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null
    Remove-Item $testFile -Force
    $true
}

# --- Final result ---
if ($results -contains $false) {
    Write-Host "`n[!] Environment check failed. Please resolve above errors." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n[✔] Environment is fully ready to run GroupDeepAudit.ps1" -ForegroundColor Green
    exit 0
}
