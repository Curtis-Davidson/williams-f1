<#
.SYNOPSIS
    WT Healthmon 8-screen launcher + Permanent Watchdog (Nov 2025)
    Now with auto-relaunch of HealthMonitor.exe if it ever crashes
#>

# ==============================
# 0. Config & Logging
# ==============================
$LogPath = "C:\Logs\WT-Healthmon-Startup.log"
$null = New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue

function Log ($Msg, $Level="INFO") {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Msg" | Out-File -FilePath $LogPath -Append -Encoding utf8
    if ($Level -eq "ERROR") { Write-Host $Msg -ForegroundColor Red }
}

Log "=== WT-Healthmon watchdog script started ==="

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
# 1. Core Functions
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
    Start-Sleep -Milliseconds 200
    [Win32]::SetWindowPos($Handle, $HWND_TOP, $b.X, $b.Y, $b.Width, $b.Height, $SWP_SHOWWINDOW) | Out-Null
    Log "$Name restored to full-screen on $($Screen.DeviceName)"
    return $true
}

# ==============================
# 2. Initial Launch (same as v2)
# ==============================
# (Insert exact same launch code from v2 here – omitted for brevity, just copy-paste the $Items array and the foreach loop that launches everything)

# ... [YOUR EXISTING LAUNCH CODE FROM v2 GOES HERE] ...

# After initial launch, start the permanent watchdog
Log "Initial launch complete – starting permanent watchdog for HealthMonitor.exe"

# ==============================
# 3. Permanent Watchdog Loop (this runs forever)
# ==============================
$HealthMonitorPath = "C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe"
$Display5 = Get-ScreenByDisplayNumber 5

while ($true) {
    $hm = Get-Process -Name "WilliamsF1.WindTunnel.HealthMonitor.Host" -ErrorAction SilentlyContinue

    if (-not $hm) {
        Log "HealthMonitor.exe NOT RUNNING → restarting now" "WARN"
        try {
            $proc = Start-Process -FilePath $HealthMonitorPath -PassThru -WindowStyle Normal
            Log "HealthMonitor.exe relaunched (PID $($proc.Id))"

            # Wait for its main window
            $stopwatch = [Diagnostics.Stopwatch]::StartNew()
            while ($stopwatch.Elapsed.TotalSeconds -lt 60) {
                $p = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
                if ($p -and $p.MainWindowHandle -ne [IntPtr]::Zero) {
                    Move-WindowToScreen $p.MainWindowHandle $Display5 "HealthMonitor.exe"
                    break
                }
                Start-Sleep -Milliseconds 800
            }
        }
        catch {
            Log "Failed to restart HealthMonitor.exe: $_" "ERROR"
        }
    }
    else {
        # Optional: re-force full-screen every hour in case the app shrinks itself
        $hm | Where-Object MainWindowHandle -ne [IntPtr]::Zero | ForEach-Object {
            $curBounds = $_.MainWindowHandle | ForEach-Object {
                $rect = New-Object RECT
                [Win32]::GetWindowRect($_, [ref]$rect) | Out-Null
                $rect
            }
            if ($curBounds -and ($curBounds.Left -ne $Display5.Bounds.X -or $curBounds.Top -ne $Display5.Bounds.Y)) {
                Move-WindowToScreen $_.MainWindowHandle $Display5 "HealthMonitor.exe (hourly fix)"
            }
        }
    }

    Start-Sleep -Seconds 4  # Check every 4 seconds → <4s recovery time
}