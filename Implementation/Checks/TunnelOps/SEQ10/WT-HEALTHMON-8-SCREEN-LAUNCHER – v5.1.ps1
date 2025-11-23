@'
<#
WT-HEALTHMON 8-SCREEN LAUNCHER – v5.1 (Final, Dec 2025)
Author : Paul R. Davidson (Curtis-Davidson)

Changes vs v5.0:
  - Added --kiosk and --start-fullscreen to Chrome launches
  - Added central ChromeBaseArgs for clarity
  - Added per-window retry loop for slow-starting UIs
#>

# ============================================================
# 0. ENVIRONMENT PREP
# ============================================================

# Try to kill any user-level Edge/Chrome instances (ignore access denied)
Get-Process *edge*,chrome -ErrorAction SilentlyContinue | ForEach-Object {
    try { $_ | Stop-Process -Force -ErrorAction Stop } catch {}
}

# Extra belt-and-braces
taskkill /f /im chrome.exe /im msedge.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

# Logging
$Log = "C:\Logs\WT-Healthmon-$(Get-Date -f 'yyyyMMdd-HHmmss').log"
New-Item -ItemType File -Path $Log -Force -ErrorAction SilentlyContinue | Out-Null

function L {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$t [$Level] $Message" | Tee-Object -FilePath $Log -Append
}

L "=== WT-HEALTHMON v5.1 LAUNCH STARTED ==="

# Ensure profile & log roots exist
New-Item -ItemType Directory -Path "C:\WT-Healthmon\ChromeProfiles" -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "C:\Logs" -Force -ErrorAction SilentlyContinue | Out-Null

# ============================================================
# 1. SCREEN DETECTION (LEFT→RIGHT WALL ORDER)
# ============================================================

Add-Type -AssemblyName System.Windows.Forms

$screens = [System.Windows.Forms.Screen]::AllScreens |
           Sort-Object { $_.Bounds.X }

L "Detected $($screens.Count) monitors (left→right):"
for ($i = 0; $i -lt $screens.Count; $i++) {
    L ("  Physical #{0}  →  {1} @ X={2}" -f ($i+1), $screens[$i].DeviceName, $screens[$i].Bounds.X)
}

# ============================================================
# 2. CHROME PATH + BASE ARGUMENTS
# ============================================================

$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (!(Test-Path $Chrome)) {
    L "Chrome not found at $Chrome – aborting" "ERROR"
    exit 1
}
L "Chrome path OK: $Chrome"

# Common Chrome switches used for ALL WT tabs
$ChromeBaseArgs = @(
    "--new-window"
    "--no-first-run"
    "--disable-fre"
    "--no-default-browser-check"
    "--disable-sync"
    "--disable-features=ChromeWhatsNewUI"
    "--kiosk"            # fullscreen kiosk window
    "--start-fullscreen" # belt-and-braces
)

# ============================================================
# 3. DEFINE APPS (PHYSICAL MAP)
#     Mapping confirmed by you:
#       2 = CTC-1
#       3 = ATR
#       4 = AXIS
#       5 = HealthMonitor
#       6 = AutoQA
#       7 = Plant
#       8 = CTC-2
#       1 = unused
# ============================================================

