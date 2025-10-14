# C:\Scripts\TunnelOps\01-backup-user-full.ps1
# Purpose: Near-complete BACKUP of a user profile. Keeps user hives (NTUSER.DAT, UsrClass.dat) for later surgical import if needed.
# Excludes only volatile caches by default (toggle with -IncludeCaches).
# Usage: .\01-backup-user-full.ps1 -SourceProfile 'C:\Users\TunnelOps' [-IncludeCaches] [-DryRun]

param(
    [Parameter(Mandatory=$true)][string]$SourceProfile,
    [switch]$IncludeCaches,
    [switch]$DryRun
)

$BackupRoot = 'C:\Backup\TunnelOps'
$Log        = 'C:\Temp\TunnelOps_backup_full.log'

# Ensure paths
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $Log) | Out-Null

# Base excludes (junctions handled by /XJ)
$xd_common = @(
    'AppData\Local\Temp',
    'AppData\Local\Packages',
    'AppData\LocalLow'
)
# Volatile caches (skip unless -IncludeCaches)
$xd_caches = @(
# Windows/IE/Edge caches
    'AppData\Local\Microsoft\Windows\INetCache',
    'AppData\Local\Microsoft\Windows\WebCache',
    'AppData\Local\Microsoft\Windows\Caches',
    'AppData\Local\Microsoft\Windows\Temporary Internet Files',

    # OneDrive/Teams (let them re-sign-in; safer)
    'AppData\Local\Microsoft\OneDrive',
    'AppData\Local\Microsoft\Teams',
    'AppData\Local\ConnectedDevicesPlatform',
    'AppData\Local\TileDataLayer',

    # Chromium caches
    'AppData\Local\Google\Chrome\User Data\*\Cache',
    'AppData\Local\Google\Chrome\User Data\*\Code Cache',
    'AppData\Local\Google\Chrome\User Data\*\GPUCache',
    'AppData\Local\Google\Chrome\User Data\*\Service Worker\CacheStorage',
    'AppData\Local\Microsoft\Edge\User Data\*\Cache',
    'AppData\Local\Microsoft\Edge\User Data\*\Code Cache',
    'AppData\Local\Microsoft\Edge\User Data\*\GPUCache',
    'AppData\Local\Microsoft\Edge\User Data\*\Service Worker\CacheStorage'
)

$xd = @()
$xd += $xd_common
if(-not $IncludeCaches){ $xd += $xd_caches }

# File excludes for BACKUP: none of the user hives are excluded (we WANT to capture them),
# but OS hives (not in profile) are listed here defensively in case of odd placements.
$xf = @('SAM','SECURITY','SYSTEM','SOFTWARE')

# Build robocopy args: /E (no mirror deletions), no ACL copy to avoid SID pollution in backup tree
$args = @(
    "`"$SourceProfile`"", "`"$BackupRoot`"",
    '/E',
    '/COPY:DAT',
    '/DCOPY:DAT',
    '/XJ',
    '/R:1','/W:1',
    '/MT:16',
    '/NFL','/NDL',
    "/LOG:$Log","/TEE"
)
foreach($d in $xd){ $args += @('/XD',"`"$($SourceProfile+'\'+$d)`"") }
foreach($f in $xf){ $args += @('/XF',"`"$f`"") }

if($DryRun){ $args += '/L' }
Write-Host "ROBOSIM BACKUP: robocopy $($args -join ' ')" -ForegroundColor Cyan
Start-Process -FilePath 'robocopy.exe' -ArgumentList $args -Wait -NoNewWindow

Write-Host "Backup complete. Review log: $Log"