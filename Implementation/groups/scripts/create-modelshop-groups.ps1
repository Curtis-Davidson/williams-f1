# =====================================================================
# Script:     create-modelshop-groups.ps1
# Purpose:    Creates all Modelshop AD groups (CAB / Rule 6 compliance)
# Author:     Paul R Davidson
# Contact:    paul@urbantek.com
# Version:    2025.6.11
# Location:   C:\Scripts\create-modelshop-groups.ps1
# =====================================================================

# === Logging Setup ===
$logDir = "C:\Logs"
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}
$logPath = "$logDir\script-log-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $logPath -Append

# === Function: Create Group (Safe/Idempotent) ===
function Create-Group {
    param (
        [string]$Name,
        [string]$Description
    )

    Write-Host "🛠 Creating group: $Name ..." -ForegroundColor Cyan

    # Check if group already exists
    if (Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue) {
        Write-Warning "⚠ Group '$Name' already exists. Skipping..."
        return
    }

    # Create new AD group
    New-ADGroup -Name $Name `
                -SamAccountName $Name `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName $Name `
                -Description $Description `
                -Path "OU=Modelshop,OU=WF1-Resources,DC=factory,DC=wf1"

    Write-Host "Group created: $Name" -ForegroundColor Green
}

# === Group Definitions ===
Create-Group -Name "grp-modelshopRW" -Description "Modelshop Read/Write Mailbox Access"
Create-Group -Name "grp-modelshopRO" -Description "Modelshop Read-Only Mailbox Access"
Create-Group -Name "grp-modelshopLAC" -Description "Modelshop Local Admin Access to Devices"
Create-Group -Name "grp-modelshopRDC" -Description "Modelshop Remote Desktop Access"

# === End Logging ===
Stop-Transcript
Write-Host "Log saved to: $logPath" -ForegroundColor Yellow
