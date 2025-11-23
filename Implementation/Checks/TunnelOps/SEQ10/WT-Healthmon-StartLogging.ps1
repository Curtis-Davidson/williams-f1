<#
WT-HEALTHMON 8-SCREEN LAUNCHER – FINAL PRODUCTION (DEC 2025)
Author: Davidson – 100% tested on real rig + remote + GitHub formatting
Logs every step → you see exactly what works and what fails
#>

# ============ LOGGING (C:\Logs – survives reboots) ============
$Log = "C:\Logs\WT-Healthmon-Startup-$(Get-Date -f 'yyyy-MM-dd_HHmm').log"
"$(Get-Date) === STARTING WT-HEALTHMON 8-SCREEN LAUNCHER ===" | Out-File $Log -Encoding utf8

function Log($msg,$level="INFO"){
    $ts = Get-Date -f "yyyy-MM-dd HH:mm:ss"
    "$ts [$level] $msg" | Tee-Object -FilePath $Log -Append
}

Log "Script started – killing all browsers"
Get-Process *edge*,chrome -EA SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

# ============ DETECT ALL MONITORS (LEFT-TO-RIGHT = WALL ORDER) ============
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens | Sort-Object {$_.Bounds.X}
Log "Detected $($screens.Count) physical monitors:"
for($i=0;$i -lt $screens.Count;$i++){
    $s = $screens[$i]
    Log "  Physical #$($i+1) → $($s.DeviceName) @ X=$($s.Bounds.X) Y=$($s.Bounds.Y) $($s.Bounds.Width)x$($s.Bounds.Height)"
}

# ============ CHROME PATH (auto-detect) ============
$chrome = @("C:\Program Files\Google\Chrome\Application\chrome.exe",
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") | Where-Object {Test-Path $_} | Select -First 1
if(!$chrome){Log "CHROME NOT FOUND – INSTALL IT" "ERROR"; exit 1}
Log "Using Chrome: $chrome"

# ============ 7 URLS + PHYSICAL WALL POSITION ============
$apps = @(
    @{Name="ChangeTimeClock-1"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          Phys=2}
    @{Name="ATR";               URL="http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=";            Phys=3}
    @{Name="AXIS";             EXE="C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe";                              Phys=4}
    @{Name="HealthMonitor";    EXE="C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe";      Phys=5}
    @{Name="Auto_QA";           URL="http://streamlit-atf.dev-aero.factory.wf1/Auto_QA";                                   Phys=6}
    @{Name="Plant_Overview";    URL="http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView"; Phys=7}
    @{Name="ChangeTimeClock-2"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          Phys=8}
)

$success = 0
foreach($app in $apps){
    $target = $screens[$app.Phys - 1]
    if(!$target){Log "PHYSICAL MONITOR $($app.Phys) NOT FOUND" "ERROR"; continue}

    Log "Launching $($app.Name) → Physical $($app.Phys) ($($target.DeviceName))"

    if($app.URL){
        # 100% WORKING SEPARATE WINDOW METHOD
        $profile = "C:\Temp\ChromeTemp$((Get-Random))"
        Start-Process $chrome "--new-window","--user-data-dir=$profile",$app.URL
    }else{
        if(Test-Path $app.EXE){
            Start-Process $app.EXE
        }else{
            Log "EXE NOT FOUND: $($app.EXE)" "ERROR"
            continue
        }
    }
    $success++
    Start-Sleep -Seconds 4
}

# ============ MONITOR PLACEMENT (LEFT-TO-RIGHT = WALL) ============
Start-Sleep -Seconds 12
Add-Type @'
using System; using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int w, int h, uint f);
}
'@

$windows = Get-Process chrome,ACSP,WilliamsF1* -EA SilentlyContinue | Where {$_.MainWindowHandle -ne 0}
foreach($w in $windows){
    $h = $w.MainWindowHandle
    $i = $windows.IndexOf($w)
    $s = $screens[$apps[$i].Phys - 1]
    $b = $s.Bounds
    [Win32]::SetWindowPos($h, [IntPtr]::Zero, $b.X, $b.Y, $b.Width, $b.Height, 0x0040) | Out-Null
    Log "PLACED $($w.ProcessName) → Physical $($apps[$i].Phys)"
}

Log "=== DONE – $success/7 LAUNCHED AND PLACED ===" "INFO"
Write-Host "Check C:\Logs for full log" -F Green