# Purpose: Free MSI/WMI, reset Windows Installer, clear stuck installer/update state, and repair WMI if needed
# Expected: msiexec no longer “stuck”, app installs/uninstalls run, Intune/ConfigMgr re-enabled at the end

# 0) Quick helpers (no files created)
$ErrorActionPreference = 'SilentlyContinue'

# 1) Stop the usual lockers (ConfigMgr, Intune, Office C2R) and keep them down during repair
sc.exe stop CcmExec
sc.exe config CcmExec start= disabled
sc.exe stop IntuneManagementExtension
sc.exe config IntuneManagementExtension start= disabled
sc.exe stop ClickToRunSvc

# 2) Kill any MSI processes (child and service-hosted)
taskkill /f /t /im msiexec.exe
taskkill /f /im TiWorker.exe
taskkill /f /im RemediationAgent.exe
taskkill /f /im RemedationAgent.exe  # (typo variants sometimes seen)

# 3) Re-register Windows Installer (both 64 & 32-bit)
& "$env:WINDIR\System32\msiexec.exe" /unregister
& "$env:WINDIR\System32\msiexec.exe" /regserver
& "$env:WINDIR\SysWOW64\msiexec.exe" /unregister
& "$env:WINDIR\SysWOW64\msiexec.exe" /regserver

# 4) Clear any stuck Installer “InProgress” / rollback entries (won’t error if missing)
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Rollback'   -Recurse -Force -ErrorAction SilentlyContinue

# 5) Stop Windows Update bits to clear SoftwareDistribution cleanly
Stop-Service -Name wuauserv,bits -Force

# 6) Clear Windows Update download cache and system temp (PowerShell syntax; no /s /q)
Remove-Item -Path "$env:WINDIR\SoftwareDistribution\Download\*" -Recurse -Force
Remove-Item -Path "$env:WINDIR\Temp\*"                            -Recurse -Force

# 7) Bring WU services back
Start-Service -Name bits,wuauserv

# 8) If WMI is still complaining, salvage the repository (non-destructive)
#    If salvage errors, do a reset (last resort). Only one will run; both are safe to paste.
net stop winmgmt /y
winmgmt /salvagerepository
if ($LASTEXITCODE -ne 0) { winmgmt /resetrepository }
net start winmgmt

# 9) Re-enable and start the agents we disabled
sc.exe config CcmExec start= auto
sc.exe start  CcmExec
sc.exe config IntuneManagementExtension start= auto
sc.exe start  IntuneManagementExtension

# 10) Start Windows Installer service and verify status
sc.exe start msiserver
sc.exe query msiserver

# 11) Sanity check: list any remaining msiexec bound to the service host
tasklist /svc | Select-String "msiserver"