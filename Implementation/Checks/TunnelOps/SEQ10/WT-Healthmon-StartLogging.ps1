# WT-HEALTHMON 8-SCREEN LAUNCHER – FINAL, BULLETPROOF, LOGGED (DEC 2025)

# KILL ALL BROWSERS
Get-Process *edge*,chrome -EA SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

# LOGGING
$Log = "C:\Logs\WT-Healthmon-$(Get-Date -f 'yyyyMMdd-HHmmss').log"
"$(Get-Date) === STARTING WT-HEALTHMON 8-SCREEN LAUNCHER ===" | Out-File $Log -Encoding utf8
function L {$m=$args[0];$l=$args[1]?"$l".ToUpper():"INFO";$t=Get-Date -f "yyyy-MM-dd HH:mm:ss";"$t [$l] $m"|Tee-Object -FilePath $Log -Append}

L "Logging started – $Log"

# DETECT MONITORS (LEFT-TO-RIGHT = WALL)
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens | Sort {$_.Bounds.X}
L "Found $($screens.Count) monitors:"
for($i=0;$i-lt$screens.Count;$i++){L "  Physical #$($i+1) → $($screens[$i].DeviceName) @ X=$($screens[$i].Bounds.X)"}

# CHROME PATH
$chrome = @("C:\Program Files\Google\Chrome\Application\chrome.exe",
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") | Where {Test-Path $_} | Select -First 1
if(!$chrome){L "CHROME NOT INSTALLED – ABORT" "ERROR";exit 1}
L "Chrome found: $chrome"

# 7 URLS + PHYSICAL WALL POSITION
$apps = @(
    @{Name="ChangeTimeClock-1"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          Phys=2}
    @{Name="ATR";               URL="http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=";            Phys=3}
    @{Name="AXIS";             EXE="C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe";                              Phys=4}
    @{Name="HealthMonitor";    EXE="C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe";      Phys=5}
    @{Name="Auto_QA";           URL="http://streamlit-atf.dev-aero.factory.wf1/Auto_QA";                                   Phys=6}
    @{Name="Plant_Overview";    URL="http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView"; Phys=7}
    @{Name="ChangeTimeClock-2"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          Phys=8}
)

# LAUNCH WITH FULL LOGGING
$success = 0
foreach($a in $apps){
    $scr = $screens[$a.Phys-1]
    if(!$scr){L "Physical $($a.Phys) missing" "ERROR";continue}
    L "Launching $($a.Name) → Physical $($a.Phys)"

    if($a.URL){
        $profile = "C:\Temp\Chrome$([guid]::NewGuid())"
        Start-Process $chrome "--new-window","--user-data-dir=$profile",$a.URL
        L "Chrome URL launched (temp profile $profile)"
    }else{
        if(Test-Path $a.EXE){
            Start-Process $a.EXE
            L "EXE launched"
        }else{
            L "EXE NOT FOUND: $($a.EXE)" "ERROR"
            continue
        }
    }
    $success++
    Start-Sleep -Seconds 5
}

# PLACEMENT
Start-Sleep -Seconds 15
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class W {
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int w, int h, uint f);
}
'@

$windows = Get-Process chrome,ACSP,WilliamsF1* -EA SilentlyContinue | Where {$_.MainWindowHandle -ne 0}
for($i=0;$i-lt$windows.Count;$i++){
    $h = $windows[$i].MainWindowHandle
    $s = $screens[$apps[$i].Phys - 1]
    $b = $s.Bounds
    [W]::SetWindowPos($h,0,$b.X,$b.Y,$b.Width,$b.Height,0x0040)|Out-Null
    L "PLACED $($apps[$i].Name) → Physical $($apps[$i].Phys)"
}

L "=== DONE – $success/7 SUCCESSFUL === Check log: $Log" "INFO"
explorer "C:\Logs"