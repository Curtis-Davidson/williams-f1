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
$UserProfile    = "C:\Users\modelshop"
$BackupRoot     = "D:\Backups\Modelshop"
$TimeStamp      = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupTarget   = Join-Path $BackupRoot $TimeStamp
$LogFile        = Join-Path $BackupTarget "robocopy.log"
$RetentionCount = 5   # Keep last 5 backups

# ===[ 2. Create Target Directory ]===
if (!(Test-Path $BackupTarget)) {
    New-Item -ItemType Directory -Path $BackupTarget -Force | Out-Null
}

# ===[ 3. Start Robocopy Backup ]===
Write-Host "`n[+] Backing up $UserProfile to $BackupTarget`n"

robocopy $UserProfile $BackupTarget /MIR /COPYALL /XJ /R:2 /W:5 /LOG:$LogFile

if ($LASTEXITCODE -le 7) {
    Write-Host "[✓] Backup completed successfully with exit code $LASTEXITCODE"
} else {
    Write-Warning "[!] Backup failed or partially completed. Exit code: $LASTEXITCODE"
}

# ===[ 4. Retention Logic (optional) ]===
$AllBackups = Get-ChildItem -Path $BackupRoot -Directory | Sort-Object Name -Descending
if ($AllBackups.Count -gt $RetentionCount) {
    $ToDelete = $AllBackups | Select-Object -Skip $RetentionCount
    foreach ($dir in $ToDelete) {
        Write-Host "[−] Removing old backup: $($dir.Name)"
        Remove-Item -Path $dir.FullName -Recurse -Force
    }
}

# ===[ 5. Optional: Export Summary Report ]===
$SummaryPath = Join-Path $BackupTarget "summary.txt"
@"
Modelshop Profile Backup Summary
--------------------------------
Date:       $(Get-Date)
Source:     $UserProfile
Target:     $BackupTarget
Exit Code:  $LASTEXITCODE
Log File:   $LogFile
"@ | Out-File -Encoding UTF8 $SummaryPath

Write-Host "`n[✓] Backup script completed.`n"
