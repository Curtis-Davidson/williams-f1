<#
=====================================================================================
  backup-modelshop.ps1 — Enterprise-grade profile backup for shared 'modelshop' user
  Author: Paul R Davidson (UT)
  Purpose:
    - Backup full user profile (incl. AppData)
    - Preserve permissions/metadata
    - Generate timestamped folders
    - Maintain log per backup
    - Optional retention policy (keep last N)
=====================================================================================
#>

# ===[ 1. Configurable Variables ]===
$UserProfile    = "C:\Users\paul.davidson"
$BackupRoot     = "D:\Backup"
$TimeStamp      = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupTarget   = Join-Path $BackupRoot $TimeStamp
$LogFile        = Join-Path $BackupTarget "robocopy.log"
$SummaryPath    = Join-Path $BackupTarget "summary.txt"
$RetentionCount = 5

# ===[ 2. Create Target Directory ]===
if (!(Test-Path $BackupTarget)) {
    New-Item -ItemType Directory -Path $BackupTarget -Force | Out-Null
}

# ===[ 3. Start Robocopy Backup ]===
Write-Host "`n[+] Backing up $UserProfile to $BackupTarget`n"

robocopy $UserProfile $BackupTarget /MIR /COPYALL /XJ /R:2 /W:5 /LOG:$LogFile

# ===[ 4. Handle Exit Code ]===
if ($LASTEXITCODE -le 7) {
    Write-Host "[✓] Backup completed successfully with exit code $LASTEXITCODE"
} else {
    Write-Warning "[!] Backup failed or partially completed. Exit code: $LASTEXITCODE"
}

# ===[ 5. Retention Logic ]===
$AllBackups = Get-ChildItem -Path $BackupRoot -Directory | Sort-Object Name -Descending
if ($AllBackups.Count -gt $RetentionCount) {
    $ToDelete = $AllBackups | Select-Object -Skip $RetentionCount
    foreach ($dir in $ToDelete) {
        Write-Host "[-] Removing old backup: $($dir.Name)"
        Remove-Item -Path $dir.FullName -Recurse -Force
    }
}

# ===[ 6. Write Summary File ]===
$SummaryContent = @"
Modelshop Profile Backup Summary
--------------------------------
Date:       $(Get-Date)
Source:     $UserProfile
Target:     $BackupTarget
Exit Code:  $LASTEXITCODE
Log File:   $LogFile
"@

$SummaryContent | Out-File -Encoding UTF8 $SummaryPath

Write-Host "`n[✓] Backup script completed.`n"