# 1) Create the tool directory (exact command)

1. Exact command
   Run in an elevated PowerShell session as a third admin:

```
# Full file path to create
# Directory creation (if needed)
New-Item -Path 'C:\Scripts\ProfileMigrate' -ItemType Directory -Force | Out-Null
New-Item -Path 'C:\Scripts\ProfileMigrate\Backups' -ItemType Directory -Force | Out-Null
New-Item -Path 'C:\Scripts\ProfileMigrate\Logs' -ItemType Directory -Force | Out-Null
```

1. Expected result / test instruction
   After running, confirm the folders exist:

```
Test-Path 'C:\Scripts\ProfileMigrate'
Test-Path 'C:\Scripts\ProfileMigrate\Backups'
Test-Path 'C:\Scripts\ProfileMigrate\Logs'
```

------

# 2) audit-profile.ps1

1. Exact command to run (example):
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\audit-profile.ps1 -SID S-1-5-... -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\audit-profile.ps1`
3. Directory creation
   Already created above.
4. File creation/edit command
   Create file at the path and paste the block below.
5. Full copy-pasteable code block

```
# PURPOSE: Audit a given profile and collect metadata for journaling.
# USAGE: .\audit-profile.ps1 -SID 'S-1-5-21-...' -WhatIf
param(
  [Parameter(Mandatory=$true)][string]$SID,
  [switch]$WhatIf
)

$JournalPath = 'C:\Scripts\ProfileMigrate\Logs\audit_$((Get-Date).ToString("yyyyMMdd_HHmmss")).md'
$ProfileListKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID"

function Write-Journal($lines){
  $lines | Out-File -FilePath $JournalPath -Encoding utf8 -Append
}

# Read-only checks
Write-Host "Running audit for SID: $SID"
$whoami = whoami /user 2>$null
$profileKeyExists = Test-Path $ProfileListKey
$profileProps = $null
if ($profileKeyExists) {
  $profileProps = Get-ItemProperty -Path $ProfileListKey -ErrorAction SilentlyContinue |
    Select-Object PSChildName, ProfileImagePath, State, Flags
}
$wmiProfiles = Get-CimInstance Win32_UserProfile | Where-Object { $_.SID -eq $SID } |
  Select SID, LocalPath, Loaded, Special

$ev = wevtutil qe "Microsoft-Windows-User Profile Service/Operational" /c:100 /f:text | Select-String $SID -SimpleMatch

$lines = @()
$lines += "## Audit - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
$lines += ""
$lines += "### Basic"
$lines += "- Current interactive user: $((whoami).Trim())"
$lines += ("- ProfileList key present: {0}" -f $profileKeyExists)
if ($profileProps) {
  $lines += ("- Registry: ProfileImagePath = {0}" -f $profileProps.ProfileImagePath)
  $lines += ("- Registry: State = {0}, Flags = {1}" -f $profileProps.State, $profileProps.Flags)
}
$lines += ""
$lines += "### Win32_UserProfile"
$lines += ($wmiProfiles | Format-List | Out-String)
$lines += ""
$lines += "### EventLog snippets (filtered)"
$lines += "````"
$lines += ($ev -join "`r`n")
$lines += "````"
Write-Journal $lines

Write-Host "Audit written to $JournalPath"
if ($WhatIf) { Write-Host "WHATIF: no changes made (audit only)." }
```

1. Expected result / test instruction

- Produces `C:\Scripts\ProfileMigrate\Logs\audit_YYYYMMDD_HHMMSS.md` containing registry and event snippets.
- Verify the file contains `ProfileImagePath` and WMI `Win32_UserProfile` entries.

------

# 3) backup-profile.ps1

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\backup-profile.ps1 -SID S-1-5-... -ProfilePath 'C:\Users\olduser' -TargetBackupDir 'C:\Scripts\ProfileMigrate\Backups' -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\backup-profile.ps1`
3. Directory creation
   Uses Backups folder created earlier.
4. File creation/edit command
   Create that file and paste the code below.
5. Full copy-pasteable code block

