# =============================================
# Makefile-Style Audit Runner for Williams F1
# File: /scripts/make.ps1
# Author: Curtis-Davidson & G
# =============================================

param (
    [ValidateSet("workstation", "shareduser", "all")]
    [string]$target = "all"
)

$base = $PSScriptRoot
$ts = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
Write-Host "`n[MAKE] Running $target @ $ts" -ForegroundColor Green

switch ($target) {
    "workstation" {
        & "$base\williamsf1-workstation-audit.ps1"
    }

    "shareduser" {
        & "$base\williamsf1-ad-audit.ps1"
    }

    "all" {
        & "$base\williamsf1-workstation-audit.ps1"
        & "$base\williamsf1-ad-audit.ps1"
    }
}