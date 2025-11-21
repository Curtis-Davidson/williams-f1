<#
.SYNOPSIS
    WT Healthmon 8-screen launcher + Permanent Watchdog v2.1 (21 Nov 2025)
    - Pixel-perfect full-screen on all 8 monitors
    - Auto-restart HealthMonitor.exe if it ever crashes
    - Second-pass fixes + logging
#>

# ==============================
# 0. Config & Logging
# ==============================
$LogPath = "C:\Logs\WT-Healthmon-Startup.log"
$null = New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue

function Log ($Msg, $Level="INFO") {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Msg" | Out-File -FilePath $LogPath -Append -Encoding utf8
}

Log "=== WT-Healthmon Watchdog v2.1 started ==="

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Win32 {
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hWnd);
}
"@
$SWP_SHOWWINDOW = 0x0040
$HWND_TOP = [IntPtr]::Zero
$SW_MAXIMIZE = 3

# ==============================
# 1. Helpers
# ==============================
function Get-ScreenByDisplayNumber ([int]$n) {
    $t = "\\.\DISPLAY$n"
    $s = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.DeviceName -eq $t }
    if (-not $s) { Log "DISPLAY$n not found!" "ERROR" }
    return $s
}

function Move-WindowToScreen ([IntPtr]$Handle, $Screen, $Name) {
    if ($Handle -eq [IntPtr]::Zero -or -not [Win32]::IsWindow($Handle)) { return $false }
    $b = $Screen.Bounds
    [Win32]::ShowWindowAsync($Handle, $SW_MAXIMIZE) | Out-Null
    Start-Sleep -Milliseconds 250
    [Win32]::SetWindowPos($Handle, $HWND_TOP, $b.X, $b.Y, $b.Width, $b.Height, $SWP_SHOWWINDOW) | Out-Null
    Log "$Name → full-screen on $($Screen.DeviceName)"
    return $true
}

function Wait-ForWindow ($ProcessName, $TitleMatch, $TimeoutSec=70, $Retries=3) {
    for ($r = 1; $r -le $Retries; $r++) {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
            $p = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object {
                $_.MainWindowHandle -ne [IntPtr]::Zero -and $_.MainWindowTitle -like $TitleMatch
            }
            if ($p) { return $p }
            Start-Sleep -Milliseconds 800
        }
        Log "Retry $r/$Retries – no window for $ProcessName ($TitleMatch)" "WARN"
    }
    return $null
}

# ==============================
# 2. App Configuration
# ==============================
$BrowserExe = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $BrowserExe) { Log "Edge not found!" "ERROR"; exit 1 }

$Items = @(
    @{Display=2; Type='Url'; Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock';                  Title='*ChangeTimeClock*'; Proc='msedge'}
    @{Display=3; Type='Url'; Target='http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=';                        Title='*ATR*';           Proc='msedge'}
    @{Display=4; Type='App'; Target='C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe';                                      Title='*AXIS*';          Proc='ACSP'}
    @{Display=5; Type='App'; Target='C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe';                Title='*HealthMonitor*'; Proc='WilliamsF1*'}
    @{Display=6; Type='Url'; Target='http://streamlit-atf.dev-aero.factory.wf1/Auto_QA';                                              Title='*Auto_QA*';       Proc='msedge'}
    @{Display=7; Type='Url'; Target='http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView'; Title='*Plant_Overview_ATF*'; Proc='msedge'}
    @{Display=8; Type='Url'; Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock';                  Title='*ChangeTimeClock*'; Proc='msedge'}
)

# ==============================
# 3. Initial Launch
# ==============================
Log "Waiting 12 seconds for system..."
Start-Sleep -Seconds 12

Log "Detected monitors:"
[System.Windows.Forms.Screen]::AllScreens | Sort DeviceName | ForEach-Object { Log "$($_.DeviceName) -> $($_.Bounds)" }

$LaunchedWindows = @()

foreach ($item in $Items) {
    $screen = Get-ScreenByDisplayNumber $item.Display
    if (-not $screen) { continue }

    Log "Launching DISPLAY$($item.Display): $($item.Target)"

    if ($item.Type -eq 'Url') {
        Start-Process $BrowserExe "--new-window" $item.Target -WindowStyle Normal
    } else {
        if (Test-Path $item.Target) {
            Start-Process $item.Target -WindowStyle Normal
        } else {
            Log "EXE missing: $($item.Target)" "ERROR"
            continue
        }
    }

    $proc = Wait-ForWindow $item.Proc $item.Title
    if ($proc) {
        Move-WindowToScreen $proc.MainWindowHandle $screen "$($item.Proc) (Display $($item.Display))"
        $LaunchedWindows += @{Handle=$proc.MainWindowHandle; Screen=$screen; Name=$item.Proc}
    } else {
        Log "FAILED to capture window for DISPLAY$($item.Display)" "ERROR"
    }
    Start-Sleep -Seconds 3
}

# Second-pass fix (Edge & AXIS love to move themselves)
Log "Second-pass correction in 15s..."
Start-Sleep -Seconds 15
foreach ($win in $LaunchedWindows) {
    if ([Win32]::IsWindow($win.Handle)) {
        Move-WindowToScreen $win.Handle $win.Screen $win.Name
    }
}

Log "Initial launch complete – entering permanent watchdog mode"

# ==============================
# 4. Permanent Watchdog (HealthMonitor auto-restart)
# ==============================
$HealthMonitorPath = "C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe"
$Display5 = Get-ScreenByDisplayNumber 5

while ($true) {
    $hm = Get-Process -Name "WilliamsF1.WindTunnel.HealthMonitor.Host" -ErrorAction SilentlyContinue

    if (-not $hm) {
        Log "HealthMonitor.exe NOT RUNNING → restarting immediately" "WARN"
        try {
            $proc = Start-Process $HealthMonitorPath -PassThru -WindowStyle Normal
            Log "HealthMonitor.exe restarted (PID $($proc.Id))"

            # Wait for window and slam to Display 5
            $sw = [Diagnostics.Stopwatch]::StartNew()
            while ($sw.Elapsed.TotalSeconds -lt 60) {
                $p = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
                if ($p -and $p.MainWindowHandle -ne [IntPtr]::Zero) {
                    Move-WindowToScreen $p.MainWindowHandle $Display5 "HealthMonitor.exe (auto-restart)"
                    break
                }
                Start-Sleep -Milliseconds 800
            }
        }
        catch { Log "Restart failed: $_" "ERROR" }
    }

    Start-Sleep -Seconds 4  # ~4 second recovery time, negligible CPU
}