```
# PURPOSE: Backup registry ProfileList entry + NTUSER.DAT + VSS/Robocopy snapshot of profile.
# USAGE: .\backup-profile.ps1 -SID 'S-1-5-...' -ProfilePath 'C:\Users\olduser' -TargetBackupDir 'C:\Scripts\ProfileMigrate\Backups' -WhatIf

param(
  [Parameter(Mandatory=$true)][string]$SID,
  [Parameter(Mandatory=$true)][string]$ProfilePath,
  [string]$TargetBackupDir = 'C:\Scripts\ProfileMigrate\Backups',
  [switch]$WhatIf
)

if (-not (Test-Path $ProfilePath)) { throw "ProfilePath not found: $ProfilePath" }
if (-not (Test-Path $TargetBackupDir)) { New-Item -ItemType Directory -Path $TargetBackupDir -Force | Out-Null }

$stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$regBackup = Join-Path $TargetBackupDir ("ProfileKey_${SID}_$stamp.reg")
$ntuserBackup = Join-Path $TargetBackupDir ("NTUSER_${SID}_$stamp.dat")
$robocopyLog = Join-Path $TargetBackupDir ("Robocopy_${SID}_$stamp.log")
$shadowName = "ProfileBackup_$stamp"

Write-Host "Exporting registry key for SID $SID to $regBackup"
cmd.exe /c "reg export `""HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID`" `"$regBackup`" /y" | Out-Null

# Copy NTUSER.DAT
$ntuser = Join-Path $ProfilePath 'NTUSER.DAT'
if (Test-Path $ntuser) {
  Copy-Item -Path $ntuser -Destination $ntuserBackup -Force
}

# Robocopy snapshot (preserve all attributes; use backup semantics if admin)
$robocopyCmd = "robocopy `"$ProfilePath`" `"$($TargetBackupDir)\ProfileSnapshot_$stamp`" /MIR /COPYALL /B /R:3 /W:5 /LOG:`"$robocopyLog`""
Write-Host "Robocopy: $robocopyCmd"
if (-not $WhatIf) { cmd /c $robocopyCmd } else { Write-Host "WHATIF: Robocopy skipped." }

# Write a small manifest
$manifest = @{
  SID = $SID
  ProfilePath = $ProfilePath
  RegBackup = $regBackup
  NTUSERBackup = $ntuserBackup
  RobocopyLog = $robocopyLog
  Timestamp = $stamp
}
$manifest | ConvertTo-Json | Out-File -FilePath (Join-Path $TargetBackupDir ("manifest_${SID}_$stamp.json")) -Encoding utf8

Write-Host "Backup completed (or WHATIF shown)."
```

1. Expected result / test instruction

- Confirm `ProfileKey_*.reg` and `NTUSER_*.dat` exist in Backups folder.
- Confirm Robocopy folder `ProfileSnapshot_YYYYMMDD_HHMMSS` exists (unless `-WhatIf`).

------

# 4) edit-hive.ps1

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\edit-hive.ps1 -ProfilePath 'C:\Users\olduser' -TempHiveName 'TempHiveX' -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\edit-hive.ps1`
3. Directory creation
   Not needed.
4. File creation/edit command
   Create file and paste the block below.
5. Full copy-pasteable code block

```
# PURPOSE: Load NTUSER.DAT for offline editing, allow templated search/replace for profile path or username strings.
# WARNING: Run only when the user is logged off. Use -WhatIf to simulate.
param(
  [Parameter(Mandatory=$true)][string]$ProfilePath,
  [Parameter(Mandatory=$true)][string]$TempHiveName,
  [string]$SearchFor = '',
  [string]$ReplaceWith = '',
  [switch]$WhatIf
)

$ntUser = Join-Path $ProfilePath 'NTUSER.DAT'
if (-not (Test-Path $ntUser)) { throw "NTUSER.DAT not found at $ntUser" }

$regMount = "HKU:\$TempHiveName"

Write-Host "Mounting hive $ntUser as $regMount"
# Use reg.exe to load hive under HKU\TempHiveName
cmd.exe /c "reg load `""HKLM\TempHive_$TempHiveName`" `"$ntUser`"" | Out-Null

