# ===============================================================
# Makefile-Style Runner for WilliamsF1 Audit Suite
# File: /scripts/make.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.6.4
# Status: Canonical, Rule 6 Compliant
# ===============================================================

param (
    [ValidateSet("workstation", "shareduser", "all", "diff", "schedule", "clean")]
    [string]$target = "all"
)

$base = $PSScriptRoot
$ts = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
Write-Host "`n[MAKE] Running target: $target @ $ts" -ForegroundColor Green

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

    "diff" {
        & "$base\williamsf1-diff-engine.ps1"
    }

    "schedule" {
        Write-Host "[TASK] Creating Task Scheduler Job: Daily Audit @ 04:00" -ForegroundColor Cyan
        $taskName = "WilliamsF1 Workstation Audit"
        $scriptPath = "$base\williamsf1-workstation-audit.ps1"
        schtasks /Create /TN "$taskName" /TR "\"powershell.exe\" -ExecutionPolicy Bypass -File `"$scriptPath`"" /SC DAILY /ST 04:00 /RL HIGHEST /F
    }

    "clean" {
        Write-Host "[CLEAN] Removing audit output files..." -ForegroundColor Yellow
        Remove-Item "$base\..\outputs\*.csv", "$base\..\outputs\*.md", "$base\..\outputs\*.html", "$base\..\logs\*.txt" -Force -ErrorAction SilentlyContinue
    }

    default {
        Write-Warning "[WARN] Unknown target: $target"
    }
}