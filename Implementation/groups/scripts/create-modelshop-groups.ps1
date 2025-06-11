# =====================================================================
# Purpose: Creates all Modelshop security groups as per CAB Rule 6
# File: scripts/ad/create-groups/create-modelshop-groups.ps1
# Author: Paul R Davidson
# Version: 2025.6.11
# =====================================================================

# Logging setup
$logPath = "logs/script-log-$(Get-Date -Format 'yyyyMMdd').txt"
Start-Transcript -Path $logPath -Append

# Create group function
Function Create-Group {
    param (
        [string]$Name,
        [string]$Description
    )

    Write-Host "Creating: $Name ..."
    New-ADGroup -Name $Name `
                -SamAccountName $Name `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName $Name `
                -Description $Description `
                -Path "OU=Modelshop,OU=WF1-Resources,DC=factory,DC=wf1"
}

# === Group definitions ===
Create-Group -Name "grp-modelshopRW" -Description "Modelshop Read/Write Mailbox Access"
Create-Group -Name "grp-modelshopRO" -Description "Modelshop Read-Only Mailbox Access"
Create-Group -Name "grp-modelshopLAC" -Description "Modelshop Local Admin Access to Devices"
Create-Group -Name "grp-modelshopRDC" -Description "Modelshop Remote Desktop Access"

# Stop logging
Stop-Transcript
