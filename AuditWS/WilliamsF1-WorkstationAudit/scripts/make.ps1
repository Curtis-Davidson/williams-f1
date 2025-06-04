# ===============================================================
# Makefile-Style Runner for WilliamsF1 Audit Suite
# File: /scripts/make.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.6.4
# Status: Canonical, Rule 6 Compliant
# ===============================================================

param (
    [ValidateSet("workstation", "shareduser", "all", "diff", "schedule", "clean", "push", "export-md", "verify")]
    [string]$target = "all"
)

$base = $PSScriptRoot
$root = Resolve-Path "$base\.."
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

    "export-md" {
        Write-Host "[EXPORT] Regenerating Markdown summaries..." -ForegroundColor Cyan
        & "$base\export-markdown.ps1"
    }

    "verify" {
        Write-Host "[VERIFY] Checking latest diff + audit snapshots..." -ForegroundColor Cyan
        $jsons = Get-ChildItem "$root\exports" -Recurse -Filter *.json | Sort-Object LastWriteTime -Descending | Select-Object -First 2
        if ($jsons.Count -lt 2) {
            Write-Warning "[FAIL] Less than 2 audit snapshots found."
        } else {
            Write-Host "[OK] Found recent snapshots:" -ForegroundColor Green
            $jsons | ForEach-Object { Write-Host "  - $($_.FullName)" }
        }
    }

    "schedule" {
        Write-Host "[TASK] Creating Task Scheduler Job: Daily Audit @ 04:00" -ForegroundColor Cyan
        $taskName = "WilliamsF1 Workstation Audit"
        $scriptPath = "$base\williamsf1-workstation-audit.ps1"
        schtasks /Create /TN "$taskName" /TR "\"powershell.exe\" -ExecutionPolicy Bypass -File `"$scriptPath`"" /SC DAILY /ST 04:00 /RL HIGHEST /F
    }

    "clean" {
        Write-Host "[CLEAN] Removing audit output files..." -ForegroundColor Yellow
        Remove-Item "$root\outputs\*.csv", "$root\outputs\*.md", "$root\outputs\*.html", "$root\logs\*.txt" -Force -ErrorAction SilentlyContinue
    }

    "push" {
        Write-Host "[GIT] Committing + tagging snapshot..." -ForegroundColor Cyan
        Set-Location $root
        git add .
        $tag = "snapshot-" + (Get-Date -Format "yyyyMMdd-HHmmss")
        git commit -m "Audit snapshot commit: $tag"
        git tag -a $tag -m "Tagged snapshot: $tag"
        git push origin main --tags
    }

    default {
        Write-Warning "[WARN] Unknown target: $target"
    }
}