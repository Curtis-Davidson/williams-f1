Windows cannot queue the **Azure AD join background task** because the **Task Scheduler** service (or one of its dependencies) is stopped, disabled, or corrupted.

------

### Step-by-step fix

Run these in **elevated PowerShell (Run as Administrator)**:

#### 1. Verify Task Scheduler service state

```
Get-Service Schedule
```

If you see:

```
Status  : Stopped
StartType : Disabled
```

that’s the problem.

#### 2. Re-enable and start the service

```
Set-Service Schedule -StartupType Automatic
Start-Service Schedule
```

#### 3. Confirm it’s running

```
Get-Service Schedule
```

You should now see:

```
Status   : Running
```

#### 4. Retry the join

```
dsregcmd /join
```

Give it about 20–30 seconds to complete.
Expected outcome:

```
+-------------------------------------------------------------------+
| Device Join Type: Azure AD Joined                                 |
| DeviceAuthStatus : SUCCESS                                        |
+-------------------------------------------------------------------+
```

#### 5. If it still fails:

Check the service dependencies haven’t been broken:

```
sc qc Schedule
```

Make sure both **RPCSS** and **EventLog** are listed as dependencies and are running:

```
Get-Service rpcss,eventlog
```

------

### Optional: Clean scheduled join task remnants

If you’ve run `/join` several times before, sometimes the old scheduled task lingers:

```
schtasks /Delete /TN "Microsoft\Windows\Workplace Join\Automatic-Device-Join" /F
```

Then re-run:

```
dsregcmd /join
```

------

### 6. Verify successful join

```
dsregcmd /status | findstr /i "AzureAdJoined DeviceAuthStatus"
```

You want:

```
AzureAdJoined : YES
DeviceAuthStatus : SUCCESS
```

------

Once it rejoins successfully, reboot once more and re-launch Outlook.
If Outlook still reports the TPM error after a successful join, we’ll flush the Hello container and M365 tokens one more time — but the scheduler fix usually clears it.

Would you like me to build you a small `Fix-AADJoin.ps1` script that performs all these checks and repairs automatically (with output logging)?

###### ChatGPT said:

Thought for 13s

Got it. The `/join` failed because Task Scheduler wasn’t available. Here’s a clean, **one-shot fix** that checks/repairs the services, clears the stale Workplace Join task, and re-joins AAD — with logging and clear output.

# Fix AAD Join after 0x80041326 (Task Scheduler)

1. Exact command
2. Full file path
3. Directory creation
4. File creation
5. Full code block (copy/paste)
6. Commented purpose above block
7. Expected result / test







That’s an excellent and logical question — and here’s the straight answer.

No, simply **re-enabling BitLocker alone will not fix the “Device TPM problem”** you’re seeing in Outlook and M365.
Let me explain *why*, and then tell you what BitLocker *will* help with.

------

## 1. What’s actually broken

The **TPM error in your screenshot** is not a BitLocker encryption issue — it’s an **Azure AD / Windows Hello key trust problem**.

- BitLocker uses TPM for **disk encryption keys**.
- Azure AD / Outlook / Teams use TPM for **authentication keys** (the device’s identity key + your Hello container).

When you cleared or changed the TPM ownership, BitLocker’s protector and Windows Hello’s key containers became desynchronised.
Re-enabling BitLocker only repairs the drive protector; it doesn’t regenerate the user’s TPM-sealed identity keys — those belong to Azure AD’s device registration (PRT and Hello keys).

That’s why even after you confirm:

```
Get-Tpm
TpmOwned : True
```

…you still get the TPM dialog in Outlook — because Azure AD is referencing an *old* device registration tied to the *previous* TPM hierarchy.

------

## 2. What re-enabling BitLocker actually does

When you run:

```
manage-bde -protectors -enable C:
```

BitLocker simply re-binds the drive encryption key to the current TPM owner.
That fixes **boot-time recovery prompts** and ensures your drive encryption works again — but it has zero effect on Azure AD or Office tokens.

------

## 3. What does fix the Outlook TPM prompt

