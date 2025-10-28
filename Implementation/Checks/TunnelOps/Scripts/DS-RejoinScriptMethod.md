That screenshot is helpful — this one’s a **token-integrity mismatch** rather than a TPM hardware issue now.

### What’s actually happening

When you ran

```
dsregcmd /leave
```

Windows **deregistered the device identity with Azure AD** (that’s expected).
However, **your cached user tokens (WAM / Web Account Manager)** in the profile were **not deleted**, so Outlook and Teams continue working on their existing access tokens — but the background **web sign-in host** (the one that pops that 657rx box) still tries to use the **old, now-invalid device credential** to fetch your photo, graph presence, or M365 web shell session.

That mismatch (old cached credential + new non-joined device) →
**Code 2150171662 (657rx)**
**Message: “The credential is invalid. Unexpected sub status (6008).”**

So even though your apps *seem fine*, that dialog means the AAD Web Account Manager is still trying to use a stale Primary Refresh Token (PRT) tied to the previous join record.

------

### Quick clean-up procedure

Run these in **elevated PowerShell** to wipe stale AAD tokens and force a fresh issue:

```
# 1. Remove cached AAD / WAM tokens
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\TokenBroker" -ErrorAction SilentlyContinue

# 2. Remove Office identity caches
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\Office\16.0\Identity" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\Office\16.0\Licensing" -ErrorAction SilentlyContinue

# 3. Clear any saved credentials
cmd /c 'for /f "tokens=2,* delims=: " %a in (''cmdkey /list ^| findstr /i "Target"'') do @cmdkey /delete:%b'

# 4. Optional but safest: sign out of Teams and Outlook completely
taskkill /IM outlook.exe /IM teams.exe /F

# 5. Reboot once
shutdown /r /t 0
```

When you log back in, Windows will obtain a *new* device-independent PRT on your first Teams/Outlook sign-in, and that **657rx** error will stop appearing.

------

### If you want to restore full device trust again

You can re-establish the join (and TPM binding) any time:

```
dsregcmd /join
```

Then confirm:

```
dsregcmd /status | findstr /i "AzureAdJoined DeviceAuthStatus"
```

Expect:

```
AzureAdJoined : YES
DeviceAuthStatus : SUCCESS
```

------

### Summary

- **657rx** = invalid or orphaned Azure AD credential, not hardware.
- Cleared by wiping AAD Broker + TokenBroker caches and letting sign-in reissue a clean PRT.
- Your clone works because the local tokens still validate for Exchange Online, but the background SSO host complains until refreshed.

Once you reboot and sign in again, that popup will disappear and everything—including the profile photo—should sync normally.

##### You said:

![Uploaded image](https://chatgpt.com/backend-api/estuary/content?id=file_00000000b8dc61f4a96bd3be0e4a2014&ts=489343&p=fs&cid=1&sig=416197f31e0b28cbd237b30081ba5a7c423600370d6f6124078866678b6d3863&v=0)

after running PS C:\windows\system32> dsregcmd /join Failed to schedule Join Task. Error: 0x80041326 PS C:\windows\system32> ran this and rebooted, # 1. Remove cached AAD / WAM tokens Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" -ErrorAction SilentlyContinue Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\TokenBroker" -ErrorAction SilentlyContinue # 2. Remove Office identity caches Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\Office\16.0\Identity" -ErrorAction SilentlyContinue Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\Office\16.0\Licensing" -ErrorAction SilentlyContinue # 3. Clear any saved credentials cmd /c 'for /f "tokens=2,* delims=: " %a in (''cmdkey /list ^| findstr /i "Target"'') do @cmdkey /delete:%b' # 4. Optional but safest: sign out of Teams and Outlook completely taskkill /IM outlook.exe /IM teams.exe /F # 5. Reboot once shutdown /r /t 0

###### ChatGPT said:

Excellent — that’s the right set of steps, and the behaviour you’re seeing confirms what’s left:
the cached identity layers are gone, but **the device itself isn’t re-joined** to Azure AD yet.
That’s why `dsregcmd /join` still throws **0x80041326** and the popup shows **657rx / 6008**.

Here’s the situation in plain English:

- You’ve removed all stale user tokens ✔️
- Outlook and Teams can still sign in because they negotiate their own OAuth directly ✔️
- The background **SSO / Web Account Manager** is still failing because the **device join task** is broken ✖️

That join task (`Automatic-Device-Join`) is what actually creates or refreshes the TPM-backed *device credentials*.
Without it, `dsregcmd /join` can’t schedule a job, and Windows can’t register the machine for single sign-on — hence the 657rx popup.

------

## Fix sequence (this is safe on the clone drive)

### 1.  Rebuild the Workplace Join task manually

Run this in **elevated PowerShell**:

```
# Remove the broken one
schtasks /Delete /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join" /F 2>$null

# Recreate a clean version
schtasks /Create /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join" `
  /SC ONLOGON /RL HIGHEST /RU SYSTEM `
  /TR "%SystemRoot%\System32\dsregcmd.exe /join"
```

Confirm it exists:

```
schtasks /Query /TN "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
```

You should see **Status = Ready**.

------

### 2.  Kick the join interactively

Now trigger it once manually:

```
dsregcmd /leave
Start-Sleep 5
dsregcmd /join
```

If you still see “Failed to schedule Join Task”, that’s OK — it will often succeed in the background on logon.

Reboot.

------

### 3.  Verify after reboot

```
dsregcmd /status | findstr /i "AzureAdJoined DeviceAuthStatus WorkplaceJoined"
```

Expect:

```
AzureAdJoined : YES
DeviceAuthStatus : SUCCESS
```

If it still says NO, open:

```
start ms-settings:workplace
```

Select **Connect** → **Join this device to Azure Active Directory**, sign in with your WF1 account.
This recreates the trust record interactively and instantly clears the popup.

------

### 4.  Why the popup persists until then

The “Something went wrong [657rx]” box isn’t coming from Outlook or Teams;
it’s **WAM (Web Account Manager)** trying to validate your device token with AAD.
Once the join task runs successfully and the PRT is re-issued, the popup stops within 1–2 logons.

------

### 5.  Optional tidy-up

```
# Refresh the new Primary Refresh Token
dsregcmd /refreshprt

# Re-enable BitLocker if it was paused
manage-bde -protectors -enable C:
```

------

**Bottom line:**
The clone is fine. You just need to **rebuild and trigger the device join task**.
Once `AzureAdJoined` flips to *YES*, that 657rx dialogue will disappear permanently.