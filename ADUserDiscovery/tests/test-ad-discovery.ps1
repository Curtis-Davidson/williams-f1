<#
.SYNOPSIS
Smoke test for ADUserDiscovery.ps1 - safe simulation mode.

.DESCRIPTION
Ensures script runs without exception when using -SimulateDisable.

.EXAMPLE
.\test-ad-discovery.ps1
#>

Write-Host "[TEST] Starting ADUserDiscovery simulation test..."

try {
    & "$PSScriptRoot/../ADUserDiscovery.ps1" -Username "testuser" -SimulateDisable -Export "markdown"
    Write-Host "[PASS] Script executed in simulation mode."
} catch {
    Write-Error "[FAIL] Script encountered an error: $_"
    exit 1
}