You need to re-establish the device-to-Azure AD trust using a new TPM key set:

```
dsregcmd /leave
shutdown /r /t 0
# After reboot:
dsregcmd /join
```

That operation forces Windows to reissue a new **device certificate + TPM binding**.
Once that’s done, re-signing into Outlook/Teams will generate new tokens bound to the refreshed TPM hierarchy — error gone.

------

## 4. Recommended sequence (safe)

If you just want to ensure BitLocker is back on **and** clean up the TPM issue:

```
# 1. Ensure TPM is ready
Get-Tpm | fl TpmReady,TpmOwned

# 2. Disable then enable protectors (BitLocker refresh)
manage-bde -protectors -disable C: -RebootCount 1
shutdown /r /t 0   # reboot once
manage-bde -protectors -enable C:

# 3. Refresh AAD trust (fix TPM dialog)
dsregcmd /leave
shutdown /r /t 0
dsregcmd /join
```

------

## 5. Short version

- **Enable BitLocker** → fixes drive encryption.
- **Re-join AAD (`dsregcmd /leave` + `/join`)** → fixes TPM auth for Outlook.
- Both together = full repair.

------

If you’d like, I can give you a *single verified PowerShell script* that performs both actions in correct sequence with logging and rollback (`Fix-TPM-Trust.ps1`).
Would you like me to generate that next?





Good—this behaviour makes sense. You effectively “fixed it in the background” even though the immediate `dsregcmd /join` output looked like a fail.

What happened (plain English):

- We rebuilt the **Workplace Join** scheduled task.
- `dsregcmd /join` sometimes returns early with *“Unable to read Join Task output data”* or 0x80070002 while the **task** still runs and completes a few seconds later (or on the next logon).
- When you opened **Settings → Work or school** it nudged the same plumbing, and the device completed the join. Hence Outlook/Teams felt happier and your symptoms cleared.

Quick verification & tidy-up (run elevated PowerShell):

1. Confirm device state

```
dsregcmd /status | findstr /i "AzureAdJoined DeviceAuthStatus WorkplaceJoined TenantName"
```

Expected:

```
AzureAdJoined : YES
DeviceAuthStatus : SUCCESS
```

1. Confirm the join task exists and is healthy

```
schtasks /Query /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
schtasks /Query /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join Hourly"
```

Expected: both present, **Ready** or **Running**.

1. Refresh your PRT and sync time (pre-empt drift)

```
w32tm /resync
dsregcmd /refreshprt
```

1. Re-enable BitLocker protectors if you disabled them earlier

```
manage-bde -protectors -enable C:
```

Why your earlier script “failed” but worked anyway:

- `dsregcmd` hands the action to the **Task Scheduler**. If the task is (re)created and `Schedule` service is running, Windows often completes the join **after** your shell returns. That’s why you saw `AzureAdJoined : NO` immediately, but state flipped shortly after.

If it ever happens again (join says NO after a minute), do this minimal set:

```
# Rebuild task and kick join
schtasks /Delete /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join" /F 2>nul
schtasks /Create /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join" /SC ONLOGON /RL HIGHEST /RU SYSTEM /TR "%SystemRoot%\System32\dsregcmd.exe /join"
dsregcmd /leave
dsregcmd /join
Start-Sleep 15
dsregcmd /status
```

If `AzureAdJoined` still reads **NO**, open:

```
start ms-settings:workplace
```

Click **Connect** → **Join this device to Azure Active Directory**, sign in, then reboot once. That forces the same trust path interactively.

Bottom line: you’re good. The transient errors were just the join task racing your console output.























Right—two things are happening:

1. `dsregcmd /join` is failing with **0x80070002** = “file not found”. In this context it means **the Automatic-Device-Join scheduled task or its wiring is missing/corrupt**, so `dsregcmd` can’t create/locate the join task it uses.
2. Outlook/Teams still work because their **user tokens (WAM)** are intact. **Device join** is separate. With the device *not* AAD-joined your **profile photo and some SSO niceties won’t roam**, and you’ll see odd prompts.

