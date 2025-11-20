Updated startup script using Edge

Separate monitor-verifier script

Confluence text + JIRA change summary for SEQ10

Updated WT-Healthmon startup script (Edge, not Chrome)

Exact command – create script folder

mkdir "C:\WF1\WT-Healthmon" -Force


Exact command – create/edit script file

notepad "C:\WF1\WT-Healthmon\WT-Healthmon-Startup.ps1"


Paste the FULL code below into that file and save.

# WT-Healthmon-Startup.ps1
# Purpose:
#   - At user logon, launch WT Healthmon dashboards and apps
#   - Move each window to the correct monitor (DISPLAY1..DISPLAY8 per Mitch diagram)
#   - Designed for WT-Healthmon PC with 8 outputs (2 and 9 mirrored, 8 is a separate output)

# ------------------------------
# 0. Safety: ensure UI assemblies are loaded
# ------------------------------
Add-Type -AssemblyName System.Windows.Forms

# Win32 interop to move/resize windows
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
$HWND_TOP = [IntPtr]::Zero

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
[Parameter(Mandatory)] $Screen
)

    if ($Handle -eq [IntPtr]::Zero) {
        Write-Warning "Move-WindowToScreen called with null handle – skipping."
        return
    }

    $bounds = $Screen.Bounds
    # Maximise then force to full bounds
    [Win32]::ShowWindowAsync($Handle, 3) | Out-Null  # SW_MAXIMIZE
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
# 1. Configuration – what goes on which monitor
# ------------------------------------
# IMPORTANT:
#   - Edge path: verify which one exists on this box
#       C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
#       C:\Program Files\Microsoft\Edge\Application\msedge.exe
#   - Update AxisCameraExe if the path is different
#   - HealthMonitorExe path already matches Mitch’s note

$BrowserExeCandidates = @(
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
"C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

$BrowserExe = $BrowserExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $BrowserExe) {
Write-Error "Microsoft Edge not found in standard paths. Update `\$BrowserExeCandidates` in script."
exit 1
}

$AxisCameraExe    = "C:\Program Files\Axis\AXIS Camera Station Pro\ACSP.exe"   # confirm path
$HealthMonitorExe = "C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe"

$Items = @(
# DISPLAY 1 – Blank (nothing started)

    # DISPLAY 2 – ChangeTimeClock (WT working section)
    [pscustomobject]@{
        Display     = 2
        Type        = 'Url'
        Target      = 'http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'
        ProcessName = 'msedge'
        WindowTitle = '*ChangeTimeClock*'
    }

    # DISPLAY 3 – ATR dashboard
    [pscustomobject]@{
        Display     = 3
        Type        = 'Url'
        Target      = 'http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token='
        ProcessName = 'msedge'
        WindowTitle = '*ATR*'
    }

    # DISPLAY 4 – Axis Camera Station Pro (ATF healthmon view)
    [pscustomobject]@{
        Display     = 4
        Type        = 'App'
        Target      = $AxisCameraExe
        Arguments   = ''
        ProcessName = 'ACSP'   # confirm via Task Manager if different
        WindowTitle = '*AXIS*'
    }

    # DISPLAY 5 – Health Monitor host app
    [pscustomobject]@{
        Display     = 5
        Type        = 'App'
        Target      = $HealthMonitorExe
        Arguments   = ''
        ProcessName = 'WilliamsF1.WindTunnel.HealthMonitor.Host'
        WindowTitle = '*HealthMonitor*'
    }

    # DISPLAY 6 – Auto_QA
    [pscustomobject]@{
        Display     = 6
        Type        = 'Url'
        Target      = 'http://streamlit-atf.dev-aero.factory.wf1/Auto_QA'
        ProcessName = 'msedge'
        WindowTitle = '*Auto_QA*'
    }

    # DISPLAY 7 – Plant overview (ATF)
    [pscustomobject]@{
        Display     = 7
        Type        = 'Url'
        Target      = 'http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView'
        ProcessName = 'msedge'
        WindowTitle = '*Plant_Overview_ATF*'
    }

    # DISPLAY 8 – ChangeTimeClock (mirror layout of 2, separate output)
    [pscustomobject]@{
        Display     = 8
        Type        = 'Url'
        Target      = 'http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock'
        ProcessName = 'msedge'
        WindowTitle = '*ChangeTimeClock*'
    }
)

