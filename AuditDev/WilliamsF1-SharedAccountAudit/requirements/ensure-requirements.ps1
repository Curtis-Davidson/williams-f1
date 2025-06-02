Set-Content -Path "C:\AuditDev\WilliamsF1-SharedAccountAudit\requirements\ensure-requirements.ps1" -Encoding UTF8 -Value @"
# =============================================
# REQUIREMENTS CHECK: Williams F1 AD Audit Stack
# File: /requirements/ensure-requirements.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.6.4
# =============================================

Write-Host "`n[INFO] Checking module requirements..." -ForegroundColor Cyan

# === MODULE: ActiveDirectory ===
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Warning "ActiveDirectory module is not available. This script must be run on a domain-joined machine with RSAT tools installed."
} else {
    Write-Host "[OK] ActiveDirectory module found." -ForegroundColor Green
}

# === MODULE: ImportExcel (for XLSX export) ===
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    try {
        Write-Host "[INSTALLING] ImportExcel..." -ForegroundColor Yellow
        Install-Module -Name ImportExcel -Scope CurrentUser -Force
        Write-Host "[OK] ImportExcel installed." -ForegroundColor Green
    } catch {
        Write-Warning "[FAIL] Failed to install ImportExcel: $_"
    }
} else {
    Write-Host "[OK] ImportExcel module found." -ForegroundColor Green
}

# === EXECUTABLE: wkhtmltopdf (for PDF export) ===
\$wkhtml = "C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe"
if (-not (Test-Path \$wkhtml)) {
    Write-Warning "wkhtmltopdf not found at: \$wkhtml"
    Write-Host "Download from: https://wkhtmltopdf.org/downloads.html"
} else {
    Write-Host "[OK] wkhtmltopdf found at: \$wkhtml" -ForegroundColor Green
}

# === SNAPSHOT + REPORT DIRS ===
\$snapPath = "\$PSScriptRoot\..\snapshots"
\$reportPath = "\$PSScriptRoot\..\reports"
\$polishedPath = "\$PSScriptRoot\..\reports-polished"

foreach (\$dir in @(\$snapPath, \$reportPath, \$polishedPath)) {
    if (!(Test-Path \$dir)) {
        New-Item -Path \$dir -ItemType Directory -Force | Out-Null
        Write-Host "[CREATED] Directory: \$dir" -ForegroundColor DarkGray
    } else {
        Write-Host "[OK] Directory exists: \$dir" -ForegroundColor Gray
    }
}

Write-Host "`n[READY] All required modules, tools, and folders checked." -ForegroundColor Cyan
"@