Let’s fix the join cleanly and put the task back.

# Rule-6 Precision Fix — Recreate Device-Join task and re-join AAD

1. Exact command

```
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass
```

1. Full file path to work area

```
C:\Scripts\AADJoinFix\
```

1. Create directory (if needed)

```
New-Item -ItemType Directory -Force -Path C:\Scripts\AADJoinFix | Out-Null
```

1. Create the repair script file

```
notepad C:\Scripts\AADJoinFix\Fix-DeviceJoin.ps1
```

1. Paste this full code block and save

```
# Purpose: Rebuild the Workplace Join task and force an Azure AD device join
# Expected: AzureAdJoined:YES after run; profile photo/SSO normal after sign-out/in

Start-Transcript -Path C:\Scripts\AADJoinFix\Fix-DeviceJoin.log -Append | Out-Null

Write-Host "=== Recreating Workplace Join task and forcing dsreg join ==="

# Ensure Task Scheduler service is healthy
$svc = Get-Service Schedule -ErrorAction Stop
if ($svc.StartType -ne 'Automatic') { Set-Service Schedule -StartupType Automatic }
if ($svc.Status -ne 'Running')      { Start-Service Schedule }

# Remove any half-baked copy of the task
$taskName  = "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
schtasks /Query /TN "$taskName" > $null 2>&1
if ($LASTEXITCODE -eq 0) { schtasks /Delete /TN "$taskName" /F | Out-Null }

# Recreate the task (SYSTEM, highest, runs on logon and hourly)
schtasks /Create /TN "$taskName" /SC ONLOGON /RL HIGHEST /RU SYSTEM `
  /TR "%SystemRoot%\System32\dsregcmd.exe /join" | Out-Null
schtasks /Create /TN "$taskName Hourly" /SC HOURLY /MO 1 /RL HIGHEST /RU SYSTEM `
  /TR "%SystemRoot%\System32\dsregcmd.exe /join" | Out-Null

# Kick a join now
Write-Host "Running dsregcmd /leave (to clear stale) ..."
dsregcmd /leave | Out-Null

Write-Host "Running dsregcmd /join ..."
dsregcmd /join

Start-Sleep -Seconds 8

# Verify
$status = dsregcmd /status
($status | Select-String -SimpleMatch "AzureAdJoined") | ForEach-Object { Write-Host $_ }
($status | Select-String -SimpleMatch "DeviceAuthStatus") | ForEach-Object { Write-Host $_ }

Stop-Transcript | Out-Null
```

1. Run the script

```
powershell -ExecutionPolicy Bypass -File C:\Scripts\AADJoinFix\Fix-DeviceJoin.ps1
```

1. Expected result / test

- You should see `AzureAdJoined : YES` and `DeviceAuthStatus : SUCCESS`.

- If it still says NO, use the **interactive** path once to seed trust:

  ```
  start ms-settings:workplace
  ```

  Click **Connect** → **Join this device to Azure Active Directory**, sign in with your WF1 account (needs local admin rights). Reboot once.

------

## Why your script showed “Failed to get Join Task. 0x80070002”

You deleted the task (good) but Windows didn’t recreate it, so `dsregcmd` couldn’t “get” it. The block above **rebuilds the task explicitly** and forces the join.

## Why Outlook/Teams work while `AzureAdJoined` is NO

They ride on **user WAM tokens** (and can work on AAD-*registered* machines). Device join gives you **device trust** (PRT, profile photo sync on logon UI, smoother SSO, conditional access compliance). That’s why your **photo disappeared** and prompts got weird.

------

## Optional tidy-ups after a successful join

Run these only **after** `AzureAdJoined:YES`:

```
# Refresh Primary Refresh Token
dsregcmd /refreshprt

# Re-enable BitLocker protectors if you disabled them earlier
manage-bde -protectors -enable C:
```

If anything in the output still blocks the join, paste the **AzureAdJoined / DeviceAuthStatus** lines from `dsregcmd /status` and we’ll pivot.

##### 