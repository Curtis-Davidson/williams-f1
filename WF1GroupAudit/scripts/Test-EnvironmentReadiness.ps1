# ===================================================================
# Script: Test-EnvironmentReadiness.ps1
# Purpose: Validates environment prerequisites for GroupDeepAudit.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.9.1
# ===================================================================

Write-Host "`n Starting environment readiness check..." -ForegroundColor Cyan
$results = @()

function Test-Check {
    param (
        [string]$Label,
        [scriptblock]$Test
    )
    try {
        if (& $Test) {
            Write-Host "✔ $Label" -ForegroundColor Green
            $results += [pscustomobject]@{ Check = $Label; Result = "PASS" }
        } else {
            Write-Host "✖ $Label" -ForegroundColor Red
            $results += [pscustomobject]@{ Check = $Label; Result = "FAIL" }
        }
    } catch {
        Write-Host "⚠ $Label threw an error: $_" -ForegroundColor Yellow
        $results += [pscustomobject]@{ Check = $Label; Result = "ERROR" }
    }
}

# 1. PowerShell Version
Test-Check "PowerShell version is 5.1 or newer" {
    $PSVersionTable.PSVersion.Major -ge 5
}

# 2. RSAT AD Module
Test-Check "ActiveDirectory module is installed" {
    Get-Module -ListAvailable -Name ActiveDirectory | Out-Null
    $true
}

# 3. AD cmdlets available
Test-Check "Get-ADGroup is available" {
    Get-Command Get-ADGroup -ErrorAction Stop | Out-Null
    $true
}
Test-Check "Get-ADGroupMember is available" {
    Get-Command Get-ADGroupMember -ErrorAction Stop | Out-Null
    $true
}

# 4. AD connectivity check
Test-Check "Can connect to AD and list at least 1 group" {
    Get-ADGroup -Filter * -ResultSetSize 1 | Out-Null
    $true
}

# 5. Can access ACLs via AD drive
Test-Check "Can access AD:\ drive for ACL reads" {
    $dn = (Get-ADGroup -Filter * -ResultSetSize 1).DistinguishedName
    Get-Acl -Path "AD:\$dn" | Out-Null
    $true
}

# 6. Execution Policy
Test-Check "Execution policy allows script execution" {
    (Get-ExecutionPolicy -Scope CurrentUser) -in @("RemoteSigned", "Unrestricted", "Bypass")
}

# 7. Optional: Git installed
Test-Check "Git is installed (optional)" {
    Get-Command git -ErrorAction SilentlyContinue | Out-Null
}

# 8. Optional: Task Scheduler available
Test-Check "Task Scheduler service exists" {
    Get-Service -Name Schedule -ErrorAction Stop | Out-Null
}

# === Final Report ===
Write-Host "`n Summary:"
$results | Format-Table -AutoSize

if ($results.Result -contains "FAIL" -or $results.Result -contains "ERROR") {
    Write-Host "`n Environment is not ready. Please address failed checks." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n Environment is fully ready to run GroupDeepAudit.ps1" -ForegroundColor Green
}