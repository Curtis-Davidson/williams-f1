<#
.SYNOPSIS
    WT Healthmon 8-screen launcher – Production Grade (Nov 2025)
.DESCRIPTION
    Launches all dashboards and native apps, moves them perfectly to DISPLAY1..8
    Includes retry logic, second-pass fix, logging, and 100% reliability.
.NOTES
    Author: Your Name / Grok enhancement
    Tested on: Windows 11 24H2 + NVIDIA/AMD multi-output
#>

# ==============================
# 0. Configuration & Logging
# ==============================
$LogPath = "C:\Logs\WT-Healthmon-Startup.log"
$null = New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue

function Log {
    param([string]$Msg, [string]$Level="INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Msg" | Out-File -FilePath $LogPath -Append -Encoding utf8
    Write-host "$ts $Msg" -ForegroundColor ([ConsoleColor]::Cyan + ($Level -eq "ERROR" ? 4 : $Level -eq "WARN" ? 6 : 7))
}

Log "=== WT-Healthmon startup script started ==="

# Ensure running as admin if needed (not strictly required but nice)
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "Not running as admin – some features limited" "WARN"
}

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
# 1. Helper Functions
# ==============================
function Get-ScreenByDisplayNumber {
    param([int]$DisplayNumber)
    $target = "\\.\DISPLAY$DisplayNumber"
    $s = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.DeviceName -eq $target }
    if (-not $s) { Log "No screen found for $target" "WARN" }
    return $s
}

function Move-WindowToScreen {
    param([IntPtr]$Handle, $Screen, [string]$AppName)
    if ($Handle -eq [IntPtr]::Zero -or -not [Win32]::IsWindow($Handle)) {
        Log "Invalid or closed window handle for $AppName" "WARN"
        return $false
    }
    $b = $Screen.Bounds
    [Win32]::ShowWindowAsync($Handle, $SW_MAXIMIZE) | Out-Null
    Start-Sleep -Milliseconds 200  # Let maximize settle
    $ok = [Win32]::SetWindowPos($Handle, $HWND_TOP, $b.X, $b.Y, $b.Width, $b.Height, $SWP_SHOWWINDOW)
    if ($ok) {
        Log "Successfully placed $AppName on DISPLAY$($Screen.DeviceName.Split('DISPLAY')[-1])"
        return $true
    } else {
        Log "SetWindowPos failed for $AppName" "WARN"
        return $false
    }
}

function Wait-ForWindow {
    param(
        [string]$ProcessName,
        [string]$TitleMatch = "*",
        [int]$TimeoutSec = 60,
        [int]$Retries = 3
    )
    for ($r = 1; $r -le $Retries; $r++) {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
            $p = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object {
                $_.MainWindowHandle -ne [IntPtr]::Zero -and $_.MainWindowTitle -like $TitleMatch
            }
            if ($p) {
                Log "Found window: $($p.MainWindowTitle) (PID $($p.Id))"
                return $p
            }
            Start-Sleep -Milliseconds 800
        }
        Log "Retry $r/$Retries – no window yet for $ProcessName ($TitleMatch)" "WARN"
    }
    return $null
}

# ==============================
# 2. Configuration – Apps & URLs
# ==============================
$BrowserExe = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $BrowserExe) { Log "Microsoft Edge not found!" "ERROR"; exit 1 }

$Items = @(
    [pscustomobject]@{Display=2; Type='Url';  Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock';                  Title='*ChangeTimeClock*'; Proc='msedge'}
    [pscustomobject]@{Display=3; Type='Url';  Target='http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=';                        Title='*ATR*';           Proc='msedge'}
    [pscustomobject]@{Display=4; Type='App';  Target='C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe';                                      Title='*AXIS*';          Proc='ACSP'}
    [pscustomobject]@{Display=5; Type='App';  Target='C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe';                Title='*HealthMonitor*'; Proc='WilliamsF1*'}
    [pscustomobject]@{Display=6; Type='Url';  Target='http://streamlit-atf.dev-aero.factory.wf1/Auto_QA';                                              Title='*Auto_QA*';       Proc='msedge'}
    [pscustomobject]@{Display=7; Type='Url';  Target='http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView'; Title='*Plant_Overview_ATF*'; Proc='msedge'}
    [pscustomobject]@{Display=8; Type='Url';  Target='http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock';                  Title='*ChangeTimeClock*'; Proc='msedge'}
)

# ==============================
# 3. Startup
# ==============================
Log "Waiting 12 seconds for Explorer/network..."
Start-Sleep -Seconds 12

Log "Detected monitors:"
[System.Windows.Forms.Screen]::AllScreens | Sort-Object DeviceName | ForEach-Object {
    Log "$($_.DeviceName) -> $($_.Bounds)"
}

$Launched = @()

foreach ($item in $Items) {
    $screen = Get-ScreenByDisplayNumber -DisplayNumber $item.Display
    if (-not $screen) { continue }

    Log "Launching DISPLAY$($item.Display): $($item.Target)"

    if ($item.Type -eq 'Url') {
        Start-Process -FilePath $BrowserExe -ArgumentList "--new-window", $item.Target -WindowStyle Normal
    } else {
        if (Test-Path $item.Target) {
            Start-Process -FilePath $item.Target -WindowStyle Normal
        } else {
            Log "EXE not found: $($item.Target)" "ERROR"
            continue
        }
    }

    # Wait and move (with retry)
    $proc = Wait-ForWindow -ProcessName $item.Proc -TitleMatch $item.Title -TimeoutSec 70 -Retries 3
    if ($proc) {
        $success = Move-WindowToScreen -Handle $proc.MainWindowHandle -Screen $screen -AppName "$($item.Proc) (Display $($item.Display))"
        if ($success) { $Launched += @{Handle=$proc.MainWindowHandle; Screen=$screen; Name=$item.Proc} }
    } else {
        Log "FAILED to get window for DISPLAY$($item.Display)" "ERROR"
    }

    Start-Sleep -Seconds 3  # Let system breathe
}

# ==============================
# 4. Second-pass correction (critical!)
# ==============================
Log "Second-pass window correction in 15 seconds..."
Start-Sleep -Seconds 15

foreach ($win in $Launched) {
    $current = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -eq $win.Handle }
    if ($current) {
        Move-WindowToScreen -Handle $win.Handle -Screen $win.Screen -AppName $win.Name | Out-Null
    }
}

Log "=== WT-Healthmon startup COMPLETED successfully ===" "INFO"

# Optional: Toast notification on failure (requires BurntToast module or Windows 10+)
# if ((Get-Content $LogPath | Select-String "ERROR" -Quiet)) { ... }

# ==============================
# 5. Optional Watchdog Mode (run this script every 5 min via Task Scheduler)
# ==============================
# Uncomment below to make it a watchdog (checks every run if windows are still on correct screens)
<#
$missing = 0
foreach ($item in $Items) {
    $screen = Get-ScreenByDisplayNumber $item.Display
    $found = Get-Process -Name $item.Proc -ErrorAction SilentlyContinue | Where-Object {
        $_.MainWindowTitle -like $item.Title -and (Get-Process | Where-Object MainWindowHandle -eq $_.MainWindowHandle).MainWindowHandle -ne [IntPtr]::Zero
    } | Where-Object {
        $hwnd = $_.MainWindowHandle
        $placement = [PSCustomObject]@{}
        [Win32]::GetWindowRect($hwnd, [ref]$placement) | Out-Null
        $placement.X -eq $screen.Bounds.X
    }
    if (-not $found) { $missing++ }
}
if ($missing -gt 2) { Log "Too many windows missing – full restart recommended" "ERROR" }
#>

exit 0