<#
WT-HEALTHMON 8-SCREEN LAUNCHER – v5.2 (FINAL-FINAL, DEC 2025)
Author  : Paul R. Davidson (Curtis-Davidson)
Purpose : Launch 7 dashboards/apps and hard-place them on Physical 2..8
          with full logging, retry, and kiosk/fullscreen Chrome.

Changes vs v5.1:
  - Chrome launches now use kiosk + start-fullscreen.
  - Still uses per-launch user-data-dir tagged with WTHealthmonProfile.
  - Only old WT-Healthmon Chrome instances are killed (no user Chrome).
#>

# ============================================================
# 1. CLEAN UP ONLY OLD WT-HEALTHMON CHROME INSTANCES
#    (NO NORMAL USER CHROME → NO RESTORE / SIGN-IN BUBBLES)
# ============================================================

$WTProfileTag = "WTHealthmonProfile"

try {
    $oldWtChrome = Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -like "*$WTProfileTag*" }

    foreach ($p in $oldWtChrome) {
        Stop-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
    }
}
catch { }

Start-Sleep -Seconds 2

# ============================================================
# 2. LOGGING
# ============================================================

$LogDir = "C:\Logs"
New-Item -Path $LogDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$Log = Join-Path $LogDir ("WT-Healthmon-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

function L {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Message" | Tee-Object -FilePath $Log -Append
}

L "=== WT-HEALTHMON 8-SCREEN LAUNCHER v5.2 STARTED ==="

# ============================================================
# 3. SCREEN DISCOVERY (LEFT → RIGHT WALL ORDER)
# ============================================================

Add-Type -AssemblyName System.Windows.Forms

$screens = [System.Windows.Forms.Screen]::AllScreens | Sort-Object { $_.Bounds.X }

L "Detected $($screens.Count) monitors (sorted by X):"
for ($i = 0; $i -lt $screens.Count; $i++) {
    L ("  Physical #{0}  Device={1}  Bounds={2}" -f ($i+1), $screens[$i].DeviceName, $screens[$i].Bounds)
}

# ============================================================
# 4. CHROME PATH (FIXED PATH ON WT-HEALTHMON RIG)
# ============================================================

$ChromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (-not (Test-Path $ChromeExe)) {
    L "Chrome not found at $ChromeExe – aborting." "ERROR"
    exit 1
}

L "Chrome path: $ChromeExe"

# ============================================================
# 5. APPLICATION / URL MAP (PHYSICAL WALL ORDER)
# ============================================================

# Physical mapping:
#   1 = unused
#   2 = CTC-1
#   3 = ATR
#   4 = AXIS
#   5 = Health
#   6 = AutoQA
#   7 = Plant
#   8 = CTC-2

$Apps = @(
    @{ Name="CTC-1";   Phys=2; Kind="Url"; Url="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock" }
    @{ Name="ATR";     Phys=3; Kind="Url"; Url="http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6`&token=" }
    @{ Name="AXIS";    Phys=4; Kind="Exe"; Exe="C:\Program Files\Axis Communications\AXIS Camera Station\Client Latest\AcsClient.exe" }
    @{ Name="Health";  Phys=5; Kind="Exe"; Exe="C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe" }
    @{ Name="AutoQA";  Phys=6; Kind="Url"; Url="http://streamlit-atf.dev-aero.factory.wf1/Auto_QA" }
    @{ Name="Plant";   Phys=7; Kind="Url"; Url="http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView" }
    @{ Name="CTC-2";   Phys=8; Kind="Url"; Url="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock" }
)

# ============================================================
# 6. LAUNCH PHASE – RECORD PIDs FOR DETERMINISTIC PLACEMENT
#    (CHROME FLAGS KILL ALL FIRST-RUN / RESTORE BUBBLES)
# ============================================================

$Launched = New-Object System.Collections.Generic.List[object]

foreach ($a in $Apps) {

    $screen = $screens[$a.Phys - 1]
    if (-not $screen) {
        L "No screen object for Physical $($a.Phys) – skipping $($a.Name)." "WARN"
        continue
    }

    L "Launching $($a.Name) → Physical $($a.Phys)"

    $proc = $null

    if ($a.Kind -eq "Url") {

        # Each launch gets its own WTHealthmon profile dir → no shared state, no restore bubble.
        $profile = "C:\Temp\{0}-{1}-{2}" -f $WTProfileTag, $a.Name, ([guid]::NewGuid().ToString())
        New-Item -Path $profile -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

        $args = @(
            "--new-window"
            "--kiosk"                    # true kiosk (no tabs, no address bar)
            "--start-fullscreen"         # belt-and-braces
            "--user-data-dir=$profile"
            "--no-first-run"
            "--disable-session-crashed-bubble"
            "--disable-features=ChromeWhatsNewUI,WelcomeUI,SigninPromo,StandaloneProfilePicker"
            $a.Url
        )

        $proc = Start-Process -FilePath $ChromeExe -ArgumentList $args -PassThru
        L "  → Chrome started (PID $($proc.Id), profile $profile)"

    } elseif ($a.Kind -eq "Exe") {

        if (Test-Path $a.Exe) {
            $proc = Start-Process -FilePath $a.Exe -PassThru
            L "  → EXE started (PID $($proc.Id))"
        }
        else {
            L "  → EXE missing: $($a.Exe)" "ERROR"
        }

    }

    if ($proc) {
        $Launched.Add([pscustomobject]@{
            Name = $a.Name
            Phys = $a.Phys
            Pid  = $proc.Id
        })
    }

    Start-Sleep -Seconds 3
}

# ============================================================
# 7. WIN32 API FOR WINDOW PLACEMENT
# ============================================================

if (-not ("W" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class W {
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
}
"@
}

Start-Sleep -Seconds 12
L "Starting placement pass…"

# ============================================================
# 8. PLACEMENT PASS (BY PID) + SIMPLE RETRY
# ============================================================

$SWP_SHOWWINDOW = 0x0040

foreach ($entry in $Launched) {

    $scr = $screens[$entry.Phys - 1]
    if (-not $scr) {
        L "No screen object for Physical $($entry.Phys) – skipping $($entry.Name)." "WARN"
        continue
    }

    $proc = $null
    $attempts = 0
    do {
        $attempts++
        $proc = Get-Process -Id $entry.Pid -ErrorAction SilentlyContinue
        if (-not $proc -or $proc.MainWindowHandle -eq [IntPtr]::Zero) {
            Start-Sleep -Seconds 2
        }
    } while (($attempts -lt 5) -and ($proc -and $proc.MainWindowHandle -eq [IntPtr]::Zero))

    if (-not $proc -or $proc.MainWindowHandle -eq [IntPtr]::Zero) {
        L "No live window for $($entry.Name) (PID $($entry.Pid)) – skipping placement." "WARN"
        continue
    }

    $b = $scr.Bounds

    [W]::SetWindowPos(
            $proc.MainWindowHandle,
            [IntPtr]::Zero,
            $b.X,
            $b.Y,
            $b.Width,
            $b.Height,
            $SWP_SHOWWINDOW
    ) | Out-Null

    L ("PLACED {0} → Physical {1}  Device={2}" -f $entry.Name, $entry.Phys, $scr.DeviceName)
}

L ("=== DONE – {0}/{1} LAUNCHED & PLACED (SEE LOG: {2}) ===" -f $Launched.Count, $Apps.Count, $Log) "INFO"

# Optional: open log folder for diagnostics
# explorer "$LogDir"