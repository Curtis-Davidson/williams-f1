<#
 WT-Healthmon-Startup.ps1  (EDGE VERSION)

 Purpose:
   - At user logon, launch WT Healthmon dashboards and apps
   - Move each window to the correct monitor (DISPLAY1..DISPLAY8)
   - Designed for the WT-Healthmon PC with 8 displays (2 and 9 mirrored)

 Notes:
   - Uses Microsoft Edge (msedge.exe) for all URLs
   - Assumes monitors are named \\.\DISPLAY1 .. \\.\DISPLAY8
   - You may need to tweak ProcessName / WindowTitle if app/window titles differ
#>

# ------------------------------
# 0. Load UI assemblies and Win32 interop
# ------------------------------
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X,
        int Y,
        int cx,
        int cy,
        uint uFlags
    );

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(
        IntPtr hWnd,
        int nCmdShow
    );
}
"@

# Constants for SetWindowPos
$SWP_SHOWWINDOW = 0x0040
$HWND_TOP       = [IntPtr]::Zero

function Get-ScreenByDisplayNumber {
    param(
        [Parameter(Mandatory)]
        [int] $DisplayNumber
    )

    $target = "\\.\DISPLAY$DisplayNumber"
    $screen = [System.Windows.Forms.Screen]::AllScreens |
            Where-Object { $_.DeviceName -eq $target }

    if (-not $screen) {
        Write-Warning "No screen found for $target – check monitor mapping."
    }
    return $screen
}

function Move-WindowToScreen {
    param(
        [Parameter(Mandatory)] [IntPtr] $Handle,
        [Parameter(Mandatory)]          $Screen
    )

    if ($Handle -eq [IntPtr]::Zero) {
        Write-Warning "Move-WindowToScreen called with null handle – skipping."
        return
    }

    $bounds = $Screen.Bounds

    # Maximise then force it to the screen bounds
    [Win32]::ShowWindowAsync($Handle, 3) | Out-Null   # SW_MAXIMIZE
    [Win32]::SetWindowPos(
            $Handle,
            $HWND_TOP,
            $bounds.X,
            $bounds.Y,
            $bounds.Width,
            $bounds.Height,
            $SWP_SHOWWINDOW
    ) | Out-Null
}

function Wait-ForMainWindow {
    param(
        [Parameter(Mandatory)] [string] $ProcessName,
        [string] $TitleMatch = $null,
        [int]    $TimeoutSeconds = 30
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    do {
        $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        foreach ($p in $procs) {
            if ($p.MainWindowHandle -ne [IntPtr]::Zero) {
                if (-not $TitleMatch -or ($p.MainWindowTitle -like $TitleMatch)) {
                    return $p
                }
            }
        }
        Start-Sleep -Milliseconds 500
    } while ($sw.Elapsed.TotalSeconds -lt $TimeoutSeconds)

    Write-Warning "Timeout waiting for main window of process '$ProcessName'."
    return $null
}

# ------------------------------------
# 1. Configuration – Edge + apps per monitor
# ------------------------------------

# Edge path (standard 64-bit install – adjust if needed)
$BrowserExe       = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Apps – confirm these two paths on the WT-Healthmon machine
$AxisCameraExe    = "C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe"
$HealthMonitorExe = "C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe"

$Items = @(
# Display 1 – Blank (nothing started)

# Display 2 – ChangeTimeClock (WT working section)
    [pscustomobject]@{
        Display     = 2
        Type        = 'Url'
        Target      = 'http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'
        ProcessName = 'msedge'
        WindowTitle = '*ChangeTimeClock*'
    }

# Display 3 – ATR dashboard
    [pscustomobject]@{
        Display     = 3
        Type        = 'Url'
        Target      = 'http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token='
        ProcessName = 'msedge'
        WindowTitle = '*ATR*'
    }

# Display 4 – Axis Camera Station Pro (ATF healthmon view)
    [pscustomobject]@{
        Display     = 4
        Type        = 'App'
        Target      = $AxisCameraExe
        Arguments   = ''
        ProcessName = 'ACSP'        # confirm via Task Manager
        WindowTitle = '*AXIS*'
    }

# Display 5 – Health Monitor host app
    [pscustomobject]@{
        Display     = 5
        Type        = 'App'
        Target      = $HealthMonitorExe
        Arguments   = ''
        ProcessName = 'WilliamsF1.WindTunnel.HealthMonitor.Host'
        WindowTitle = '*HealthMonitor*'
    }

# Display 6 – Auto_QA
    [pscustomobject]@{
        Display     = 6
        Type        = 'Url'
        Target      = 'http://streamlit-atf.dev-aero.factory.wf1/Auto_QA'
        ProcessName = 'msedge'
        WindowTitle = '*Auto_QA*'
    }

# Display 7 – Plant overview (ATF)
    [pscustomobject]@{
        Display     = 7
        Type        = 'Url'
        Target      = 'http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView'
        ProcessName = 'msedge'
        WindowTitle = '*Plant_Overview_ATF*'
    }

# Display 8 – ChangeTimeClock (mirror of 2)
    [pscustomobject]@{
        Display     = 8
        Type        = 'Url'
        Target      = 'http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'
        ProcessName = 'msedge'
        WindowTitle = '*ChangeTimeClock*'
    }
)

# ------------------------------------
# 2. Small logon delay so Explorer + network are ready
# ------------------------------------
Start-Sleep -Seconds 10

Write-Host "`n[INFO] Monitors detected:" -ForegroundColor Cyan
[System.Windows.Forms.Screen]::AllScreens |
        Sort-Object DeviceName |
        ForEach-Object {
            "{0} : {1} ({2}x{3} at {4},{5})" -f `
            $_.DeviceName, $_.Bounds, $_.Bounds.Width, $_.Bounds.Height, $_.Bounds.X, $_.Bounds.Y
        } | Write-Host

# ------------------------------------
# 3. Launch each item and move window to the correct screen
# ------------------------------------
foreach ($item in $Items) {

    $screen = Get-ScreenByDisplayNumber -DisplayNumber $item.Display
    if (-not $screen) { continue }

    Write-Host "`n[STEP] DISPLAY$($item.Display) -> $($item.Target)" -ForegroundColor Cyan

    switch ($item.Type) {
        'Url' {
            if (-not (Test-Path $BrowserExe)) {
                Write-Warning "Browser not found at '$BrowserExe'. Update `\$BrowserExe."
                continue
            }
            Start-Process -FilePath $BrowserExe -ArgumentList "--new-window", $item.Target
        }

        'App' {
            if (-not (Test-Path $item.Target)) {
                Write-Warning "Application not found at '$($item.Target)'."
                continue
            }
            Start-Process -FilePath $item.Target -ArgumentList $item.Arguments
        }

        default {
            Write-Warning "Unknown Type '$($item.Type)' for DISPLAY$($item.Display)."
            continue
        }
    }

    $proc = Wait-ForMainWindow -ProcessName $item.ProcessName -TitleMatch $item.WindowTitle -TimeoutSeconds 45

    if ($proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
        Move-WindowToScreen -Handle $proc.MainWindowHandle -Screen $screen
        Write-Host "[OK] Placed '$($item.ProcessName)' on DISPLAY$($item.Display)." -ForegroundColor Green
    }
    else {
        Write-Warning "Could not move process '$($item.ProcessName)' – check process name/title."
    }
}

Write-Host "`n[SUCCESS] WT-Healthmon startup script completed." -ForegroundColor Green