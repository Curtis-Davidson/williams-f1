# ===========================================================
# Inject MetaData JSON Generator – Forensic Export Tagging
# File     : /modules/inject-meta.ps1
# Version  : 2025.7.4
# Author   : Paul R Davidson & Urbantek
# Purpose  : Auto-generate .meta.json for CAB, GitHub & Audit trace
# ===========================================================

param (
    [Parameter(Mandatory)][string]$ExportDir,
    [Parameter(Mandatory)][string]$Username
)

function Get-GitTag {
    try {
        $tag = git describe --tags --always
        return $tag
    } catch {
        return "v2025.7.4-untagged"
    }
}

function Get-CurrentCABReference {
    return "CAB-P135901"
}

# === Step 1: Build Metadata Object ===
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
$meta = [PSCustomObject]@{
    username          = $Username
    exportTimestamp   = $timestamp
    gitVersion        = Get-GitTag
    cabReference      = Get-CurrentCABReference
    author            = "Curtis-Davidson"
    project           = "WilliamsF1 Forensic AD Discovery"
    repository        = "https://github.com/UrbantekDev/CloudHealthLink"
    type              = "forensic-ad-audit"
    format            = "Rule6-Compliant"
}

# === Step 2: Write .meta.json to export directory ===
$metaPath = Join-Path $ExportDir ".meta.json"
$meta | ConvertTo-Json -Depth 4 | Set-Content -Path $metaPath -Encoding UTF8

Write-Host " Metadata injected at: $metaPath"