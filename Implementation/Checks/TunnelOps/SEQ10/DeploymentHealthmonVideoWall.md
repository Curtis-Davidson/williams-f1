# WT-Healthmon 8-Screen Auto-Launcher – Production Support Guide

**Version:** v5.3.1 (December 2025) **Author:** Paul R. Davidson (Curtis-Davidson) **Rig:** WT-Healthmon (Windows 11 24H2 – 8 physical monitors) **Purpose:** 100 % deterministic, hands-free launch and placement of all seven wind-tunnel dashboards on the correct physical monitors after every reboot or manual start.

### What the script actually does (step-by-step)

| Step | Action                                                       | Result on the wall                                           |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | Kills only previous WT-Healthmon Chrome instances (by profile tag) | Clean slate – no zombie windows                              |
| 2    | Detects all 8 monitors and sorts them strictly left-to-right (X-coordinate) | Guarantees Physical #1 = leftmost monitor on the wall        |
| 3    | Launches 5 Chrome windows + 2 native EXEs                    | 7 processes started                                          |
| 4    | Every Chrome window gets its own isolated profile (C:\WT-Healthmon\ChromeProfiles\…) | Zero first-run, zero restore bubbles, zero sync, zero crash reporter |
| 5    | Chrome is forced into true kiosk + fullscreen (--kiosk --start-fullscreen) | No tabs, no address bar, no borders – looks like native app  |
| 6    | Waits for each window handle (PID tracking)                  | No race conditions                                           |
| 7    | Places every window on the correct physical monitor using Win32 SetWindowPos | Exact wall layout every time                                 |
| 8    | Second placement pass (Windows loves to move things)         | 100 % final correctness                                      |
| 9    | Writes full log to C:\Logs\WT-Healthmon-YYYYMMDD-HHMMSS.log and opens folder | Instant diagnostics if anything ever looks wrong             |

### Exact wall layout (never changes)

| Physical (wall) | Application             | Type   | URL / Path                                         |
| --------------- | ----------------------- | ------ | -------------------------------------------------- |
| 2               | CTC-1                   | Chrome | http://streamlit-wtworkingsection…/ChangeTimeClock |
| 3               | ATR                     | Chrome | http://streamlit-atf…/ATR?…                        |
| 4               | AXIS Camera Station Pro | EXE    | C:\Program Files\Axis…\AcsClient.exe               |
| 5               | Health Monitor          | EXE    | C:\Health Monitor 4.8.6 (Dev)\…Host.exe            |
| 6               | Auto_QA                 | Chrome | http://streamlit-atf…/Auto_QA                      |
| 7               | Plant Overview          | Chrome | http://10.100.3.85/…Plant_Overview_ATF.px          |
| 8               | CTC-2 (mirror of 2)     | Chrome | http://streamlit-wtworkingsection…/ChangeTimeClock |

### Auto-start after every reboot (already deployed)

Method: All Users Startup folder (survives Intune/GPO on this rig) Location: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\WT-Healthmon Auto-Start.lnk Target:

text

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\WT-Healthmon\WT-Healthmon-Start.ps1"
```

→ Runs as Administrator automatically → No user interaction required → Works even after cold boot, Windows Update, or power cycle

### Files & folders created by the script

| Path                                           | Purpose                                                  |
| ---------------------------------------------- | -------------------------------------------------------- |
| C:\Scripts\WT-Healthmon\WT-Healthmon-Start.ps1 | Master script – never edit elsewhere                     |
| C:\WT-Healthmon\ChromeProfiles\                | One sub-folder per dashboard (safe to delete on rebuild) |
| C:\Logs\WT-Healthmon-*.log                     | Full execution log – opened automatically at end         |

### Troubleshooting (99 % of issues)

| Symptom                       | Fix                                                          |
| ----------------------------- | ------------------------------------------------------------ |
| Only 1–3 windows open         | Reboot → script kills everything first → always fixed        |
| Wrong monitor placement       | Check log → Physical order is printed at start → matches wall |
| Chrome shows first-run screen | Delete C:\WT-Healthmon\ChromeProfiles folder → script recreates clean |
| Script doesn’t run at boot    | Verify shortcut is in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp and set to Run as administrator |

### Rollback / emergency stop

Delete or rename the shortcut in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp → script stops auto-running on next reboot.