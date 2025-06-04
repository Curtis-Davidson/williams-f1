# ====================================================================
# Canonical Makefile-Style Script Runner for Williams F1
# File: /scripts/make.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.9.2
# ====================================================================

param (
    [ValidateSet("workstation", "shareduser", "group", "all", "export-md", "push", "verify", "verify-env")]
    [string]$target = "all"
)

$base = $PSScriptRoot
$ts   = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
Write-Host "`n[MAKE] Running target: $target @ $ts" -ForegroundColor Cyan

switch ($target) {

    "workstation" {
        & "$base\williamsf1-workstation-audit.ps1"
    }

    "shareduser" {
        & "$base\williamsf1-ad-audit.ps1"
    }

    "group" {
        & "$base\GroupDeepAudit.ps1"
    }

    "all" {
        & "$base\williamsf1-workstation-audit.ps1"
        & "$base\williamsf1-ad-audit.ps1"
        & "$base\GroupDeepAudit.ps1"
    }

    "export-md" {
        Get-ChildItem "$base\..\exports" -Recurse -Filter *.md |
                Where-Object { $_.Name -like 'report_*.md' } |
                ForEach-Object {
                    Write-Host "Exporting: $($_.FullName)" -ForegroundColor Green
                }
    }

    "verify" {
        $diffs = Get-ChildItem "$base\..\exports" -Recurse -Filter diff_summary.md
        if ($diffs.Count -gt 0) {
            Write-Host " Found $($diffs.Count) snapshot diff(s):"
            $diffs | ForEach-Object { Write-Host "• $($_.FullName)" -ForegroundColor Yellow }
        } else {
            Write-Host " No diff snapshots found." -ForegroundColor Red
        }
    }

    "verify-env" {
        & "$base\Test-EnvironmentReadiness.ps1"
    }

    "push" {
        Push-Location "$base\.."
        git add .; git commit -m " Automated snapshot + diff export @ $ts"; git tag -a "snapshot-$(Get-Date -Format yyyyMMdd-HHmm)" -m "Auto-tag"; git push; git push --tags
        Pop-Location
    }

    default {
        Write-Host " Unknown target: $target" -ForegroundColor Red
        exit 1
    }
}