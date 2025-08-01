@echo off
net use * /delete /y > nul
net stop sharedaccess
rem regedit /s IPC_FlexLM_Change.reg
ipconfig > "%USERPRoFILE%\ipdetails.txt"
findstr "1.0." "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "1.5." "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "10.100." "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.16.13" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.16.21" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.16.10" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.16.146" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.16.45" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "192.168.10" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto RaceTeam
findstr "192.168.11" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto TestTeam
findstr "172.16.110" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto TestTeam
findstr "172.17.28" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.17.29" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.17.30" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.17.31" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.17.32" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory
findstr "172.17.33" "%USERPRoFILE%\ipdetails.txt" > nul
if not errorlevel 1 goto Factory

goto end

:Factory
echo.
echo Mapping Factory Drives
echo.
net use j: \\factory.wf1\wf1\cncprogs
net use l: \\factory.wf1\wf1\apps_win\licom
net use P: \\factory.wf1\DFS2
net use r: \\factory.wf1\wf1\rigdata
net use t: \\factory.wf1\wf1\Department2
net use v: \\factory.wf1\wf1\Department1
net use w: \\factory.wf1\wf1\apps_win\ipc
if exist \\factory.wf1\wf1\user2\%username% net use u: \\factory.wf1\wf1\user2\%username%
REM: The following maps the X and Y drives if the user
REM: has an appropriate directory.
set X_MAP_FACT=\\factory.wf1\wf1\user_cae_files1
set X_MAP_AERO=\\factory.wf1\wf1\user_cae_files2
set Y_MAP=\\factory.wf1\wf1\pdmfiles1\cae_common
echo Checking for X: drive...
if exist X:\ goto X_MAPPED
if exist %X_MAP_FACT%\%USERNAME% net use X: %X_MAP_FACT% & goto X_MAPPED
if exist %X_MAP_AERO%\%USERNAME% net use X: %X_MAP_AERO% & goto X_MAPPED
echo ...X drive mapping skipped. & goto SKIP_X_Y_MAPPING
: X_MAPPED
echo ...X drive mapped.
echo Checking for Y: drive...
if exist Y:\ goto Y_MAPPED
if exist %Y_MAP% net use Y: %Y_MAP% & goto Y_MAPPED
echo ...Y drive mapping skipped. & goto SKIP_X_Y_MAPPING
: Y_MAPPED
echo ...Y drive mapped.
: SKIP_X_Y_MAPPING

REM: echo "Configuring Proxy"

REM: regedit.exe /s \\factdc1\netlogon\Proxy-Grove.reg

REM echo "Scan & Remove Kiddo Virus"

REM "\\factdc1\NETLOGON\Worm Removal\ERunAs.exe" "\\factory.wf1\NETLOGON\Worm Removal\KK.ERAS"

echo "Setting Windows Firewall Security"

"\\factdc1\NETLOGON\Windows Firewall\ERunAs.exe" "\\factory.wf1\NETLOGON\Windows Firewall\Windows Firewall.eras"

xcopy %logonserver%\netlogon\hosts %systemroot%\system32\drivers\etc /y
if not exist c:\WF1Templates mkdir C:\WF1Templates
xcopy /D /S \\factdc1\netlogon\WF1Templates C:\WF1Templates /y
goto end

:RaceTeam
echo.
echo Mapping Race Team Drives
echo.
echo UR@Race
ping -n 1 192.168.10.251 > nul
if errorlevel 1 goto RTDC2
net use p: \\192.168.10.251\Data
xcopy %logonserver%\netlogon\hosts %systemroot%\system32\drivers\etc /y
pause
exit
:RTDC2
ping -n 1 192.168.10.252 > nul
if errorlevel 1 goto Arni
net use p: \\192.168.10.252\Data
xcopy %logonserver%\netlogon\hosts %systemroot%\system32\drivers\etc /y
exit
:Arni
rem echo ***********************************
rem echo **                               **
rem echo ** You do not have a connection  **
rem echo **   to the Race Team Servers.   **
rem echo **                               **
rem echo **        Tell Arni he           **
rem echo **     has a bit more on!!       **
rem echo **                               **
rem echo ***********************************
rem pause
goto end

:TestTeam
echo.
echo Mapping Test Team Drives
echo.
ping -n 1 172.16.110.101 > nul
if errorlevel 1 goto TTDC2
rem net use p: \\192.168.10.251\Data
rem the above line added for Bla73 only
net use p: \\172.16.110.101\Data
rem add for Bla73
goto end
:TTDC2
ping -n 1 172.16.110.102 > nul
if errorlevel 1 goto birdy
rem net use p: \\192.168.10.252\Data
rem the above ;ine addes for Bla73 only
net use p: \\172.16.110.102\Data
xcopy %logonserver%\netlogon\hosts %systemroot%\system32\drivers\etc /y
rem add for Bla73
goto end
:birdy
echo ***********************************
echo **                               **
echo ** You do not have a connection  **
echo **   to the Test Team Servers.   **
echo **                               **
echo **                   	      **
echo **        ******************     **
echo **                               **
echo ***********************************
pause
goto end

:end
rem xcopy /D %logonserver%\netlogon\hosts %systemroot%\system32\drivers\etc /y
del "C:\Documents and Settings\%username%\ipdetails.txt"
exit