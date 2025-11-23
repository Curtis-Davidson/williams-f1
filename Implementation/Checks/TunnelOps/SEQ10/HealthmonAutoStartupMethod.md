### STEP 1 – Save script exactly here (never changes)

text

```
C:\Scripts\WT-Healthmon\WT-Healthmon-Start.ps1
```

### STEP 2 – Create the bulletproof launcher shortcut

1. Right-click Desktop → New → Shortcut

2. Location (paste exactly):

   text

   ```
   powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\WT-Healthmon\WT-Healthmon-Start.ps1"
   ```

3. Name it: WT-Healthmon Auto-Start

4. Right-click shortcut → Properties → Advanced → **Run as administrator** → OK → OK

### STEP 3 – Drop it in the ONE place that survives Intune, GPO, reboot, everything

**Copy the shortcut** into:

text

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
```

That folder = **All Users Startup** → runs **every reboot**, **every user**, **even before login** if you want (but normal login is fine).

### STEP 4 – (Optional) Nuclear option – Task Scheduler (never dies)

If your rig is ultra-locked and Startup folder is blocked:

1. Run → taskschd.msc (as admin)

2. Create Task → General tab:

    - Name: WT-Healthmon Auto-Start
    - **Run whether user is logged on or not**
    - **Run with highest privileges**
    - Hidden

3. Triggers → New → **At startup**

4. Actions → New → Program: powershell.exe Arguments:

   text

   ```
   -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\WT-Healthmon\WT-Healthmon-Start.ps1"
   ```

5. Conditions → uncheck “Start only if on AC power”

6. OK → enter admin password when prompted