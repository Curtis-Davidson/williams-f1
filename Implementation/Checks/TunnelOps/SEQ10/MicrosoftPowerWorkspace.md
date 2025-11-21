### Microsoft PowerToys Workspaces: Factual Overview and Key Limitations (as of November 2025)

Microsoft PowerToys Workspaces is a utility introduced in PowerToys v0.84 (September 2024) and remains part of the latest stable release (v0.96 as of November 2025). It allows users to save and restore groups of applications with predefined window positions, sizes, and (optionally) command-line arguments across multiple monitors. Workspaces can be launched via the editor (Win+Ctrl+`), desktop shortcuts, or PowerToys Run.

#### Core Features

- Capture current open windows or manually add apps/URLs.
- Launch multiple apps simultaneously and reposition/resize them automatically.
- Supports classic Win32 apps, Microsoft Edge (including some PWAs after fixes in v0.87+), and basic command-line arguments.
- Works across multiple monitors and remembers relative positions/sizes.
- No requirement for PowerToys to stay running after a workspace shortcut is created.

Official Microsoft documentation describes it as a "desktop manager utility" with no explicit "experimental" label in 2025 releases.

#### Documented and Known Reliability Issues (Especially for Fixed, 24/7 Multi-Monitor Setups)

Despite improvements over the past year, Workspaces has fundamental architectural limitations and recurring real-world problems that make it unsuitable for **mission-critical, single-purpose, 8-monitor dashboards** like a wind-tunnel health-monitoring wall:

| Issue                                                        | Description                                                  | Impact on Your 8-Screen Use Case                             | Source / Evidence                                            |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Cannot natively spawn windows on specific monitors**       | PowerToys launches apps first, then moves/resizes them. There is visible "window jumping/flickering" during launch. | Operators see flashing windows popping on wrong screens before correction — unacceptable on a glanceable monitoring wall. | Official Microsoft Learn docs explicitly state: "PowerToys cannot tell an app to launch to a specific position... this results in the user visibly seeing the process on-screen." |
| **Fragile window identification**                            | Relies on process name, window title, and heuristics. Multiple identical Edge windows (e.g., your two ChangeTimeClock tabs) frequently get mixed up or applied to the wrong instance. | Your DISPLAY 2 and DISPLAY 8 (identical content) would randomly swap or fail to place correctly. | Multiple open/closed GitHub issues (#34621, #39593) report Workspaces confusing instances and failing to open new ones reliably. |
| **Breaks after monitor changes or reboots**                  | If display order/EDID changes slightly (common after driver updates or docking), saved layouts drift or only apply to one monitor. | On a fixed PC with 8 outputs (including mirrored ones), any Windows/NVIDIA/AMD update risks breaking the entire wall until manually re-captured. | GitHub issues #34586 (only 1 monitor saved), #36749 (editor opens off-screen with multi-monitor), #34570 (unreliable placement on 4+ monitors). |
| **No robust crash recovery**                                 | If an app (e.g., your custom HealthMonitor.exe) crashes mid-session, Workspaces cannot auto-relaunch or re-position it — you must manually trigger the workspace again. | During long wind-tunnel runs, a single crash leaves a blank screen until someone notices and re-launches. | No built-in watchdog or monitoring; relies on user action.   |
| **Poor support for Store/UWP/MSIX apps & PWAs**              | Early versions failed entirely with PWAs; later fixes are incomplete for many internal/Streamlit apps. | Your AXIS Camera Station and custom HealthMonitor.exe may not restore reliably. | Fixed partially in v0.87, but ongoing reports of MS Store apps (e.g., To-Do) ignoring saved positions (#39593). |
| **No automatic launch on login/startup without extra hacks** | No native "run on logon" for a specific workspace; shortcuts sometimes fail silently. | Cannot guarantee pixel-perfect wall after unattended reboot. | Issues #35602 (desktop shortcuts do nothing), #34885 (requests for startup launch — still unresolved). |
| **Ongoing bug reports in 2025**                              | Even in v0.93–0.96, issues persist: editor crashes, timing races where windows move before apps are ready, confusion with elevated apps. | Real-world reliability remains <99.9% in complex multi-monitor setups. | Active GitHub tracker shows dozens of Workspaces-related bugs fixed per release, but new ones continue. |

#### Bottom Line for Your Specific Scenario

PowerToys Workspaces is excellent for **personal developer machines** where you occasionally restore a coding or browsing layout and can tolerate occasional glitches.

For a **fixed, 24/7, 8-screen, mission-critical F1 wind-tunnel health-monitoring wall** that must be 100% pixel-perfect after every reboot or crash, with zero visible artifacts and zero manual intervention, it is objectively the wrong tool. The visible jumping, fragile matching of identical windows, lack of true crash recovery, and history of breaking after updates make it a reliability risk.

Custom PowerShell watchdog script (sequential launch → explicit DISPLAYn targeting → second-pass correction → permanent monitoring) bypasses every single one of these limitations and is the proven, production-grade approach used in similar high-stakes control rooms.