try {
  $hiveKey = "HKLM:\TempHive_$TempHiveName"
  Write-Host "Hive mounted at $hiveKey"

  if ($SearchFor -and $ReplaceWith) {
    Write-Host "Searching for values containing '$SearchFor' and replacing with '$ReplaceWith' (in HKU\TempHive path)."
    $values = Get-ChildItem -Path $hiveKey -Recurse -ErrorAction SilentlyContinue |
      ForEach-Object {
        Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue |
          Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name |
          ForEach-Object { @{Path=$_.PSPath; Name=$_} } -ErrorAction SilentlyContinue
      }
    # NOTE: The above is a conceptual scan. For production, implement targeted subkeys only (e.g. Software\Microsoft\Office\...)
    # Example template for replacing a specific key:
    $targetKey = Join-Path $hiveKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
    if (Test-Path $targetKey) {
      $prop = Get-ItemProperty -Path $targetKey -ErrorAction SilentlyContinue
      $changed = $false
      foreach ($p in $prop.PSObject.Properties) {
        if ($p.Value -and ($p.Value -is [string]) -and $p.Value -like "*$SearchFor*") {
          $newVal = $p.Value -replace [Regex]::Escape($SearchFor), $ReplaceWith
          Write-Host "Would set $($p.Name) => $newVal"
          if (-not $WhatIf) {
            Set-ItemProperty -Path $targetKey -Name $p.Name -Value $newVal
            $changed = $true
          }
        }
      }
      if ($changed) { Write-Host "Hive edits applied." } else { Write-Host "No matched values changed." }
    } else {
      Write-Host "Target key not found for template replacement: $targetKey"
    }
  } else {
    Write-Host "No search/replace parameters given; hive is mounted for manual inspection."
  }
}
finally {
  Write-Host "Unmounting hive."
  cmd.exe /c "reg unload `""HKLM\TempHive_$TempHiveName`"" | Out-Null
}
```

1. Expected result / test instruction

- When run with `-WhatIf`, the script mounts the hive and reports the intended modifications without applying them.
- With real args, it modifies targeted registry values under the mounted hive (use logs to verify), then unmounts.

**NOTE:** The scanning/replacement logic above is intentionally conservative. For production, code specific target keys and test thoroughly.

------

# 5) repoint-profile.ps1

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\repoint-profile.ps1 -TargetSID 'S-1-5-...' -NewPath 'C:\Users\paul.davidson' -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\repoint-profile.ps1`
3. Directory creation
   Not required.
4. File creation/edit command
   Create and paste below.
5. Full copy-pasteable code block

```
# PURPOSE: Safely set ProfileImagePath for a given SID to a specific folder.
# WARNING: Run only when target profile not Loaded=True.
param(
  [Parameter(Mandatory=$true)][string]$TargetSID,
  [Parameter(Mandatory=$true)][string]$NewPath,
  [switch]$WhatIf
)

$ProfileKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$TargetSID"

if (-not (Test-Path $ProfileKey)) { throw "ProfileList key not found for $TargetSID" }

# Pre-check loaded state
$w = Get-CimInstance Win32_UserProfile | Where-Object { $_.SID -eq $TargetSID }
if ($w -and $w.Loaded) { throw "Profile $TargetSID is Loaded=True; logoff or reboot before running." }

$current = (Get-ItemProperty -Path $ProfileKey -Name ProfileImagePath -ErrorAction SilentlyContinue).ProfileImagePath
Write-Host "Current: $current"

Write-Host "Will set ProfileImagePath to $NewPath"
if ($WhatIf) { Write-Host "WHATIF: no registry change performed." ; return }

# Backup
$backup = Join-Path 'C:\Scripts\ProfileMigrate\Backups' ("ProfileKeyBackup_$TargetSID_$((Get-Date).ToString('yyyyMMdd_HHmmss')).reg")
cmd.exe /c "reg export `"$ProfileKey`" `"$backup`" /y" | Out-Null

