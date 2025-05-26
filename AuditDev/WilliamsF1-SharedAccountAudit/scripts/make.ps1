Set-Content -Path "C:\AuditDev\WilliamsF1-SharedAccountAudit\scripts\make.ps1" -Encoding UTF8 -Value @"
# =============================================
# MAKE SCRIPT: Master Runner for Full Audit Job
# File: /scripts/make.ps1
# Author: Curtis-Davidson & Urbantek
# Version: 2025.6.4
# =============================================

Write-Host "`n=== Williams F1 Shared Account Audit – MAKE RUNNER ===" -ForegroundColor Cyan

# === STEP 0: Run Requirements ===
\$req = "\$PSScriptRoot\..\requirements\ensure-requirements.ps1"
if (Test-Path \$req) {
    Write-Host "[STEP 0] Checking requirements..." -ForegroundColor Yellow
    & \$req
} else {
    Write-Warning "[WARN] Requirements script not found!"
}

# === STEP 1: Run Main Audit ===
\$audit = "\$PSScriptRoot\williamsf1-ad-audit.ps1"
if (Test-Path \$audit) {
    Write-Host "`n[STEP 1] Running Full AD Audit..." -ForegroundColor Yellow
    & \$audit
} else {
    Write-Warning "[FAIL] Audit script not found at: \$audit"
    exit 1
}

# === STEP 2: Auto-Tag Git (if in repo) ===
\$gitFolder = "\$PSScriptRoot\.."
if (Test-Path "\$gitFolder\.git") {
    Write-Host "`n[STEP 2] Auto-tagging Git snapshot..." -ForegroundColor Gray
    \$tagName = "audit-\$(Get-Date -Format 'yyyyMMdd-HHmm')"
    Push-Location \$gitFolder
    git add . ; git commit -m "Auto snapshot: \$tagName"
    git tag -a \$tagName -m "Audit run: \$tagName"
    git push origin --tags
    Pop-Location
} else {
    Write-Host "[INFO] Git repo not detected — skipping version tagging." -ForegroundColor DarkGray
}

Write-Host "`n MAKE RUN COMPLETE " -ForegroundColor Green
"@