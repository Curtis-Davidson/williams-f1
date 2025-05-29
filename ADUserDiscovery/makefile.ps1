# =============================================
# Williams F1 | ADUserDiscovery Makefile Runner
# File: Makefile.ps1
# Version: 2025.7.2
# Author: Curtis-Davidson & Urbantek
# Purpose: Standardised entry-point for Rule 6 tasks
# =============================================

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("run", "test", "clean", "logs", "export")]
    [string]$Task = "run",

    [string]$Username
)

# === Directory Map ===
$ScriptPath = "$PSScriptRoot/scripts/ADUserDiscovery.ps1"
$TestPath   = "$PSScriptRoot/tests/test-ad-discovery.ps1"
$LogPath    = "$PSScriptRoot/logs"
$ExportPath = "$PSScriptRoot/exports"

function Run-Audit {
    if (-not $Username) {
        Write-Error "Please provide a username: .\Makefile.ps1 -Task run -Username j.smith"
        exit 1
    }
    Write-Host "`n Running ADUserDiscovery for user: $Username" -ForegroundColor Cyan
    & $ScriptPath -Username $Username
}

function Run-Test {
    Write-Host "`n🔍 Running Tests..." -ForegroundColor Yellow
    & $TestPath
}

function Clean-Exports {
    Write-Host "`n🧹 Cleaning exports and logs..." -ForegroundColor Red
    Remove-Item "$ExportPath\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "$LogPath\*" -Force -Recurse -ErrorAction SilentlyContinue
}

function Show-Logs {
    Get-ChildItem -Path $LogPath -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | Format-Table Name, LastWriteTime
}

function Show-Exports {
    Get-ChildItem -Path $ExportPath -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | Format-Table Name, LastWriteTime
}

switch ($Task) {
    "run"    { Run-Audit }
    "test"   { Run-Test }
    "clean"  { Clean-Exports }
    "logs"   { Show-Logs }
    "export" { Show-Exports }
    default  {
        Write-Error "Unknown task: $Task"
        exit 1
    }
}