# Set new value
Set-ItemProperty -Path $ProfileKey -Name ProfileImagePath -Value $NewPath

# Verify
$verify = (Get-ItemProperty -Path $ProfileKey -Name ProfileImagePath).ProfileImagePath
if ($verify -ne $NewPath) { throw "Verification failed: expected $NewPath, got $verify" }
Write-Host "ProfileImagePath updated and backed up to $backup"
```

1. Expected result / test instruction

- On success, the registry key now shows `ProfileImagePath = C:\Users\paul.davidson`.
- Confirm with Get-ItemProperty and WMI after logoff and logon tests.

------

# 6) acl-fix.ps1

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\acl-fix.ps1 -ProfilePath 'C:\Users\paul.davidson' -User 'FACTORY\paul.davidson' -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\acl-fix.ps1`
3. Directory creation
   Not required.
4. File creation/edit command
   Create that file and paste block below.
5. Full copy-pasteable code block

```
# PURPOSE: Targeted ACL and ownership repairs for profile. Avoid whole-profile recursive unless forced.
param(
  [Parameter(Mandatory=$true)][string]$ProfilePath,
  [Parameter(Mandatory=$true)][string]$User,                # e.g. FACTORY\paul.davidson
  [switch]$FullRecursive,                                   # if set, perform full recursive takeown/icacls (slow)
  [switch]$WhatIf
)

if (-not (Test-Path $ProfilePath)) { throw "ProfilePath not found: $ProfilePath" }

# Critical targets
$CriticalRelative = @(
  'NTUSER.DAT',
  'AppData\Roaming\Microsoft\Credentials',
  'AppData\Roaming\Microsoft\Protect',
  'AppData\Local\Microsoft\Vault',
  'AppData\Local\Packages'
)
$Critical = $CriticalRelative | ForEach-Object { Join-Path $ProfilePath $_ } | Where-Object { Test-Path $_ }

# Quick top-level owner check
Write-Host "Top-level owner:" (Get-Acl $ProfilePath).Owner

if ($FullRecursive) {
  Write-Host "Performing full recursive ownership and ACL fix (this is slow)."
  if ($WhatIf) { Write-Host "WHATIF: would run takeown/icacls recursively." ; return }
  cmd.exe /c "takeown /F `"$ProfilePath`" /A /R /D Y" | Out-Null
  cmd.exe /c "icacls `"$ProfilePath`" /grant `"$User`":(OI)(CI)F /T /C" | Out-Null
  cmd.exe /c "icacls `"$ProfilePath`" /setowner `"$User`" /T /C" | Out-Null
} else {
  # Targeted fixes
  foreach ($item in $Critical) {
    Write-Host "Fixing: $item"
    if ($WhatIf) { Write-Host "WHATIF: would set owner and grant for $item" ; continue }
    if ((Get-Item $item).PSIsContainer) {
      cmd.exe /c "icacls `"$item`" /setowner `"$User`" /T /C" | Out-Null
      cmd.exe /c "icacls `"$item`" /grant `"$User`":(OI)(CI)F /T /C" | Out-Null
    } else {
      cmd.exe /c "icacls `"$item`" /setowner `"$User`" /C" | Out-Null
      cmd.exe /c "icacls `"$item`" /grant `"$User`":F /C" | Out-Null
    }
  }
  # Ensure root owner is correct (non recursive)
  if ($WhatIf) { Write-Host "WHATIF: would set owner on $ProfilePath" } else {
    cmd.exe /c "icacls `"$ProfilePath`" /setowner `"$User`" /C" | Out-Null
  }
}

Write-Host "ACL fixes complete (or WHATIF shown)."
```

1. Expected result / test instruction

- Verify owners on `NTUSER.DAT` and `AppData\Local\Packages` are the expected user; test via:

```
(Get-Acl 'C:\Users\paul.davidson\ntuser.dat').Owner
(Get-Acl 'C:\Users\paul.davidson\AppData\Local\Packages').Owner
```

------

# 7) verify-profile.ps1

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\verify-profile.ps1 -SID 'S-1-5-...' -ExpectedPath 'C:\Users\paul.davidson'`
2. Full file path
   `C:\Scripts\ProfileMigrate\verify-profile.ps1`