# ------------------------------------
# 2. Optional: small delay at logon so Explorer + network are ready
# ------------------------------------
Start-Sleep -Seconds 10

Write-Host "`n[INFO] Monitors detected:" -ForegroundColor Cyan
[System.Windows.Forms.Screen]::AllScreens |
Sort-Object DeviceName |
ForEach-Object {
"{0} : {1}" -f $_.DeviceName, $_.Bounds
} | Write-Host

# ------------------------------------
# 3. Launch everything and move to target screens
# ------------------------------------
foreach ($item in $Items) {

    $screen = Get-ScreenByDisplayNumber -DisplayNumber $item.Display
    if (-not $screen) { continue }

    Write-Host "`n[STEP] DISPLAY$($item.Display) -> $($item.Target)" -ForegroundColor Cyan

    switch ($item.Type) {
        'Url' {
            if (-not (Test-Path $BrowserExe)) {
                Write-Warning "Browser not found at '$BrowserExe'. Update `\$BrowserExe`."
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

    # Wait for the main window then move it
    $proc = Wait-ForMainWindow -ProcessName $item.ProcessName -TitleMatch $item.WindowTitle -TimeoutSeconds 45
    if ($proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
        Move-WindowToScreen -Handle $proc.MainWindowHandle -Screen $screen
        Write-Host "[OK] Placed '$($item.ProcessName)' on DISPLAY$($item.Display)." -ForegroundColor Green
    }
    else {
        Write-Warning "Could not move process '$($item.ProcessName)' – check process name/title or title filter."
    }
}

Write-Host "`n[SUCCESS] WT-Healthmon startup script completed." -ForegroundColor Green


Expected result / test

From an elevated PowerShell on WT-Healthmon:

Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
powershell.exe -ExecutionPolicy Bypass -File "C:\WF1\WT-Healthmon\WT-Healthmon-Startup.ps1"


You should see each Edge window / app launch and hop to the correct display.
Once happy, drop a shortcut to that script in:

C:\Users\shr-tunops-wte\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

so it runs at logon.

Monitor verifier script – Get-WTHealthmon-Monitors.ps1

Exact command – create file

notepad "C:\WF1\WT-Healthmon\Get-WTHealthmon-Monitors.ps1"


Paste this and save:

# Get-WTHealthmon-Monitors.ps1
# Purpose:
#   - Dump the current monitor mapping with DISPLAY number and bounds
#   - Used to verify that Windows sees monitors as expected before we pin apps

Add-Type -AssemblyName System.Windows.Forms

Write-Host "`n[WT-Healthmon] Current monitor layout:" -ForegroundColor Cyan

[System.Windows.Forms.Screen]::AllScreens |
Sort-Object DeviceName |
ForEach-Object {
$dev  = $_.DeviceName
$b    = $_.Bounds
$disp = $dev.Replace("\\.\DISPLAY","")
"{0} -> {1}  ({2}x{3} at {4},{5})" -f $dev, "DISPLAY$disp", $b.Width, $b.Height, $b.X, $b.Y
} | Write-Host


Expected result / test

Run:

powershell.exe -ExecutionPolicy Bypass -File "C:\WF1\WT-Healthmon\Get-WTHealthmon-Monitors.ps1"


You should see each \\.\DISPLAYn line printed – that lets you prove Windows’ numbering matches Mitch’s 1-to-8 layout before you blame the script.

Confluence diagram text + JIRA change summary (SEQ10)

A) Confluence – “WT-Healthmon Screen Layout & Startup Automation (SEQ10)”

You can paste this straight into Confluence and tweak names:

Title: WT-Healthmon Screen Layout & Startup Automation (SEQ10)

Overview
- WT-Healthmon PC drives eight displays in the Tunnel Operations area.
- Each display is pinned to a specific dashboard or application at user logon.
- A PowerShell startup script (WT-Healthmon-Startup.ps1) launches the required URLs/apps and moves each window to the correct monitor.

Monitor mapping (per Mitch Hackwood 18/11/2025)
- DISPLAY 1: Blank (no content)
- DISPLAY 2: ChangeTimeClock (WT working section)
  URL: http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock
- DISPLAY 3: ATR dashboard
  URL: http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=
- DISPLAY 4: ATF Healthmon – Axis Camera Station Pro
  Application: AXIS Camera Station Pro on server WT-CAMS01 (ATF Healthmon view)
- DISPLAY 5: Wind Tunnel Health Monitor host
  Application: C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe
- DISPLAY 6: Auto_QA
  URL: http://streamlit-atf.dev-aero.factory.wf1/Auto_QA
- DISPLAY 7: ATF plant overview
  URL: http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView
- DISPLAY 8: ChangeTimeClock (duplicate layout of DISPLAY 2, separate output)
  URL: http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock
- DISPLAY 9: Physical mirror of DISPLAY 2 (handled by graphics configuration, not script)

Automation details
- Script location: C:\WF1\WT-Healthmon\WT-Healthmon-Startup.ps1
- Browser: Microsoft Edge (msedge.exe)
- Script behaviour:
    - Waits 10 seconds after logon for Explorer and network to initialise.
    - Launches Edge windows and native applications.
    - Waits for each main window handle, then moves it to the correct DISPLAY using Win32 APIs.
    - Maximises each window and forces it to the full bounds of the target screen.

Operational notes
- A separate verifier script (Get-WTHealthmon-Monitors.ps1) dumps the current Windows monitor mapping.
- Both scripts are designed to be run manually (for testing) and automatically via the user Startup folder.
- If window titles or process names change (e.g. browser updates), only the configuration section of the startup script needs updating.


B) JIRA change summary text (SEQ10)

Use something like this for the ticket body:

Summary
Implement automated WT-Healthmon screen layout (8-display TunnelOps dashboard) using PowerShell startup script.

Description
As part of SEQ10 (TunnelOps migration), implement a repeatable method to launch and place all WT-Healthmon dashboards and applications on the correct displays at user logon.

Scope
- WT-Healthmon PC only.
- Eight physical outputs (2 and 9 mirrored at GPU level).
- Applications/URLs:
    - ChangeTimeClock (x2 outputs)
    - ATR dashboard
    - Auto_QA
    - ATF plant overview
    - Axis Camera Station Pro (ATF healthmon view)
    - WilliamsF1 WindTunnel Health Monitor host.

Implementation
- Create folder C:\WF1\WT-Healthmon.
- Deploy two PowerShell scripts:
    - WT-Healthmon-Startup.ps1 – launches Edge / applications and moves windows to DISPLAY1..DISPLAY8 using Win32 APIs.
    - Get-WTHealthmon-Monitors.ps1 – diagnostic script to dump Windows monitor mapping.
- Place a shortcut to WT-Healthmon-Startup.ps1 in the WT-Healthmon user Startup folder so it runs at logon.
- Browser: Microsoft Edge (msedge.exe) using local intranet URLs (no external dependency change).

Testing
- Log on as WT-Healthmon user.
- Confirm Get-WTHealthmon-Monitors.ps1 output matches Mitch Hackwood’s 8-screen layout.
- Run WT-Healthmon-Startup.ps1 and verify:
    - Each dashboard/app opens.
    - Each window appears on the correct physical display and is maximised.
- Reboot and confirm behaviour is consistent at logon.

Rollback
- Remove the startup shortcut from the user Startup folder.
- Delete or rename C:\WF1\WT-Healthmon\WT-Healthmon-Startup.ps1.
- No registry or system-level changes are made; reverting leaves