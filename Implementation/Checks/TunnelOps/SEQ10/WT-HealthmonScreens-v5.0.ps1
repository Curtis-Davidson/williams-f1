<#
.SYNOPSIS
    WT-HEALTHMON 8-screen launcher – v5.0 (Dec 2025, factory rig)

.DESCRIPTION
    Launches all seven WT dashboards / apps and places them deterministically
    on Physical Screens 2–8 (left → right wall layout) with logging and retries.

.NOTES
    Author : Paul R. Davidson
    Rig    : WT-Healthmon – 8 monitors, Chrome + AXIS + HealthMonitor
#>

# ============================================================
# 1. CLEAN BROWSER STATE (BEST EFFORT, IGNORE ACCESS ERRORS)
# ============================================================
Get-Process *edge*, chrome -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue

taskkill /f /im msedge.exe /im chrome.exe /im msedgewebview2.exe 2>$null | Out-Null
Start-Sleep -Seconds 5

# ============================================================
# 2. LOGGING
# ============================================================
$Log = "C:\Logs\WT-Healthmon-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date)

function L {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Message" | Tee-Object -FilePath $Log -Append
}

L "=== WT-HEALTHMON v5.0 LAUNCH STARTED ==="

# ============================================================
# 3. SCREEN DISCOVERY – LEFT→RIGHT WALL ORDER
# ============================================================
Add-Type -AssemblyName System.Windows.Forms

$screens = [System.Windows.Forms.Screen]::AllScreens |
        Sort-Object { $_.Bounds.X }

L "Detected $($screens.Count) monitors (physical wall order):"
for ($i = 0; $i -lt $screens.Count; $i++) {
    $scr = $screens[$i]
    L ("  Physical #{0} → {1} Bounds={2}" -f ($i+1), $scr.DeviceName, $scr.Bounds)
}

# ============================================================
# 4. CHROME + PROFILE ROOT
# ============================================================
$ChromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $ChromeExe)) {
    L "Chrome executable not found at: $ChromeExe" "ERROR"
    exit 1
}

$ProfileRoot = "C:\WT-Healthmon\ChromeProfiles"
New-Item -ItemType Directory -Path $ProfileRoot -Force | Out-Null
L "Chrome: $ChromeExe"
L "Profile root: $ProfileRoot"

# Common Chrome flags to suppress first-run / sync / nags
$ChromeBaseArgs = @(
    "--new-window",
    "--no-first-run",
    "--disable-fre",
    "--no-default-browser-check",
    "--disable-sync",
    "--disable-features=ChromeWhatsNewUI"
)

# ============================================================
# 5. APPLICATION MAP (PHYSICAL 2–8)
# ============================================================
#  Physical 2 = CTC-1
#  Physical 3 = ATR
#  Physical 4 = AXIS
#  Physical 5 = HealthMonitor
#  Physical 6 = AutoQA
#  Physical 7 = Plant
#  Physical 8 = CTC-2
#  Physical 1 = (unused)

$Items = @(
    [pscustomobject]@{
        Name   = "CTC-1"
        Phys   = 2
        Type   = "Chrome"
        Url    = "http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock"
        Title  = "*ChangeTimeClock*"
        ProfileName = "CTC-1"
    }
    [pscustomobject]@{
        Name   = "ATR"
        Phys   = 3
        Type   = "Chrome"
        Url    = "http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token="
        Title  = "*ATR*"
        ProfileName = "ATR"
    }
    [pscustomobject]@{
        Name   = "AXIS"
        Phys   = 4
        Type   = "Exe"
        Exe    = "C:\Program Files\Axis Communications\AXIS Camera Station\Client Latest\AcsClient.exe"
        Title  = "*AXIS*"
        ProfileName = $null
    }
    [pscustomobject]@{
        Name   = "HealthMonitor"
        Phys   = 5
        Type   = "Exe"
        Exe    = "C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe"
        Title  = "*HealthMonitor*"
        ProfileName = $null
    }
    [pscustomobject]@{
        Name   = "AutoQA"
        Phys   = 6
        Type   = "Chrome"
        Url    = "http://streamlit-atf.dev-aero.factory.wf1/Auto_QA"
        Title  = "*Auto_QA*"
        ProfileName = "AutoQA"
    }
    [pscustomobject]@{
        Name   = "Plant"
        Phys   = 7
        Type   = "Chrome"
        Url    = "http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView"
        Title  = "*Plant_Overview_ATF*"
        ProfileName = "Plant"
    }
    [pscustomobject]@{
        Name   = "CTC-2"
        Phys   = 8
        Type   = "Chrome"
        Url    = "http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock"
        Title  = "*ChangeTimeClock*"
        ProfileName = "CTC-2"
    }
)