3. Directory creation
   Not required.
4. File creation/edit command
   Create and paste.
5. Full copy-pasteable code block

```
# PURPOSE: Verify final state after migration. Run as the target user after logon for full validation.
param(
  [Parameter(Mandatory=$true)][string]$SID,
  [Parameter(Mandatory=$true)][string]$ExpectedPath
)

Write-Host "Verification for SID $SID"

$who = whoami
Write-Host "whoami: $who"

$envProfile = $env:USERPROFILE
Write-Host "USERPROFILE: $envProfile"

$wmi = Get-CimInstance Win32_UserProfile -Filter "SID='$SID'" | Select SID,LocalPath,Loaded,Special
Write-Host "Win32_UserProfile: $($wmi | Out-String)"

# quick critical file checks
$checks = @(
  Join-Path $ExpectedPath 'ntuser.dat',
  Join-Path $ExpectedPath 'AppData\Local\Packages'
)
foreach ($c in $checks) {
  if (Test-Path $c) { Write-Host "$c exists; owner: $((Get-Acl $c).Owner)" }
  else { Write-Warning "$c missing" }
}

# quick app sanity checks (non exhaustive)
Write-Host "Quick app checks: OneDrive status (if present) and Outlook roaming values not validated automatically."
```

1. Expected result / test instruction

- Run this while logged in as the target user. Expected to show `USERPROFILE` and Win32_UserProfile LocalPath matching `C:\Users\paul.davidson` and `Loaded=True`.

------

# 8) journal.ps1 (append single Markdown entry)

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\journal.ps1 -Message "Repointed SID x -> C:\Users\y" `
2. Full file path
   `C:\Scripts\ProfileMigrate\journal.ps1`
3. Directory creation
   Uses Logs folder.
4. File creation/edit command
   Create file and paste below.
5. Full copy-pasteable code block

```
# PURPOSE: Append a markdown entry into the ProfileDiagnosticsJournal
param(
  [Parameter(Mandatory=$true)][string]$Message
)
$Journal = 'C:\Scripts\ProfileMigrate\Logs\ProfileDiagnosticsJournal.md'
if (-not (Test-Path $Journal)) { New-Item -Path $Journal -ItemType File -Force | Out-Null }

$entry = @()
$entry += "## [$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
$entry += ""
$entry += $Message
$entry += ""
$entry += "---"
Add-Content -Path $Journal -Value ($entry -join "`r`n")
Write-Host "Journal appended to $Journal"
```

1. Expected result / test instruction

- Running `.\journal.ps1 -Message "test"` appends a small markdown entry to `ProfileDiagnosticsJournal.md`.

------

# 9) orchestrator.ps1 — the controller

1. Exact command example:
   `PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\orchestrator.ps1 -SourceProfile 'C:\Users\olduser' -SourceSID 'S-1-5-...' -TargetSID 'S-1-5-...' -TargetPath 'C:\Users\newuser' -WhatIf`
2. Full file path
   `C:\Scripts\ProfileMigrate\orchestrator.ps1`
3. Directory creation
   Already created.
4. File creation/edit command
   Create file and paste below.
5. Full copy-pasteable code block

```
# PURPOSE: High-level orchestration for a single profile migration.
# WARNING: THIS SCRIPT IS A CONTROLLER. Always run with -WhatIf for first runs.
param(
  [Parameter(Mandatory=$true)][string]$SourceProfile,
  [Parameter(Mandatory=$true)][string]$SourceSID,
  [Parameter(Mandatory=$true)][string]$TargetSID,
  [Parameter(Mandatory=$true)][string]$TargetPath,
  [switch]$WhatIf,
  [switch]$Confirm
)

