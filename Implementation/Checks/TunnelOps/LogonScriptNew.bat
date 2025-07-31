@echo off
REM ============================================================================
REM TunnelOps Logon Script - Enhanced
REM Maps drives & applies settings based on detected IP range
REM ============================================================================

REM Delete all existing mappings
net use * /delete /y > nul

REM Stop unnecessary service
net stop sharedaccess > nul 2>&1

REM Create IP details file
ipconfig > "%USERPROFILE%\ipdetails.txt"

REM Optional: log actions
set LOGFILE=%USERPROFILE%\TunnelOps.log
echo [%DATE% %TIME%] Starting TunnelOps logon > "%LOGFILE%"

REM Detect network and branch accordingly
call :DetectNetwork
goto %TARGET%

:DetectNetwork
echo Detecting network... >> "%LOGFILE%"

for %%I in (
    "1.0."      "Factory"
    "1.5."      "Factory"
    "10.100."   "Factory"
    "172.16.13" "Factory"
    "172.16.21" "Factory"
    "172.16.10" "Factory"
    "172.16.146""Factory"
    "172.16.45" "Factory"
    "172.29"    "Factory"
    "172.17.28" "Factory"
    "172.17.29" "Factory"
    "172.17.30" "Factory"
    "172.17.31" "Factory"
    "172.17.32" "Factory"
    "172.17.33" "Factory"
    "192.168.10""RaceTeam"
    "192.168.11""TestTeam"
    "172.16.110""TestTeam"
) do (
    set "PATTERN=%%~I"
    set "LABEL=%%~J"
    findstr "%PATTERN%" "%USERPROFILE%\ipdetails.txt" > nul
    if not errorlevel 1 (
        set TARGET=%LABEL%
        echo Matched IP pattern [%PATTERN%], jumping to [%LABEL%] >> "%LOGFILE%"
        exit /b
    )
)

REM No match found
echo No known IP range detected, defaulting to Factory >> "%LOGFILE%"
set TARGET=Factory
exit /b

:Factory
echo.
echo Mapping Factory Drives...
echo.

net use j: \\factory.wf1\wf1\cncprogs
net use l: \\factory.wf1\wf1\apps_win\licom
net use P: \\factory.wf1\DFS2
net use r: \\factory.wf1\wf1\rigdata
net use t: \\factory.wf1\wf1\Department2
net use v: \\factory.wf1\wf1\Department1
net use w: \\factory.wf1\wf1\apps_win\ipc

if exist \\factory.wf1\wf1\user2\%USERNAME% (
    net use u: \\factory.wf1\wf1\user2\%USERNAME%
)

REM Optional X/Y mappings
call :MapXY

REM Optional configs
echo Configuring Windows Firewall Security...
"\\factdc1\NETLOGON\Windows Firewall\ERunAs.exe" "\\factory.wf1\NETLOGON\Windows Firewall\Windows Firewall.eras"

xcopy %LOGONSERVER%\netlogon\hosts %SystemRoot%\System32\drivers\etc /y
if not exist C:\WF1Templates mkdir C:\WF1Templates
xcopy /D /S \\factdc1\netlogon\WF1Templates C:\WF1Templates /y

goto End

:RaceTeam
echo.
echo Mapping Race Team Drives...
echo.

ping -n 1 192.168.10.251 > nul
if errorlevel 1 goto RTDC2
net use p: \\192.168.10.251\Data
goto End

:RTDC2
ping -n 1 192.168.10.252 > nul
if errorlevel 1 goto Arni
net use p: \\192.168.10.252\Data
goto End

:Arni
echo No connection to Race Team servers. Please contact IT.
pause
goto End

:TestTeam
echo.
echo Mapping Test Team Drives...
echo.

ping -n 1 172.16.110.101 > nul
if errorlevel 1 goto TTDC2
net use p: \\172.16.110.101\Data
goto End

:TTDC2
ping -n 1 172.16.110.102 > nul
if errorlevel 1 goto Birdy
net use p: \\172.16.110.102\Data
goto End

:Birdy
echo No connection to Test Team servers. Please contact IT.
pause
goto End

:MapXY
echo Checking for X: and Y: drives...

set X_MAP_FACT=\\factory.wf1\wf1\user_cae_files1
set X_MAP_AERO=\\factory.wf1\wf1\user_cae_files2
set Y_MAP=\\factory.wf1\wf1\pdmfiles1\cae_common

if not exist X:\ (
    if exist %X_MAP_FACT%\%USERNAME% (
        net use X: %X_MAP_FACT%
    ) else if exist %X_MAP_AERO%\%USERNAME% (
        net use X: %X_MAP_AERO%
    )
)

if not exist Y:\ (
    if exist %Y_MAP% (
        net use Y: %Y_MAP%
    )
)

goto :eof

:End
echo Cleaning up...
del "%USERPROFILE%\ipdetails.txt" > nul 2>&1
echo Finished at [%DATE% %TIME%] >> "%LOGFILE%"
exit