$Apps = @(
    @{ Name="CTC-1"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";                 Phys=2; Title="*ChangeTimeClock*"; Proc="chrome" }
    @{ Name="ATR";   URL="http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6`&token=";                    Phys=3; Title="*ATR*";             Proc="chrome" }
    @{ Name="AXIS";  EXE="C:\Program Files\Axis Communications\AXIS Camera Station\Client Latest\AcsClient.exe";   Phys=4; Title="*AXIS*";            Proc="AcsClient" }
    @{ Name="Health";EXE="C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe";             Phys=5; Title="*HealthMonitor*";   Proc="WilliamsF1*"}
    @{ Name="AutoQA";URL="http://streamlit-atf.dev-aero.factory.wf1/Auto_QA";                                     Phys=6; Title="*Auto_QA*";         Proc="chrome" }
    @{ Name="Plant"; URL="http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView"; Phys=7; Title="*Plant*"; Proc="chrome" }
    @{ Name="CTC-2"; URL="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";                 Phys=8; Title="*ChangeTimeClock*"; Proc="chrome" }
)

# ============================================================
# 4. LAUNCH EACH ITEM WITH PER-APP PROFILE
# ============================================================

$Launched = @()

foreach ($a in $Apps) {
    $scr = $screens[$a.Phys - 1]
    if (-not $scr) {
        L "No screen object for Physical $($a.Phys) – skipping $($a.Name)" "WARN"
        continue
    }

    L "Launching $($a.Name) to Physical $($a.Phys) ($($scr.DeviceName))"

    if ($a.ContainsKey("URL") -and $a.URL) {
        # Per-app Chrome profile
        $profilePath = "C:\WT-Healthmon\ChromeProfiles\$($a.Name)"
        New-Item -ItemType Directory -Path $profilePath -Force -ErrorAction SilentlyContinue | Out-Null

        $args = @()
        $args += $ChromeBaseArgs
        $args += "--user-data-dir=$profilePath"
        $args += $a.URL

        try {
            $p = Start-Process -FilePath $Chrome -ArgumentList $args -PassThru -ErrorAction Stop
            L "Chrome started for $($a.Name) (PID $($p.Id), Profile=$profilePath)"
            $Launched += @{
                Name  = $a.Name
                Phys  = $a.Phys
                PID   = $p.Id
                Title = $a.Title
            }
        } catch {
            L "FAILED to start Chrome for $($a.Name): $($_.Exception.Message)" "ERROR"
        }
    }
    elseif ($a.ContainsKey("EXE") -and $a.EXE) {
        if (Test-Path $a.EXE) {
            try {
                $p = Start-Process -FilePath $a.EXE -PassThru -ErrorAction Stop
                L "EXE started for $($a.Name) (PID $($p.Id))"
                $Launched += @{
                    Name  = $a.Name
                    Phys  = $a.Phys
                    PID   = $p.Id
                    Title = $a.Title
                }
            } catch {
                L "FAILED to start EXE for $($a.Name): $($_.Exception.Message)" "ERROR"
            }
        }
        else {
            L "Missing EXE for $($a.Name): $($a.EXE)" "ERROR"
        }
    }
    else {
        L "Item $($a.Name) has neither URL nor EXE – config error" "ERROR"
    }

    Start-Sleep -Seconds 2
}

# ============================================================
# 5. WINDOW PLACEMENT (PID-FIRST WITH RETRY)
# ============================================================

Start-Sleep -Seconds 12
L "Beginning placement phase..."

Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class W {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hIns,
        int X,
        int Y,
        int W,
        int H,
        uint F
    );
}
'@

foreach ($entry in $Launched) {
    $scr = $screens[$entry.Phys - 1]
    if (-not $scr) {
        L "No screen for Physical $($entry.Phys) during placement – skipping $($entry.Name)" "WARN"
        continue
    }

    $bounds = $scr.Bounds
    $handle = [IntPtr]::Zero

    # Retry loop – up to 20s per window
    $maxSeconds = 20
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    while ($sw.Elapsed.TotalSeconds -lt $maxSeconds -and $handle -eq [IntPtr]::Zero) {

        # 1) Try PID
        $p = Get-Process -Id $entry.PID -ErrorAction SilentlyContinue
        if ($p -and $p.MainWindowHandle -ne 0) {
            $handle = $p.MainWindowHandle
            break
        }

        # 2) Fallback to title match
        if ($entry.Title) {
            $p2 = Get-Process -ErrorAction SilentlyContinue |
                    Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like $entry.Title } |
                    Select-Object -First 1
            if ($p2) {
                $handle = $p2.MainWindowHandle
                break
            }
        }

        Start-Sleep -Milliseconds 700
    }

    if ($handle -eq [IntPtr]::Zero) {
        L "No window handle for $($entry.Name) after $maxSeconds s – skipping placement" "WARN"
        continue
    }

    # Place window
    [void][W]::SetWindowPos(
            $handle,
            [IntPtr]::Zero,
            $bounds.X,
            $bounds.Y,
            $bounds.Width,
            $bounds.Height,
            0x0040
    )

    L "PLACED $($entry.Name) → Physical $($entry.Phys) ($($scr.DeviceName))"
}

L "=== WT-HEALTHMON v5.1 COMPLETE – $($Launched.Count) items launched ==="
L "Log saved: $Log"
# Optional: open logs folder for quick inspection
explorer "C:\Logs" | Out-Null
'@ | Set-Content -Path 'C:\Scripts\WT-Healthmon\WT-Healthmon-Launcher-v5.1.ps1' -Encoding UTF8