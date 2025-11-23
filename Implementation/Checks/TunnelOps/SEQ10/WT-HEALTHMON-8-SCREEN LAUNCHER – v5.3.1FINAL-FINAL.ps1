<#
WT-HEALTHMON 8-SCREEN LAUNCHER – v5.3.1 FINAL-FINAL (DEC 2025)
Author  : Paul R. Davidson (Curtis-Davidson)
Purpose : 7 dashboards/apps → Physical 2..8, true fullscreen, zero bubbles, zero drift.
          WT-specific Chrome processes only, no interference with user Chrome.
#>

# ============================================================
# 1. CLEAN UP ONLY OLD WT-HEALTHMON CHROME INSTANCES
# ============================================================
$WTProfileTag = "WTHealthmonProfile"

try {
    $oldWtChrome = Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -like "*$WTProfileTag*" }

    foreach ($p in $oldWtChrome) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
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

L "=== WT-HEALTHMON v5.3.1 LAUNCH STARTED (FINAL-FINAL) ==="

# ============================================================
# 3. SCREEN DISCOVERY – LEFT→RIGHT WALL ORDER
# ============================================================
Add-Type -AssemblyName System.Windows.Forms

$screens = [System.Windows.Forms.Screen]::AllScreens | Sort-Object { $_.Bounds.X }

L "Detected $($screens.Count) monitors (physical wall order):"
for ($i = 0; $i -lt $screens.Count; $i++) {
    L (" Physical #{0} → {1} Bounds={2}" -f ($i+1), $screens[$i].DeviceName, $screens[$i].Bounds)
}

# ============================================================
# 4. CHROME PATH
# ============================================================
$ChromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $ChromeExe)) {
    L "Chrome not found at $ChromeExe – aborting." "ERROR"
    exit 1
}
L "Chrome path: $ChromeExe"

# ============================================================
# 5. APPLICATION MAP (PHYSICAL 2–8)
# ============================================================
$Apps = @(
    [pscustomobject]@{Name="CTC-1";  Phys=2; Type="Chrome"; Url="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          ProfileName="CTC-1"}
    [pscustomobject]@{Name="ATR";    Phys=3; Type="Chrome"; Url="http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=";             ProfileName="ATR"}
    [pscustomobject]@{Name="AXIS";   Phys=4; Type="Exe";    Exe="C:\Program Files\Axis Communications\AXIS Camera Station\Client Latest\AcsClient.exe"; ProfileName=$null}
    [pscustomobject]@{Name="Health"; Phys=5; Type="Exe";    Exe="C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe";     ProfileName=$null}
    [pscustomobject]@{Name="AutoQA"; Phys=6; Type="Chrome"; Url="http://streamlit-atf.dev-aero.factory.wf1/Auto_QA";                               ProfileName="AutoQA"}
    [pscustomobject]@{Name="Plant";  Phys=7; Type="Chrome"; Url="http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView"; ProfileName="Plant"}
    [pscustomobject]@{Name="CTC-2";  Phys=8; Type="Chrome"; Url="http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock";          ProfileName="CTC-2"}
)

# ============================================================
# 6. LAUNCH WITH PER-APP PROFILE + FULL KIOSK
# ============================================================
$ProfileRoot = "C:\WT-Healthmon\ChromeProfiles"
New-Item -ItemType Directory -Path $ProfileRoot -Force -ErrorAction SilentlyContinue | Out-Null

$ChromeFlags = @(
    "--new-window"
    "--kiosk"                    # true kiosk (no tabs, no address bar)
    "--start-fullscreen"         # belt-and-braces
    "--no-first-run"
    "--disable-fre"
    "--disable-sync"
    "--no-default-browser-check"
    "--disable-features=ChromeWhatsNewUI,TranslateUI,WelcomeUI,SigninPromo,StandaloneProfilePicker"
    "--disable-crash-reporter"   # no crash bubbles
)

$Launched = @()

foreach ($a in $Apps) {
    $scr = $screens[$a.Phys - 1]
    if (-not $scr) {
        L "Physical $($a.Phys) missing – skipping $($a.Name)" "WARN"
        continue
    }

    L "Launching $($a.Name) → Physical $($a.Phys)"

    $proc = $null

    if ($a.Type -eq "Chrome") {
        # include WT tag in profile path so clean-up can find them
        $profile = Join-Path $ProfileRoot ("{0}-{1}" -f $WTProfileTag, $a.ProfileName)
        New-Item -ItemType Directory -Path $profile -Force -ErrorAction SilentlyContinue | Out-Null

        $args = $ChromeFlags + "--user-data-dir=$profile" + $a.Url

        $proc = Start-Process -FilePath $ChromeExe -ArgumentList $args -PassThru
        L " Chrome launched (PID $($proc.Id)) → $profile"
    }
    else {
        if (Test-Path $a.Exe) {
            $proc = Start-Process -FilePath $a.Exe -PassThru
            L " EXE launched (PID $($proc.Id))"
        }
        else {
            L " EXE missing: $($a.Exe)" "ERROR"
            continue
        }
    }

    if ($proc) {
        $Launched += [pscustomobject]@{
            Name = $a.Name
            Phys = $a.Phys
            Pid  = $proc.Id
        }
    }

    Start-Sleep -Seconds 4
}

# ============================================================
# 7. WIN32 + DOUBLE PASS PLACEMENT
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

function Place([IntPtr]$h, $screen) {
    if ($h -eq [IntPtr]::Zero -or -not $screen) { return }
    [W]::SetWindowPos(
            $h,
            [IntPtr]::Zero,
            $screen.Bounds.X,
            $screen.Bounds.Y,
            $screen.Bounds.Width,
            $screen.Bounds.Height,
            0x0040
    ) | Out-Null
}

Start-Sleep -Seconds 15
L "First placement pass..."

foreach ($l in $Launched) {
    $p = Get-Process -Id $l.Pid -ErrorAction SilentlyContinue
    if ($p -and $p.MainWindowHandle -ne [IntPtr]::Zero) {
        Place $p.MainWindowHandle $screens[$l.Phys - 1]
        L "PLACED $($l.Name) → Physical $($l.Phys)"
    }
    else {
        L "No live window for $($l.Name) on first pass" "WARN"
    }
}

Start-Sleep -Seconds 10
L "Second (final) placement pass..."

foreach ($l in $Launched) {
    $p = Get-Process -Id $l.Pid -ErrorAction SilentlyContinue
    if ($p -and $p.MainWindowHandle -ne [IntPtr]::Zero) {
        Place $p.MainWindowHandle $screens[$l.Phys - 1]
    }
}

L "=== WT-HEALTHMON v5.3.1 DONE – $($Launched.Count)/$($Apps.Count) LAUNCHED & PLACED (SEE LOG: $Log) ===" "INFO"
explorer "C:\Logs"