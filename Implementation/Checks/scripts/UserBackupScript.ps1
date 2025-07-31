<#
=====================================================================================
  UserBackupScript.ps1 — Robust ASCII-safe profile backup
  Author: Paul R Davidson (Urbantek)
  Purpose:
    - Backup full user profile
    - Preserve permissions and metadata
    - Timestamped folders and backup logs
    - Auto-retention of last N backups
=====================================================================================
#>

# ===[ 1. Configurable Variables ]===
$UserProfile    = "C:\Users\paul.davidson"
$BackupRoot     = "C:\Backup"
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
Write-Host ""
Write-Host "[INFO] Backing up $UserProfile to $BackupTarget"
Write-Host ""

robocopy $UserProfile $BackupTarget /MIR /COPYALL /XJ /R:2 /W:5 /LOG:$LogFile

# ===[ 4. Handle Exit Code ]===
if ($LASTEXITCODE -le 7) {
    Write-Host "[INFO] Backup completed successfully. Exit code: $LASTEXITCODE"
} else {
    Write-Warning "[WARNING] Backup failed or partially completed. Exit code: $LASTEXITCODE"
}

# ===[ 5. Retention Logic ]===
$AllBackups = Get-ChildItem -Path $BackupRoot -Directory | Sort-Object Name -Descending
if ($AllBackups.Count -gt $RetentionCount) {
    $ToDelete = $AllBackups | Select-Object -Skip $RetentionCount
    foreach ($dir in $ToDelete) {
        Write-Host "[INFO] Removing old backup: $($dir.Name)"
        Remove-Item -Path $dir.FullName -Recurse -Force
    }
}

# ===[ 6. Write Summary File ]===
$SummaryContent = @"
User Profile Backup Summary
---------------------------
Date:       $(Get-Date)
Source:     $UserProfile
Target:     $BackupTarget
Exit Code:  $LASTEXITCODE
Log File:   $LogFile
"@

$SummaryContent | Out-File -Encoding ASCII $SummaryPath

Write-Host ""
Write-Host "[INFO] Backup script completed."
Write-Host ""