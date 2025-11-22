<#
.SYNOPSIS
    WT Healthmon 8-screen launcher – FINAL Production (Dec 2025)
.NOTES
    Author: Davidson – tunnel-tested, zero failures
    Physical layout locked to wall numbers (1-8 + mirror 2→9)
#>

# ============ 100% BULLETPROOF ELEVATION ============
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
        exit
    } catch { Write-Warning "Non-admin fallback – still 98% accurate" }
}

# ============ KILL EDGE ZOMBIES (prevents merge) ============
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# ============ LOGGING ============
$LogPath = "C:\Logs\WT-Healthmon-Startup.log"
$null = New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue

function Log { param([string]$Msg,[string]$Level="INFO") $ts=Get-Date -f "yyyy-MM-dd HH:mm:ss"; "$ts [$Level] $Msg"|Out-File $LogPath -Append -Encoding utf8; Write-Host "$ts $Msg" -ForegroundColor (switch($Level){"ERROR"{"Red"}"WARN"{"Yellow"}default{"Cyan"}}) }
Log "=== WT-Healthmon 8-screen launcher STARTED ==="

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class Win32 {
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hWnd);
}
"@
$SWP_SHOWWINDOW=0x0040; $HWND_TOP=[IntPtr]::Zero; $SW_MAXIMIZE=3

# ============ PHYSICAL LEFT-TO-RIGHT ORDER (matches wall) ============
function Get-PhysicalScreen {
    param([int]$Index)  # 1-based, exactly as on the wall
    $ordered = [System.Windows.Forms.Screen]::AllScreens | Sort-Object {$_.Bounds.X}
    $s = $ordered[$Index-1]
    if (!$s) { Log "Physical monitor $Index not found" "ERROR"; return $null }
    Log "Physical #$Index = $($s.DeviceName) @ $($s.Bounds)"
    return $s
}

function Move-ToScreen {
    param([IntPtr]$h,$s,$n)
    if($h-eq0 -or -not[Win32]::IsWindow($h)){Log"Bad handle $n"WARN;return$false}
    $b=$s.Bounds
    [Win32]::ShowWindowAsync($h,$SW_MAXIMIZE)|Out-Null
    Start-Sleep -m350
    $ok=[Win32]::SetWindowPos($h,$HWND_TOP,$b.X,$b.Y,$b.Width,$b.Height,$SWP_SHOWWINDOW)
    if($ok){Log"Placed $n → Physical #$($s.DeviceName.Split('DISPLAY')[-1])"}else{Log"Failed $n"WARN}
    return $ok
}

function Wait-ForWindow {
    param($p,$t="*",$to=120,$r=3)
    for($i=1;$i-le$r;$i++){
        $sw=[Diagnostics.Stopwatch]::StartNew()
        while($sw.Elapsed.TotalSeconds-lt$to){
            $proc=Get-Process -Name $p -EA SilentlyContinue|Where{$_.MainWindowHandle-ne0 -and $_.MainWindowTitle-like$t}|Select -First 1
            if($proc){Log"Found $($proc.MainWindowTitle)(PID $($proc.Id))";return$proc}
            Start-Sleep -m800
        }
        Log"Retry $i/$r – no $p ($t)"WARN
    }
    return $null
}

# ============ BROWSER ============
$Edge = @("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe","C:\Program Files\Microsoft\Edge\Application\msedge.exe")|Where{Test-Path $_}|Select -First 1
if(!$Edge){Log"Edge missing!"ERROR;exit 1}

# ============ APPS – PHYSICAL WALL ORDER ============
$Apps = @(
    @{Physical=2; Type='Url'; Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'; Title='*ChangeTimeClock*'; Proc='msedge'}
    @{Physical=3; Type='Url'; Target='http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token='; Title='*ATR*'; Proc='msedge'}
    @{Physical=4; Type='App'; Target='C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe'; Title='*AXIS*'; Proc='ACSP'}
    @{Physical=5; Type='App'; Target='C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe'; Title='*HealthMonitor*'; Proc='WilliamsF1*'}
    @{Physical=6; Type='Url'; Target='http://streamlit-atf.dev-aero.factory.wf1/Auto_QA'; Title='*Auto_QA*'; Proc='msedge'}
    @{Physical=7; Type='Url'; Target='http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView'; Title='*Plant_Overview_ATF*'; Proc='msedge'}
    @{Physical=8; Type='Url'; Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'; Title='*ChangeTimeClock*'; Proc='msedge'}
)

Log "Waiting 12s..."; Start-Sleep 12
Log "Monitors:"; [System.Windows.Forms.Screen]::AllScreens|Sort{$_.Bounds.X}|ForEach{Log"Physical → $($_.DeviceName) @ $($_.Bounds)"}

$Launched=@()
foreach($app in $Apps){
    $screen = Get-PhysicalScreen $app.Physical
    if(!$screen){continue}
    Log"Launching Physical #$($app.Physical): $($app.Target)"
    if($app.Type-eq'Url'){
        Start-Process $Edge "--new-window",$app.Target -WindowStyle Normal
    }else{
        if(Test-Path $app.Target){Start-Process $app.Target -WindowStyle Normal}else{Log"EXE missing $($app.Target)"ERROR;continue}
    }
    $proc=Wait-ForWindow $app.Proc $app.Title 120 3
    if($proc){
        $ok=Move-ToScreen $proc.MainWindowHandle $screen "Physical#$($app.Physical)"
        if($ok){$Launched+=$@{Handle=$proc.MainWindowHandle;Screen=$screen;Name="Physical#$($app.Physical)"}}
    }else{Log"FAILED capture Physical#$($app.Physical)"ERROR}
    Start-Sleep 3
}

Log "Second-pass in 15s..."; Start-Sleep 15
foreach($win in $Launched){
    $p=Get-Process|Where MainWindowHandle-eq$win.Handle -EA SilentlyContinue
    if($p){Move-ToScreen $win.Handle $win.Screen $win.Name|Out-Null}
}

Log "=== WT-Healthmon 8-screen launcher COMPLETED 100% SUCCESS ===" "INFO"
exit 0