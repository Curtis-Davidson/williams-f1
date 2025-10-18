# VARS
$UserProfile = 'C:\Users\shr-tunops-wtm'
$ProfileListKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$TempLog = 'C:\Temp\WTM_profile_rebuild.log'
mkdir -Force C:\Temp | Out-Null

# A) Find the ProfileList SID key that points to this profile
$SidKey = Get-ChildItem $ProfileListKey | Where-Object {
    (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).ProfileImagePath -eq $UserProfile
}

# Safety backup of the SID key (if found)
if($SidKey){ reg export $SidKey.Name $TempLog.replace('.log','.reg') /y | Out-Null }

# B) Ensure the user is fully logged off (kill any stray processes)
Get-Process -IncludeUserName -ErrorAction SilentlyContinue |
        Where-Object { $_.UserName -match 'shr-tunops-wtm' } |
        Stop-Process -Force -ErrorAction SilentlyContinue

# C) Rename the broken profile folder
if(Test-Path $UserProfile){ Rename-Item $UserProfile ($UserProfile + '.bak') -ErrorAction SilentlyContinue }

# D) Delete the ProfileList SID entry so Windows will build a fresh profile on next logon
if($SidKey){ reg delete $SidKey.Name /f | Out-Null }

Write-Host "Profile key removed and folder renamed. Next logon will build a fresh profile." -ForegroundColor Yellow