$base = 'C:\Scripts\ProfileMigrate'
$audit = Join-Path $base 'audit-profile.ps1'
$backup = Join-Path $base 'backup-profile.ps1'
$edithive = Join-Path $base 'edit-hive.ps1'
$repoint = Join-Path $base 'repoint-profile.ps1'
$acl = Join-Path $base 'acl-fix.ps1'
$verify = Join-Path $base 'verify-profile.ps1'
$journal = Join-Path $base 'journal.ps1'

Write-Host "Orchestrator starting. Source: $SourceProfile ($SourceSID) -> Target: $TargetPath ($TargetSID)"
if ($WhatIf) { Write-Host "Running in WHATIF mode (no destructive changes will be applied)." }

# Audit
& $audit -SID $SourceSID -WhatIf:$WhatIf

# Backup
& $backup -SID $SourceSID -ProfilePath $SourceProfile -TargetBackupDir (Join-Path $base 'Backups') -WhatIf:$WhatIf

# Edit hive (example: replace 'C:\Users\olduser' to target occurrences)
& $edithive -ProfilePath $SourceProfile -TempHiveName "Migrate_$((Get-Date).ToString('yyyyMMdd_HHmmss'))" -SearchFor (Split-Path $SourceProfile -Leaf) -ReplaceWith (Split-Path $TargetPath -Leaf) -WhatIf:$WhatIf

# Repoint registry (do not run if loaded)
& $repoint -TargetSID $TargetSID -NewPath $TargetPath -WhatIf:$WhatIf

# ACL fixes (targeted)
& $acl -ProfilePath $TargetPath -User "FACTORY\$((Split-Path $TargetPath -Leaf))" -WhatIf:$WhatIf

# Journal action
& $journal -Message "Orchestrator run for SourceSID $SourceSID -> TargetSID $TargetSID (WhatIf=$WhatIf)"

Write-Host "Orchestrator complete. Review logs in C:\Scripts\ProfileMigrate\Logs. If you ran WHATIF remove the flag to apply changes."
```

1. Expected result / test instruction

- Run with `-WhatIf` first; examine logs and `ProfileDiagnosticsJournal.md`.
- After confident dry runs and tests on VMs, re-run without `-WhatIf`.
- After running, reboot and run `verify-profile.ps1` as the target user.

------

# 10) Final checklist before running anything on a production machine

-  Run the whole suite on a VM clone and test Outlook, OneDrive, Chrome, Edge, Teams, and any in-house apps.
-  Confirm adequate disk space for backups and snapshots (Robocopy target).
-  Ensure a **third admin** is available to run the script while target user is logged off.
-  Confirm a restore plan (how to re-import `.reg` files and restore profile snapshot). Practice it once.
-  Confirm acceptable data loss for DPAPI-bound secrets; plan reauthentication flow for users.
-  Add the orchestrator to your CI/deploy pipeline only after 3 successful manual runs.

------

# 11) Notes, caveats and improvement ideas

- The `edit-hive` script above is intentionally **templated** — editing arbitrary hives must be targeted. Do not perform global blind search/replace inside a hive. Implement safe filters and only change known keys (Explorer shell folders, certain Office keys, application-specific Registry locations). Add logging for every changed value.
- Consider capturing VSS snapshots (via `diskshadow` or VSS APIs) if you want a consistent point-in-time backup while the machine is online.
- For DPAPI migration of credentials you need domain DPAPI escrow or backup of machine keys; otherwise, expect to re-provision credentials.
- Add a Slack/Teams webhook to the `journal.ps1` to alert ops automatically.
- Add a `-DryRunToFile` option to save the exact list of commands that would be executed for audit.

------

# 12) Quick example: Dry run invocation

```
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\ProfileMigrate\orchestrator.ps1 `
  -SourceProfile 'C:\Users\adminpdavidson' `
  -SourceSID 'S-1-5-21-........138190' `
  -TargetSID 'S-1-5-21-........138187' `
  -TargetPath 'C:\Users\paul.davidson' `
  -WhatIf
```

Examine `C:\Scripts\ProfileMigrate\Logs\*` and `ProfileDiagnosticsJournal.md`. If everything looks correct in the dry run and you’ve validated backups, re-run without `-WhatIf`.