# ============================================================
# 6. LAUNCH ALL ITEMS (WITH PER-URL PROFILES)
# ============================================================
$Launched = @()

foreach ($item in $Items) {

    $scr = if ($item.Phys -le $screens.Count) { $screens[$item.Phys - 1] } else { $null }
    if (-not $scr) {
        L "No screen object for Physical $($item.Phys) – skipping $($item.Name)" "WARN"
        continue
    }

    L "Launching $($item.Name) → Physical $($item.Phys) (Device $($scr.DeviceName))"

    $proc = $null

    if ($item.Type -eq "Chrome") {

        $profilePath = Join-Path $ProfileRoot $item.ProfileName
        New-Item -ItemType Directory -Path $profilePath -Force | Out-Null

        $args = @()
        $args += $ChromeBaseArgs
        $args += "--user-data-dir=$profilePath"
        $args += $item.Url

        $proc = Start-Process -FilePath $ChromeExe `
                              -ArgumentList $args `
                              -PassThru

        L "  Chrome started with profile: $profilePath (PID $($proc.Id))"
    }
    elseif ($item.Type -eq "Exe") {

        if (-not (Test-Path $item.Exe)) {
            L "  EXE missing: $($item.Exe) – skipping launch." "ERROR"
            continue
        }

        $proc = Start-Process -FilePath $item.Exe -PassThru
        L "  EXE started: $($item.Exe) (PID $($proc.Id))"
    }

    if ($proc) {
        $Launched += [pscustomobject]@{
            Name  = $item.Name
            Phys  = $item.Phys
            Pid   = $proc.Id
            Title = $item.Title
            Type  = $item.Type
        }
    }

    Start-Sleep -Seconds 4
}

L "Launch phase complete – $($Launched.Count) processes tracked."

# ============================================================
# 7. WIN32 API FOR WINDOW PLACEMENT
# ============================================================
Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class WTWin32 {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd, IntPtr hWndInsertAfter,
        int X, int Y, int cx, int cy, uint uFlags);
}
"@

$SWP_SHOWWINDOW = 0x0040
$HWND_TOP       = [IntPtr]::Zero

# ============================================================
# 8. RETRY + PLACE WINDOWS
# ============================================================
Start-Sleep -Seconds 15
L "Starting placement phase..."

function Get-WindowForEntry {
    param(
        [pscustomobject]$Entry
    )

    $maxTries   = 5
    $delaySec   = 3
    $candidate  = $null

    for ($t = 1; $t -le $maxTries; $t++) {

        # Try by PID first
        $candidate = Get-Process -Id $Entry.Pid -ErrorAction SilentlyContinue |
                Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }

        if ($candidate) { break }

        # Fallback for Chrome – try by title pattern
        if ($Entry.Type -eq "Chrome" -and $Entry.Title) {
            $candidate = Get-Process chrome -ErrorAction SilentlyContinue |
                    Where-Object {
                        $_.MainWindowHandle -ne [IntPtr]::Zero -and
                                $_.MainWindowTitle -like $Entry.Title
                    } |
                    Sort-Object StartTime |
                    Select-Object -First 1
            if ($candidate) { break }
        }

        Start-Sleep -Seconds $delaySec
    }

    return $candidate
}

foreach ($entry in $Launched) {

    $scr = if ($entry.Phys -le $screens.Count) { $screens[$entry.Phys - 1] } else { $null }
    if (-not $scr) {
        L "No screen object for Physical $($entry.Phys) – skipping $($entry.Name)" "WARN"
        continue
    }

    $proc = Get-WindowForEntry -Entry $entry
    if (-not $proc) {
        L "No live window for $($entry.Name) (PID $($entry.Pid)) – skipping placement." "WARN"
        continue
    }

    $b = $scr.Bounds

    [WTWin32]::SetWindowPos(
            $proc.MainWindowHandle,
            $HWND_TOP,
            $b.X, $b.Y, $b.Width, $b.Height,
            $SWP_SHOWWINDOW
    ) | Out-Null

    L "PLACED $($entry.Name) → Physical $($entry.Phys) Device=$($scr.DeviceName)"
}

L "=== WT-HEALTHMON v5.0 DONE (SEE LOG: $Log) ==="
# Optional: open logs folder for quick verification
# explorer "C:\Logs"