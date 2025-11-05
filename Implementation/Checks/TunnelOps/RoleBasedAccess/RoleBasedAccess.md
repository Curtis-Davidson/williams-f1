## 1. The Core Principle

> **Applications must be installed “for all users” (machine-wide), not per user.**
> This means:

- Installers must run **as Administrator** (elevated).
- Installation context should write under `C:\Program Files` (or `C:\Program Files (x86)`), not `%LOCALAPPDATA%`.
- Any configuration or licensing should be stored in either:
    - `HKLM\Software\<Vendor>\<App>` (machine registry)
    - or `%PROGRAMDATA%\<Vendor>\<App>`

If you install from a standard user context, Windows Installer will redirect to the user profile (`AppData\Local\Programs`) and the next person who logs on won’t see it.

------

## 2. Installer Behaviour and How to Force “All Users”

| Installer Type                      | Correct Switch / Method                                  | Notes                                        |
| ----------------------------------- | -------------------------------------------------------- | -------------------------------------------- |
| **MSI (.msi)**                      | Run from admin cmd: `msiexec /i app.msi ALLUSERS=1 /qn`  | Always set `ALLUSERS=1`                      |
| **EXE (InstallShield/Wise)**        | Usually `/allusers` or `/machine`                        | e.g. `setup.exe /allusers`                   |
| **EXE (Inno Setup)**                | `setup.exe /VERYSILENT /ALLUSERS`                        | Can check `setup.exe /?`                     |
| **ClickOnce / per-user installers** | Avoid — repackage or use vendor’s enterprise/MSI version | These live under `%LOCALAPPDATA%` by default |
| **Microsoft Store apps**            | Use **winget** with `--scope machine`                    | Example below                                |

### Example commands

```
# MSI
msiexec /i "C:\Installers\TunnelSim.msi" ALLUSERS=1 /qn

# EXE (Inno)
Start-Process -FilePath "C:\Installers\CADToolSetup.exe" -ArgumentList "/VERYSILENT /ALLUSERS" -Wait -Verb RunAs

# Winget
winget install "Autodesk AutoCAD" --scope machine
```

------

## 3. Configuration Data

Put anything user-independent under `%PROGRAMDATA%` rather than inside a user profile.
Example:

```
C:\ProgramData\TunnelOps\CADProfiles\
C:\ProgramData\TunnelOps\TelemetryConfig\
```

These paths are visible to all users, and writable if you grant `Users:(M)` or `Authenticated Users:(M)` rights.

Use PowerShell to set ACLs:

```
icacls "C:\ProgramData\TunnelOps" /grant "Users:(OI)(CI)M" /T /C
```

------

## 4. Role-Based Access (AD / Entra Groups)

1. Create AD security groups for each engineering role:

   ```
   WF1-TunnelOps-Engineer
   WF1-Aero-Analyst
   WF1-CAD-Admin
   ```

2. Assign application **licences or shortcuts** through these groups.

3. For permissions on local folders or config files, grant rights to those groups rather than individuals:

   ```
   icacls "C:\ProgramData\TunnelOps" /grant "WF1-TunnelOps-Engineer:(M)"
   ```

4. If an app requires registry keys under HKLM:

    - Use Group Policy Preferences (Registry) to deploy common settings.
    - Or set them once via an elevated PowerShell script.

------

## 5. Shortcuts for All Users

If you need desktop or Start Menu visibility for every account:

```
# Create a Start Menu shortcut visible to all users
$AllUsersStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
Copy-Item "C:\Program Files\TunnelSim\TunnelSim.lnk" "$AllUsersStart\TunnelSim.lnk"

# Create an All Users desktop shortcut
Copy-Item "C:\Program Files\TunnelSim\TunnelSim.lnk" "C:\Users\Public\Desktop\TunnelSim.lnk"
```

------

## 6. Testing Method

1. Log on as an admin → install app with `ALLUSERS=1`.
2. Log off → sign in as a normal domain user (non-admin).
3. Confirm the application:
    - Appears in Start Menu (All Users scope).
    - Can launch without UAC prompts.
    - Reads its config correctly from `%PROGRAMDATA%` or HKLM.

------

## 7. Making it Repeatable (Template for All Machines)

Once one “reference” TunnelOps workstation is perfect:

1. Export app inventory (`winget export` or a custom script).
2. Use **Intune / SCCM / MDT / PowerShell remoting** to replay the same installs on others.
3. Store configuration under `C:\ProgramData\TunnelOps\Config.json` (read-only).
4. Build a **post-build script** that:
    - Copies all public shortcuts.
    - Ensures permissions and registry settings.
    - Validates core services.

------

## 8. Summary Table (What Belongs Where)

| Type                | Location                                              | Visibility |
| ------------------- | ----------------------------------------------------- | ---------- |
| Executables         | `C:\Program Files\<App>`                              | All Users  |
| Configuration       | `%PROGRAMDATA%\<App>`                                 | All Users  |
| Logs (shared)       | `%PROGRAMDATA%\<App>\Logs`                            | All Users  |
| Per-user temp/cache | `%LOCALAPPDATA%\<App>`                                | User only  |
| Desktop shortcut    | `C:\Users\Public\Desktop`                             | All Users  |
| Start menu          | `%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs` | All Users  |

------

If you’d like, I can build a **PowerShell deployment script** for your reference TunnelOps engineer image — one that installs all required packages in all-users scope, lays down shared configs under `C:\ProgramData\TunnelOps`, and locks it down cleanly.
Would you like me to generate that next?

##### You said:

What about if it's an in-house application that's written in-house? And what about if it's a group, a membership that requires network access as well? And we need to sort out the local access that any user logged in would have access to it.

###### ChatGPT said:

Good — now you’re talking enterprise-grade architecture.
Let’s break this down carefully so you can design **your own in-house apps** and **network access** to behave like any other “for-all-users, role-based” system.

We’ll cover both sides:

1. **Local app installation** (how to make an in-house app work for every user on that PC)
2. **Group / membership-controlled access** (network, file, DB, or service side)

------

## 1. If it’s your own application (written in-house)

### Design rule:

Everything the app needs to run **must live outside any specific user profile**.

That means:

- **Executables** go under `C:\Program Files\<AppName>` (never under `%LOCALAPPDATA%`)
- **Config / logs / runtime data** go under `%PROGRAMDATA%\Urbantek\<AppName>`
- **Per-user preferences** (if absolutely required) can go under `%APPDATA%\<AppName>`, but these should be *optional*and recreate automatically at first run.

### Example layout:

```
C:\Program Files\TunnelOpsSuite\
  ├── bin\
  ├── ui\
  └── TunnelOps.exe
C:\ProgramData\Urbantek\TunnelOpsSuite\
  ├── Config.json
  └── Logs\
```

### Installer / packaging:

If you’re distributing an in-house .NET, Python, or Electron app:

| Framework                 | How to package for all users                                 |
| ------------------------- | ------------------------------------------------------------ |
| **.NET / WinForms / WPF** | Build MSI with `ALLUSERS=1`; TargetDir=`ProgramFilesFolder`  |
| **Python**                | Use PyInstaller → wrap with MSI that installs to Program Files |
| **Electron / Node**       | Use Squirrel or MSI builder with `--machine` or `ALLUSERS=1` |
| **Custom .exe / script**  | Deploy via Intune / SCCM / PowerShell with elevated rights   |

Example (PowerShell silent deploy):

```
Start-Process msiexec.exe -ArgumentList '/i "\\fileshare\apps\TunnelOpsSuite.msi" ALLUSERS=1 /qn' -Wait -Verb RunAs
```

------

## 2. Local permissions so **any user** can run it

By default, standard users can *execute* from `C:\Program Files`.
If your app writes anywhere (logs, temp files, local DBs), point it to a writable shared area, e.g.:

```
# Create writable data dir for all users
$path = "C:\ProgramData\Urbantek\TunnelOpsSuite"
New-Item -ItemType Directory -Force -Path $path
icacls $path /grant "Users:(OI)(CI)(M)" /T /C
```

Then have the app reference that directory:

```
var dataPath = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData)
              + @"\Urbantek\TunnelOpsSuite";
```

That ensures every user, regardless of logon identity, can write logs/config.

------

## 3. Network / membership-controlled access

Now we move off the machine.

You want:

- All users to **see the app** and **run it locally**,
- But only specific roles (AD groups) to reach or interact with backend resources (shares, SQL, API, etc).

### Strategy:

1. **App always launches locally** — no user restriction.
2. Inside the app (or via the network permissions), enforce group membership.

#### a) File Share / Path

On your file server:

```
icacls "\\factory-fs01\TunnelOpsData" /grant "WF1-TunnelOps-Engineer:(M)"
icacls "\\factory-fs01\TunnelOpsData" /remove:g "Users"
```

#### b) Database (SQL / Postgres)

Use integrated Windows Auth, map AD group to DB role:

```
CREATE LOGIN [WF1-TunnelOps-Engineer] FROM WINDOWS;
CREATE USER [WF1-TunnelOps-Engineer] FOR LOGIN [WF1-TunnelOps-Engineer];
EXEC sp_addrolemember 'db_datareader', 'WF1-TunnelOps-Engineer';
```

#### c) REST / API Access

Use group-based claims:

- If hosted in IIS / ASP.NET: use Windows Authentication and `[Authorize(Roles="WF1-TunnelOps-Engineer")]`
- If in FastAPI or Node backend: pull `REMOTE_USER` from Kerberos/NTLM header and check AD group via LDAP lookup.

#### d) Network drives / VPN policies

Control these via GPO:

```
User Configuration → Preferences → Windows Settings → Drive Maps
  Target: WF1-TunnelOps-Engineer
  Path: \\factory-fs01\TunnelOpsData
```

That way, only those in the correct AD role get drive mappings, policies, and backend access.

------

## 4. Putting it together — role-based all-users workstation

| Layer          | Implementation                                         | Scope           |
| -------------- | ------------------------------------------------------ | --------------- |
| Application    | Installed machine-wide under Program Files             | All local users |
| Data / Config  | Stored in ProgramData with Users:(M) rights            | All local users |
| Access Control | AD groups determine network / DB / API rights          | Role-based      |
| Profiles       | Any domain user can log on (no shared profile needed)  | Per-user        |
| Deployment     | Intune / SCCM / PowerShell script with elevated rights | IT-controlled   |

------

## 5. Example: TunnelOps Workstation Model

**Goal:** any engineer logs in → all apps visible → rights governed by AD.

**Implementation script (PowerShell)**
`C:\Scripts\TunnelOps-WorkstationSetup.ps1`

```
# Purpose: prepare TunnelOps workstation for all-user use
# Expected: run once as admin; afterwards any domain user can run apps

# Create shared data area
$shared = "C:\ProgramData\Urbantek\TunnelOpsSuite"
New-Item -ItemType Directory -Force -Path $shared | Out-Null
icacls $shared /grant "Users:(OI)(CI)(M)" /T /C

# Install app
Start-Process msiexec.exe -ArgumentList '/i "\\factory-fs01\apps\TunnelOpsSuite.msi" ALLUSERS=1 /qn' -Wait -Verb RunAs

# Create global shortcuts
Copy-Item "C:\Program Files\Urbantek\TunnelOpsSuite\TunnelOps.exe" "C:\Users\Public\Desktop\TunnelOps.lnk"
Copy-Item "C:\Program Files\Urbantek\TunnelOpsSuite\TunnelOps.exe" "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\TunnelOps.lnk"
```

------

## 6. Verification

- Log in as random domain user (not admin) → app launches, reads common config, writes logs.
- Disconnect from network → app still opens (local).
- Reconnect → app checks AD group; if member, network/data access works.

------

If you tell me:

- What language/framework your in-house apps are built in (e.g. .NET, Electron, Python, C++)
- What kind of backend (shared files, database, REST API)

**exact deployment model and ACL template** for your environment so that any domain account can log in and use them, with role-based control and zero shared accounts. Would you like to go that route next?

enforce the proper “all-users, shared workstation” setup for Office.

------

## 1. Understand the two Office install modes

| Type                                | Where it installs                   | Who can use it           | Typical outcome                                       |
| ----------------------------------- | ----------------------------------- | ------------------------ | ----------------------------------------------------- |
| **Per-user Click-to-Run (default)** | `%LOCALAPPDATA%\Microsoft\Office`   | Only that user           | Other users get missing shortcuts or licensing errors |
| **Per-machine (device-based)**      | `C:\Program Files\Microsoft Office` | All users on the machine | Exactly what you want                                 |

The difference is controlled by the **Office Deployment Tool (ODT)** and the install XML — *not* by Intune or Store defaults.

------

## 2. Confirm your current Office installation type

Run this in PowerShell:

```
Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Office%'" | Select Name, InstallLocation
```

Or manually check:

```
C:\Program Files\Microsoft Office\
```

vs.

```
C:\Users\<user>\AppData\Local\Microsoft\Office\
```

If you see the second one, it’s per-user and should be reinstalled cleanly.

------

## 3. How to install Office for **all users (machine-wide)**

You need the **Office Deployment Tool** from Microsoft, and a simple XML file defining the correct mode.

### a) Download the ODT

```
Invoke-WebRequest -Uri "https://aka.ms/odt" -OutFile "C:\Installers\OfficeDeploymentTool.exe"
Start-Process "C:\Installers\OfficeDeploymentTool.exe" -ArgumentList "/quiet /extract:C:\Installers\ODT"
```

### b) Create configuration XML

Save this as
`C:\Installers\ODT\Office-AllUsers.xml`

```
<!-- Purpose: Install Microsoft 365 Apps for Enterprise for all users -->
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise" AllUsers="TRUE" AllowCdnFallback="TRUE">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-gb" />
      <ExcludeApp ID="Teams" /> <!-- Optional if Teams managed separately -->
    </Product>
  </Add>
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Property Name="SharedComputerLicensing" Value="1" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="TRUE" />
</Configuration>
```

### c) Run it elevated

```
cd C:\Installers\ODT
Start-Process "setup.exe" -ArgumentList "/configure Office-AllUsers.xml" -Wait -Verb RunAs
```

This installs Office under:

```
C:\Program Files\Microsoft Office\
C:\Program Files\Common Files\Microsoft Shared\
```

and every user who logs in will see the full suite.

------

## 4. Licensing behaviour

With `SharedComputerLicensing=1` and `DeviceBasedLicensing=TRUE`,
Office no longer “binds” to the first user.
Each person who logs in with their Microsoft 365 / Entra ID automatically gets licensed at runtime.

That’s the official **shared workstation mode** for labs, call-centres, or engineering machines.

------

## 5. Verifying post-install

Check the registry:

```
reg query "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v AllUsers
```

Expected:

```
AllUsers    REG_SZ    1
```

Executables should now live here:

```
C:\Program Files\Microsoft Office\root\Office16\
```

(e.g. WINWORD.EXE, EXCEL.EXE, OUTLOOK.EXE)

Shortcuts are under:

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
```

and visible to all users.

------

## 6. Tying it into your role-based model

Once Office is installed in all-users mode:

- No per-user reinstalls ever occur.
- Any domain account can launch Office apps.
- Licensing is automatic via Entra sign-in.
- You can still **control access** via group membership (e.g. `WF1-OfficeLicensedUsers`).

If you need to restrict who actually *can* run Office, deploy AppLocker or Software Restriction Policies linked to that AD group — so non-licensed roles don’t launch it.

------

## 7. Recap

| Goal                | Implementation                                               |
| ------------------- | ------------------------------------------------------------ |
| Executables shared  | Install with ODT using `AllUsers=TRUE`                       |
| License flexibility | `SharedComputerLicensing=1`                                  |
| Config uniformity   | Registry and ProgramData are machine-wide                    |
| Management          | AD group controls; optional AppLocker rules                  |
| Maintenance         | Same for all users; single update stream via Click-to-Run service |

------

If you like, I can generate a **ready-to-run Office All-Users deployment package** (XML + PowerShell wrapper) so you can drop it onto any TunnelOps machine and rebuild Office into proper enterprise mode.
Would you like me to do that next?

# UT-NoBS: Role-Based App Deployment (All Users, Zero Shared Accounts)

## 0) Principles (why this works)

- **Install per-machine only** (Program Files + HKLM). No per-user installers.
- **Authorisation by AD security group** (not by account). Membership = permission to run + write app-data.
- **Consistency**: app data lives in `C:\ProgramData\<Vendor>\<App>` (modifiable by role group), binaries live in `C:\Program Files\<Vendor>\<App>` (read-only to users).
- **First-run defaults** provided via **Active Setup** or **GPP Registry** for any HKCU that the vendor insists on.
- **Execution control** via **AppLocker** (or SRP) scoped to the role group.
- **Network access** via **Windows Firewall rules** scoped by group (if needed).

------

# 1) Create AD Role Groups (one per app/role)

### 1. Exact command

```
# Run on a management host with RSAT-AD
Import-Module ActiveDirectory

# App/role examples – rename to your canon
New-ADGroup -Name "WF1_App_TunnelOps"   -SamAccountName "WF1_App_TunnelOps"   -GroupScope Global -GroupCategory Security -Path "OU=Groups,DC=Factory,DC=WF1"
New-ADGroup -Name "WF1_App_AeroTools"   -SamAccountName "WF1_App_AeroTools"   -GroupScope Global -GroupCategory Security -Path "OU=Groups,DC=Factory,DC=WF1"
New-ADGroup -Name "WF1_Office_Users"    -SamAccountName "WF1_Office_Users"    -GroupScope Global -GroupCategory Security -Path "OU=Groups,DC=Factory,DC=WF1"
```

### 2. Full file path

N/A (directory objects in AD).

### 3. Directory creation

N/A.

### 4. File creation/edit command

N/A.

### 5. Code block

(Above)

### 6. Commented purpose

In comments above block.

### 7. Expected result / test

- `Get-ADGroup WF1_App_TunnelOps` returns the group.
- Add a user to test: `Add-ADGroupMember WF1_App_TunnelOps user1`.

------

# 2) Bind AD Role Groups to Local Rights (login allowed + local app rights)

You want *any domain user* to log on? That’s default. You want **only role members** to have elevated app permissions? We’ll add **role groups** to local groups (or grant NTFS/registry directly).

### Option A (recommended): via GPO – Local Users & Groups

- **GPO**: `WF1 – LocalGroup Bindings`
- **Path**: Computer Config > Preferences > Control Panel Settings > Local Users and Groups
- Add groups:
    - Local group: **Users** → **Add** `WF1_App_TunnelOps` (grants logon + read to user-space)
    - Local group: **Performance Log Users**/**Event Log Readers** as needed for tooling
    - (Do NOT put role groups in Administrators unless absolutely required.)

### Option B: one-off on a box (PowerShell)

```
net localgroup "Users" "Factory\WF1_App_TunnelOps" /add
net localgroup "Event Log Readers" "Factory\WF1_App_TunnelOps" /add
```

**Test**: `whoami /groups` as the user shows the AD group; `net localgroup "Users"` lists it.

------

# 3) Standard NTFS ACL Template (per app)

### Layout

```
C:\Program Files\<Vendor>\<App>\        # binaries (RO to users)
C:\ProgramData\<Vendor>\<App>\          # mutable data (Modify to role)
```

### 1. Exact command

```
$appVendor = "WF1"
$appName   = "TunnelOps"
$roleGroup = "Factory\WF1_App_TunnelOps"

# 2) Ensure directories
New-Item -ItemType Directory -Path "C:\Program Files\$appVendor\$appName" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\ProgramData\$appVendor\$appName"   -Force | Out-Null

# 3) Lock Program Files to admins+system; users read-only
icacls "C:\Program Files\$appVendor\$appName" /inheritance:r /grant "SYSTEM:(OI)(CI)F" "Administrators:(OI)(CI)F" "Users:(OI)(CI)RX" /T /C

# 4) Allow role group Modify on ProgramData; others read-only
icacls "C:\ProgramData\$appVendor\$appName" /inheritance:r /grant "SYSTEM:(OI)(CI)F" "Administrators:(OI)(CI)F" "$roleGroup:(OI)(CI)M" "Users:(OI)(CI)R" /T /C
```

### 2. Full file path

- `C:\Program Files\WF1\TunnelOps\`
- `C:\ProgramData\WF1\TunnelOps\`

### 3. Directory creation

As above.

### 4. File creation/edit command

As above.

### 5. Copy-pasteable code

(Above)

### 6. Commented purpose

Inline comments included.

### 7. Expected result / test

- As a **non-member** user: app folder read-only; ProgramData read-only.
- As a **member** user: write/modify succeeds under `C:\ProgramData\WF1\TunnelOps\`.

------

# 4) Registry ACL Template (when app stores machine config in HKLM)

### 1. Exact command

```
$roleGroup = "Factory\WF1_App_TunnelOps"
$pathHKLM  = "HKLM:\SOFTWARE\WF1\TunnelOps"

New-Item -Path $pathHKLM -Force | Out-Null

# Grant Modify for role group; FullControl for Admins/System
$rule = New-Object System.Security.AccessControl.RegistryAccessRule("SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$key  = Get-Item $pathHKLM
$acl  = $key.GetAccessControl()
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$acl.AddAccessRule($rule)
$acl.AddAccessRule((New-Object System.Security.AccessControl.RegistryAccessRule("Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.RegistryAccessRule($roleGroup,"Modify","ContainerInherit,ObjectInherit","None","Allow")))
$key.SetAccessControl($acl)
```

### 2. Full file path

Registry: `HKLM\SOFTWARE\WF1\TunnelOps`

### 3–6. Included above

### 7. Expected result / test

- `reg query HKLM\SOFTWARE\WF1\TunnelOps` works.
- As role user, can write a value: `reg add HKLM\SOFTWARE\WF1\TunnelOps /v Test /t REG_SZ /d OK`.

------

# 5) Office for All Users (device-based, shared-computer licensing)

### 1. Exact command

```
New-Item -ItemType Directory -Path "C:\Installers\ODT" -Force | Out-Null
Invoke-WebRequest -Uri "https://aka.ms/odt" -OutFile "C:\Installers\OfficeDeploymentTool.exe"
Start-Process "C:\Installers\OfficeDeploymentTool.exe" -ArgumentList "/quiet /extract:C:\Installers\ODT" -Wait

# Create the XML
@'
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise" AllUsers="TRUE" AllowCdnFallback="TRUE">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-gb" />
      <ExcludeApp ID="Teams" />
    </Product>
  </Add>
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Property Name="SharedComputerLicensing" Value="1" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="TRUE" />
</Configuration>
'@ | Set-Content -Path "C:\Installers\ODT\Office-AllUsers.xml" -Encoding UTF8

Start-Process "C:\Installers\ODT\setup.exe" -ArgumentList "/configure C:\Installers\ODT\Office-AllUsers.xml" -Wait -Verb RunAs
```

### 2. Full file path

- `C:\Installers\ODT\Office-AllUsers.xml`
- Office installs to `C:\Program Files\Microsoft Office\root\Office16\`

### 3–6. Included above (with comments).

### 7. Expected result / test

- `reg query "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v AllUsers` → `1`
- Any domain user can launch Word/Excel; first run prompts for Entra sign-in and activates (no per-user install).

------

# 6) First-Run HKCU Stubs (Active Setup: vendor apps that insist on HKCU)

### 1. Exact command

```
# Example: seed HKCU keys for TunnelOps at first logon per user
$GUID = "{E2E7B640-7C6A-4e8d-9D9E-UT-TunnelOps-Init}"
$Stub = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\$GUID"

New-Item -Path $Stub -Force | Out-Null
New-ItemProperty -Path $Stub -Name "Version"  -Value "1,0,0,0" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $Stub -Name "StubPath" -Value 'powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\WF1\TunnelOps\Init-HKCU.ps1"' -PropertyType String -Force | Out-Null

# Create the per-user initialiser
@'
# Purpose: add minimal HKCU keys safely (idempotent)
$base = "HKCU:\Software\WF1\TunnelOps"
New-Item -Path $base -Force | Out-Null
New-ItemProperty -Path $base -Name "UiTheme" -Value "Dark" -PropertyType String -Force | Out-Null
'@ | Set-Content "C:\Program Files\WF1\TunnelOps\Init-HKCU.ps1" -Encoding UTF8
```

### 2. Full file path

- `HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{GUID}`
- `C:\Program Files\WF1\TunnelOps\Init-HKCU.ps1`

### 3–6. Included.

### 7. Expected result / test

- Log on as a fresh user → HKCU `Software\WF1\TunnelOps` exists with values.

------

# 7) AppLocker: allow app only for the role group NOOOOOOOO!!!!

### 1. Exact command

```
# Create a minimal allow rule for role group on program path; default rules kept for Windows + Program Files
# Run locally (for pilot) or import into a GPO at Computer Config > Windows Settings > Security Settings > AppLocker

# Generate a policy fragment from path
$policy = New-AppLockerPolicy -Path "C:\Program Files\WF1\TunnelOps" -RuleType Exe -User "Factory\WF1_App_TunnelOps" -IgnoreMissingFileInformation
# Merge with default rules
$default = New-AppLockerPolicy -DefaultRule
$merged  = Merge-AppLockerPolicy -PolicyObject $default -MergePolicyObject $policy

# Enforce (local)
Set-AppLockerPolicy -PolicyObject $merged -Merge -ErrorAction Stop
# Ensure service is running
Set-Service -Name AppIDSvc -StartupType Automatic
Start-Service AppIDSvc
```

### 2. Path

- `C:\Program Files\WF1\TunnelOps\…`

### 3–6. Included.

### 7. Expected result / test

- **Member** of `WF1_App_TunnelOps` can run the app.
- **Non-member** gets AppLocker event 8004 (blocked) in `Applications and Services Logs\Microsoft\Windows\AppLocker\EXE and DLL`.

------

# 8) Windows Firewall Rules (only the role group can bind/use)

If your in-house tool listens locally or must reach specific hosts/ports:

### 1. Exact command

```
# Example: allow outbound to 10.50.10.25:59112 (AeroDB) only for role group
New-NetFirewallRule -DisplayName "WF1 TunnelOps to AeroDB 59112" `
  -Direction Outbound -Protocol TCP -RemoteAddress 10.50.10.25 -RemotePort 59112 `
  -Action Allow -Program "C:\Program Files\WF1\TunnelOps\TunnelOps.exe" `
  -EdgeTraversalPolicy Block

# Scope the rule to a security group via IPsec or by deploying the rule in a GPO
# that is security-filtered to the role group’s machine set (preferred: GPO to computers in the TunnelOps machine OU)
```

### 2. Path

- App binary: `C:\Program Files\WF1\TunnelOps\TunnelOps.exe`

### 3–6. Included.

### 7. Expected result / test

- `Test-NetConnection 10.50.10.25 -Port 59112` from the app host succeeds; other programs do not get this rule.

------

# 9) Installer Packaging Rules (MSI/MSIX/EXE)

- **Prefer MSI/MSIX** with **ALLUSERS=1** or per-machine settings.
- For legacy EXEs:
    - Use vendor silent switches (`/S`, `/quiet`, `/norestart`).
    - Validate it writes under `Program Files` and `ProgramData`.
    - If it drops files under `%LOCALAPPDATA%`, repackage or move configuration to `ProgramData` and bootstrap HKCU via Active Setup (section 6).

**Example MSI force per-machine:**

```
msiexec /i "\\fileserver\software\WF1\TunnelOps\setup.msi" ALLUSERS=1 /qn /norestart
```

**Example EXE (InstallShield/Wise typical):**

```
setup.exe /s /v"ALLUSERS=1 /qn /norestart"
```

------

# 10) Verification Script (Rule-8 “verify-exists” before creation)

### 1. Exact command

```
# C:\WF1\Verify\verify-app-surface.ps1
New-Item -ItemType Directory -Path "C:\Urbantek\Verify" -Force | Out-Null
@'
param(
  [Parameter(Mandatory=$true)] [string]$AppPath = "C:\Program Files\WF1\TunnelOps",
  [Parameter(Mandatory=$true)] [string]$DataPath = "C:\ProgramData\WF1\TunnelOps",
  [Parameter(Mandatory=$true)] [string]$RoleGroup = "Factory\WF1_App_TunnelOps"
)

Write-Host "=== VERIFY SURFACE ==="
Write-Host "[Dirs]  $AppPath , $DataPath"
Write-Host "[Group] $RoleGroup"

# Files/dirs
$e1 = Test-Path $AppPath
$e2 = Test-Path $DataPath
Write-Host "Exists: App=$e1  Data=$e2"
if(-not($e1 -and $e2)){ exit 2 }

# ACLs
Write-Host "`n[ACL] Program Files (expect Users=RX, Admins/SYSTEM=F):"
icacls $AppPath

Write-Host "`n[ACL] ProgramData (expect Role=Modify):"
icacls $DataPath

# AppLocker enforcement state
Write-Host "`n[AppLocker] Effective Policy (hash):"
(Get-AppLockerPolicy -Effective -ErrorAction SilentlyContinue).RuleCollections | ForEach-Object {
  $_.Rules | Measure-Object | Select Count
}

# Office all-users flag
Write-Host "`n[Office] AllUsers flag (1 expected) if Office present:"
reg query "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v AllUsers 2>$null

Write-Host "`nVerify complete."
'@ | Set-Content "C:\Urbantek\Verify\verify-app-surface.ps1" -Encoding UTF8
```

### 2. Full file path

- `C:\WF1\Verify\verify-app-surface.ps1`

### 3–6. Included.

### 7. Expected result / test

- Run:
  `powershell -ExecutionPolicy Bypass -File C:\Urbantek\Verify\verify-app-surface.ps1`
- You see expected ACLs + AppLocker effective counts; Office `AllUsers=1` if deployed.

------

# 11) In-House App: packaging checklist

1. **Binaries** → `C:\Program Files\WF1\<App>`
2. **Mutable data/logs/cache** → `C:\ProgramData\WF1\<App>`
3. **HKLM config** only; **HKCU** created via Active Setup if truly needed
4. **Service** runs as `LocalService` or `NetworkService` (not a user)
5. **Firewall** rules tied to executable
6. **AppLocker** rules scoped to `WF1_App_<App>` group
7. **Updates** ship as MSI/MSIX or EXE with the same layout; never write to user profile.

------

# 12) End-to-end smoke test (per machine)

1. Add **user A** to `WF1_App_TunnelOps` (and keep **user B** out).
2. Log in as **A** → launch app → can write to `C:\ProgramData\WF1\TunnelOps\Logs`.
3. Log in as **B** → app either runs read-only or is blocked by AppLocker (by design).
4. Office: both users launch Word → activation succeeds, no per-user install.
5. RSOP / gpresult shows the GPOs applied. AppLocker log shows allows/denies as expected.

------

## Bonus: make it reproducible (Intune/ConfigMgr/GPO)

- **Config** (ACLs, Active Setup, registry, firewall) in a **PowerShell remediation** package.
- **ODT Office** as a Win32 app in Intune with detection rule:
  `HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\AllUsers = 1`
- **AppLocker** in a computer-scoped GPO linked to the **TunnelOps machine OU**.

------

If you want this into a single **repo-ready** folder:

```
C:\Urbantek\Deploy\
  ├─ Apps\WF1\TunnelOps\ (stubs)
  ├─ ODT\Office-AllUsers.xml
  ├─ Scripts\Set-Acls.ps1
  ├─ Scripts\Enable-ActiveSetup.ps1
  ├─ Scripts\Enable-AppLocker.ps1
  └─ Verify\verify-app-surface.ps1
```



------

## 1. Where this lives

Everything here happens inside **Active Directory (AD)** — the normal company domain environment, not Entra (cloud).

So we’re talking about:

- **AD Groups** (that live in your on-premise domain)
- **Group Policy** (which applies to computers joined to the domain)
- **Local machine permissions** that those AD groups control once the user logs in.

------

## 2. The simple goal

You want:

> “Any engineer can log in with their own account (firstname.lastname), and automatically get access to the software tools they need on that workstation — without using a shared account.”

That’s what this system achieves.

------

## 3. How it does it (the idea in one sentence)

We create **AD Security Groups** — one per job role or application —
and give those groups **permission** on each workstation to run or access certain apps.

So instead of:

- `shr-tunops-dia` (a shared login)

You’d have:

- `paul.davidson`
- `rafal.janik`
- `jane.smith`
  and you’d simply *add* them to the group **WF1_App_TunnelOps** in Active Directory.

------

## 4. What happens when they log in

1. The laptop/workstation checks who’s logging in (that’s AD’s job).
2. Windows sees Paul is a member of `WF1_App_TunnelOps`.
3. Windows says, “Okay — that group has permission to read/write the TunnelOps data folder, and AppLocker says they’re allowed to run the TunnelOps app.”
4. Paul sees all the same apps that used to live under the shared account, but under his own login.

No hacks. No duplication.
Each person gets exactly what they should, based on their **group membership**.

------

## 5. What’s actually being created

| Component                             | Where               | Purpose                                                      |
| ------------------------------------- | ------------------- | ------------------------------------------------------------ |
| **AD Group (e.g. WF1_App_TunnelOps)** | In Active Directory | Represents everyone allowed to use that app                  |
| **Local folder permissions**          | On the workstation  | Makes the app data writable for group members                |
| **AppLocker rule (optional)**         | Policy from AD      | Ensures only that group can run the app                      |
| **ProgramData directory**             | On the workstation  | Common place for all users to share settings/logs            |
| **Office all-user install**           | On the workstation  | Lets every user access Office apps without reinstalling them per user |

------

## 6. Example scenario (TunnelOps workstation)

Let’s say you’ve got **five engineers**.

1. In AD, you create a group called `WF1_App_TunnelOps`.
2. You add those five engineers’ accounts to that group.
3. On the TunnelOps workstation, you run the setup script I gave you.
    - It installs the app once (machine-wide).
    - It sets folder permissions so that members of that group can use it.
    - It ensures the app appears for all users.
4. Now, anyone in the group can log into that PC, open the app, and everything works — as if it were installed just for them.

If a sixth engineer joins later, you don’t touch the workstation at all.
You just go into AD → find the user → “Add to group WF1_App_TunnelOps.”
Done. They’ll have access next time they log in.

------

## 7. Is it difficult to manage?

Not really. Once it’s set up, it’s extremely easy to maintain.

**IT Admin View:**

- Create groups once.
- Link those groups to the right permissions or apps.
- Add/remove users from those groups as their job changes.

**User View:**

- Log in with your normal domain account.
- The right tools are already there.

No more shared profiles, no duplicate installs, no broken policies.

------

## 8. Why this is better than shared accounts

| Shared Account                   | Role-Based Model                |
| -------------------------------- | ------------------------------- |
| Everyone uses the same login     | Everyone uses their own         |
| Impossible to audit who did what | Fully auditable                 |
| Profiles get corrupted           | Stable profiles per user        |
| Breaks policy compliance         | Fully compliant with AD         |
| Needs manual file copy           | Controlled via group membership |

------

## 9. What tools you need to manage it

- **Active Directory Users and Computers (ADUC)** — built into any admin workstation with RSAT.
- Optional: **Group Policy Management Console (GPMC)** for firewall/AppLocker rules.

If you’ve already got domain admin or delegated OU admin rights, you can do this yourself easily.

------

## 10. What you’ll see when it’s all in place

- Apps live in **Program Files**, not user folders.
- Common data/config lives in **ProgramData**.
- New user logs in — same icons, same tools, no reinstallation.
- Removing someone’s group membership immediately cuts their access.

------

If you’d like, I can now:

- Draw out **the exact AD + GPO hierarchy diagram** (visual, role-based).
- Provide **one PowerShell script** to create the group, link it to the workstation, and set all ACLs in one go.

Would you like me to generate that next?



- **Source:** your own project metadata (you supplied it).
- **Where:** stored in your ChatGPT memory context for Urbantek.
- **Nothing external:** I don’t query any AD, Entra, or internet directory unless you explicitly tell me to.

In short — the name exists because **you typed it first** as part of your canonical build.



------

## 1. **The Core Concept**

You’re building a **Role-Based Access Model**, where:

- Each **role** (Wind Tunnel Engineer, Wind Tunnel Aero, Wind Tunnel Systems, etc.) becomes a **security group in AD**.
- Membership of that group gives a user access to the **apps, folders, and web shortcuts** relevant to that role.
- The workstation doesn’t care *who* logs in — only *what groups they belong to*.

So you end up with:

```
WF1_App_TunnelOps
WF1_App_AeroTools
WF1_App_WindTunnelSystems
WF1_App_WindTunnelEngineer
```

Each group is the “key” that unlocks the same installed apps.

------

## 2. **Who installs the software**

Always install as a **local administrator** account — never as one of the users, and never as a shared account.

### You have two clean options:

| Option                                   | Who you log in as                                      | Typical usage                                                |
| ---------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| **Local Admin (built-in Administrator)** | `.\Administrator` or your `adminpdavidson` local admin | Best for manual build/testing — has full rights, not domain-tied |
| **Domain Admin / Deployment Account**    | `FACTORY\AdminDeploy`                                  | For repeatable rollout across machines (via GPO, SCCM, Intune, or script) |

This ensures apps install **system-wide** under `C:\Program Files` with registry keys in `HKLM`, not tied to one profile.

------

## 3. **What happens on the machine afterwards**

Once installed machine-wide:

1. Any user logs on.
2. Windows checks their AD group membership.
3. If they’re in, say, `WF1_App_TunnelOps`, then:
    - They have NTFS “Modify” rights to the app’s data folder (e.g. `C:\ProgramData\WF1\TunnelOps`).
    - AppLocker (if used) allows them to run `C:\Program Files\WF1\TunnelOps\TunnelOps.exe`.
    - Optional: shortcuts and registry entries for that role appear via Group Policy or a login script.

If they’re not in the group → the app either doesn’t appear, or launches read-only, or is blocked — whatever you decide.

------

## 4. **How to think of web-based / SharePoint / hybrid apps**

These are simpler — they don’t need machine-level installs.
Still, treat them as part of the **role definition**:

| Example                        | How to deliver                            | Where it links in                                 |
| ------------------------------ | ----------------------------------------- | ------------------------------------------------- |
| SharePoint “Wind Tunnel Docs”  | GPO or Intune Shortcut to Edge/Chrome     | Target only the `WF1_App_WindTunnelEngineer`group |
| Internal Web Portal (AeroView) | Add URL to corporate favourites via GPO   | Same targeting                                    |
| Teams/PowerApps tools          | Controlled in M365 by AD group membership | Same concept — group is the key                   |

So web apps, local apps, and Office components all pivot off the same role group.

------

## 5. **The practical build workflow**

**On the master TunnelOps workstation:**

1. Log in as `adminpdavidson` (local admin).
2. Install *all* required software (Wind Tunnel suite, Office, telemetry tools, etc.).
3. Configure each one for “All Users” during setup, or move config into `C:\ProgramData\<Vendor>\<App>`.
4. Verify the app launches under a *different* domain account — proves it’s machine-wide.
5. Apply NTFS permissions so the AD role group can modify its own ProgramData area.
6. Capture a restore point or clone — that’s your master image.
7. Push the same ACLs and AppLocker rules out via GPO later.

------

## 6. **How the hierarchy looks in AD**

```
OU=WF1_Apps
 ├── Group: WF1_App_TunnelOps
 ├── Group: WF1_App_WindTunnelEngineer
 ├── Group: WF1_App_WindTunnelAero
 └── Group: WF1_App_WindTunnelSystems

OU=WF1_Users
 ├── paul.davidson (Member of WF1_App_WindTunnelEngineer)
 ├── rafal.janik   (Member of WF1_App_WindTunnelSystems)
 └── claire.smith  (Member of WF1_App_TunnelOps)
```

Each group can map to multiple machines if you need — you just bind those groups into local ACLs or AppLocker rules.

------

## 7. **Quick sanity check**

When you run `whoami /groups` on a workstation, you’ll see:

```
Factory\WF1_App_TunnelOps
Factory\Domain Users
...
```

That’s how Windows knows what you’re allowed to run.

------

## 8. **Summary — no fluff**

| Task                     | Who does it                   | One-line purpose                            |
| ------------------------ | ----------------------------- | ------------------------------------------- |
| Install apps             | You, logged in as local admin | Put binaries in Program Files for all users |
| Create AD groups         | You or AD admin               | Define which roles exist                    |
| Set folder/registry ACLs | You (scripted)                | Let those groups write where needed         |
| Link groups to machines  | GPO Local Groups              | So group rights apply locally               |
| Add users to groups      | IT Admin                      | Grants access automatically                 |
| Verify                   | Log in as user                | If in group, app works; if not, blocked     |

------







--------------------------------------------------------------RBAC---------------------------------------------------------



# **TUNNELOPS ROLE-BASED APPLICATION ACCESS MODEL (RBAM)**

**Environment:** Hybrid AD (On-Prem AD + Entra / M365)
**Purpose:** Replace all shared logins with named user access, using AD group-based role control for all app types (local, network, web).
**Goal:** Any user (firstname.lastname) can log onto any designated workstation and automatically gain access to the correct set of tools, based purely on AD group membership.

------

## **1. Core Principles**

| Principle                            | Description                                                  |
| ------------------------------------ | ------------------------------------------------------------ |
| **1.1 Machine-wide installs**        | All applications are installed system-wide under `C:\Program Files\WF1\<AppName>` using a local admin account. No user-context installs. |
| **1.2 Role-based access only**       | Users are added to AD groups corresponding to their business area and app needs (e.g., `WF1_App_TunnelOps`). |
| **1.3 Consistency across all roles** | Every app—local, network, or web—is linked to its controlling AD group. |
| **1.4 No shared accounts**           | Every login is firstname.lastname. Shared accounts are disabled. |
| **1.5 Separation of Control**        | AD manages membership; local ACLs and GPOs manage visibility. The two layers never overlap logically. |
| **1.6 Zero code changes**            | Apps are not recompiled or reinstalled—only their installation paths, ACLs, and shortcuts are standardised. |

------

## **2. AD STRUCTURE & NAMING STANDARD**

```
OU=WF1_Apps
 ├── WF1_App_TunnelOps
 ├── WF1_App_WindTunnelEngineer
 ├── WF1_App_WindTunnelAero
 ├── WF1_App_ModelShop
 ├── WF1_App_Systems
 ├── WF1_App_Composites
 └── WF1_App_DataAcquisition

OU=WF1_Users
 ├── paul.davidson         (Member of WF1_App_WindTunnelEngineer)
 ├── rafal.janik           (Member of WF1_App_Systems)
 ├── claire.smith          (Member of WF1_App_TunnelOps)
 └── dan.harris            (Member of WF1_App_Composites)
```

- Each `WF1_App_*` group maps directly to one **application set or business role**.
- Group type: **Global Security Group** (so they sync with Entra for hybrid).
- Naming prefix: `WF1_App_` keeps search and GPO targeting consistent.

------

## **3. MACHINE PREPARATION MODEL**

| Step | Task                                              | Command / Description                                        |
| ---- | ------------------------------------------------- | ------------------------------------------------------------ |
| 3.1  | Log in as `adminpdavidson` or local Administrator | Ensures clean, machine-wide registry and file write permissions |
| 3.2  | Create root program directory                     | `mkdir "C:\Program Files\WF1"`                               |
| 3.3  | Create shared program data root                   | `mkdir "C:\ProgramData\WF1"`                                 |
| 3.4  | Set base ACL inheritance                          | `icacls "C:\Program Files\WF1" /inheritance:e`               |
| 3.5  | Pre-create subfolders per app area                | `mkdir "C:\Program Files\WF1\TunnelOps"`, etc.               |

All installs and configs live within these predictable, group-controllable paths.

------

## **4. INSTALLATION PROTOCOL**

| Type                   | Install As                                       | Path                             | Notes                                               |
| ---------------------- | ------------------------------------------------ | -------------------------------- | --------------------------------------------------- |
| **Local desktop apps** | `adminpdavidson`                                 | `C:\Program Files\WF1\<AppName>` | Always use “Install for all users” where offered    |
| **Network share apps** | Install once to network path                     | `\\WF1-FS01\Apps\<AppName>`      | Ensure `WF1_App_*` groups have read/execute         |
| **Web apps**           | None                                             | GPO shortcut only                | Shortcut points to internal web address or PowerApp |
| **Office Add-ins**     | System-wide via Office Customization Tool or MSI | -                                | Installed as admin once; not user-context           |

------

## **5. NTFS PERMISSION TEMPLATE**

Apply this to **each app folder** after installation.

### Example: Wind Tunnel Engineer tools

```
$AppDir = "C:\Program Files\WF1\WindTunnelEngineer"
$DataDir = "C:\ProgramData\WF1\WindTunnelEngineer"

icacls "$AppDir" /inheritance:e /grant "WF1_App_WindTunnelEngineer:(RX)" "Administrators:(F)" "SYSTEM:(F)"
icacls "$DataDir" /inheritance:e /grant "WF1_App_WindTunnelEngineer:(M)" "Administrators:(F)" "SYSTEM:(F)"
```

For **network share apps:**

```
icacls "\\WF1-FS01\Apps\TunnelOps" /grant "WF1_App_TunnelOps:(RX)" "Administrators:(F)"
icacls "\\WF1-FS01\Data\TunnelOps" /grant "WF1_App_TunnelOps:(M)" "Administrators:(F)"
```

This means:

- Members of `WF1_App_TunnelOps` can launch and modify within their role boundaries.
- All others are denied by omission (no explicit deny, just no allow).

------

## **6. GROUP POLICY CONFIGURATION**

### 6.1 Shortcut & Web Access Policy

Use **Group Policy Preferences → Shortcuts**.

| Target Group                 | Shortcut Path                                                | Destination               |
| ---------------------------- | ------------------------------------------------------------ | ------------------------- |
| `WF1_App_TunnelOps`          | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TunnelOps.lnk` | Target path to EXE or URL |
| `WF1_App_WindTunnelEngineer` | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Wind Tunnel Tools.lnk` | As required               |

This ensures each role only sees relevant Start Menu items.

------

### 6.2 Network Share Mapping (if applicable)

Use **GPO → User Configuration → Preferences → Drive Maps**

Example:

```
Action: Replace
Location: \\WF1-FS01\TunnelOpsData
Label: TunnelOps Data
Reconnect: Yes
Target Group: WF1_App_TunnelOps
```

------

### 6.3 Printer / Device Mappings (optional)

If specific workstations or printers are role-based (e.g. AeroPlotter01), target those by group as well.

------

## **7. TESTING PROTOCOL**

1. Log in as local admin → verify installation locations.
2. Log in as a **user not in any WF1_App_ group** → apps should not launch.
3. Log in as a **member of WF1_App_TunnelOps** → confirm access works, config loads.
4. Log in as a **member of another role** → verify separation.
5. Run `whoami /groups` → confirm correct group membership visible.
6. If an app fails to start → check ACLs and HKLM registry references (permissions usually too tight).

------

## **8. HYBRID / M365 SYNC**

Because this is hybrid AD:

- Make sure all `WF1_App_*` groups are **security-enabled and sync to Entra** (via AD Connect).
- This allows Intune, SharePoint, Teams, and PowerApps to reference the same groups for web-based role control.
- Your web apps (internal SharePoint, PowerApps, etc.) should use those same groups for permissions.

This gives one unified identity plane across:

- Windows logon
- On-prem file shares
- SharePoint sites
- PowerApps access
- In-house web apps

------

## **9. ONBOARDING PROCESS**

| Step | Action                                          |
| ---- | ----------------------------------------------- |
| 1    | Create AD user (`firstname.lastname`)           |
| 2    | Add to correct `WF1_App_*` groups               |
| 3    | User logs in → access auto-propagates           |
| 4    | Confirm `whoami /groups` matches expected roles |
| 5    | Done — no local configuration required          |

------

## **10. EXAMPLE: FULL ROLE IMPLEMENTATION**

**Role:** Wind Tunnel Engineer
**Apps:** AeroView, TunnelOps, Wind Tunnel Planner
**Web:** SharePoint TunnelOps Docs, PowerApp Test Planner
**Drives:** `\\WF1-FS01\AeroData`
**Group:** `WF1_App_WindTunnelEngineer`

### Setup Commands

```
# Local folder permissions
icacls "C:\Program Files\WF1\TunnelOps" /grant "WF1_App_WindTunnelEngineer:(RX)"
icacls "C:\ProgramData\WF1\TunnelOps" /grant "WF1_App_WindTunnelEngineer:(M)"

# Network data
icacls "\\WF1-FS01\AeroData" /grant "WF1_App_WindTunnelEngineer:(M)"
```

### GPO Preferences

- Shortcut: TunnelOps.lnk
- Drive Map: `Z:` → `\\WF1-FS01\AeroData`
- Web shortcut: `https://sharepoint/wf1/tunnelops`

------

## **11. MAINTENANCE**

| Task                   | Frequency      | Command / Tool                |
| ---------------------- | -------------- | ----------------------------- |
| Audit group membership | Monthly        | `Get-ADGroupMember WF1_App_*` |
| Reapply ACLs           | After installs | `icacls /verify` scripts      |
| Review GPOs            | Quarterly      | `gpresult /r`                 |
| Backup config          | Monthly        | Export OU & GPO XMLs          |

------

## **12. SUMMARY: WHY THIS WORKS**

- No user-context dependencies
- Simple AD-based control (one toggle = one access change)
- Easy to clone across business units
- Works for local + network + web apps
- No AppLocker, no registry pain, no rewriting
- Future-proof — hybrid sync to M365 already in place

------

If you like, I can generate **the full PowerShell + GPO starter pack** for one business area (say *TunnelOps Engineering*) — including:

- Group creation
- Folder ACL commands
- GPO XML export references
- Validation checks











------------------------------



# **TUNNELOPS ROLE-BASED APPLICATION ACCESS MODEL (RBAM)**

**Environment:** Hybrid AD (On-Prem AD + Entra / M365)
**Purpose:** Replace all shared logins with named user access, using AD group-based role control for all app types (local, network, web).
**Goal:** Any user (firstname.lastname) can log onto any designated workstation and automatically gain access to the correct set of tools, based purely on AD group membership.

------

## **1. Core Principles**

| Principle                            | Description                                                  |
| ------------------------------------ | ------------------------------------------------------------ |
| **1.1 Machine-wide installs**        | All applications are installed system-wide under `C:\Program Files\WF1\<AppName>` using a local admin account. No user-context installs. |
| **1.2 Role-based access only**       | Users are added to AD groups corresponding to their business area and app needs (e.g., `WF1_App_TunnelOps`). |
| **1.3 Consistency across all roles** | Every app—local, network, or web—is linked to its controlling AD group. |
| **1.4 No shared accounts**           | Every login is firstname.lastname. Shared accounts are disabled. |
| **1.5 Separation of Control**        | AD manages membership; local ACLs and GPOs manage visibility. The two layers never overlap logically. |
| **1.6 Zero code changes**            | Apps are not recompiled or reinstalled—only their installation paths, ACLs, and shortcuts are standardised. |

------

## **2. AD STRUCTURE & NAMING STANDARD**

```
OU=WF1_Apps
 ├── WF1_App_TunnelOps
 ├── WF1_App_WindTunnelEngineer
 ├── WF1_App_WindTunnelAero
 ├── WF1_App_ModelShop
 ├── WF1_App_Systems
 ├── WF1_App_Composites
 └── WF1_App_DataAcquisition

OU=WF1_Users
 ├── paul.davidson         (Member of WF1_App_WindTunnelEngineer)
 ├── rafal.janik           (Member of WF1_App_Systems)
 ├── claire.smith          (Member of WF1_App_TunnelOps)
 └── dan.harris            (Member of WF1_App_Composites)
```

- Each `WF1_App_*` group maps directly to one **application set or business role**.
- Group type: **Global Security Group** (so they sync with Entra for hybrid).
- Naming prefix: `WF1_App_` keeps search and GPO targeting consistent.

------

## **3. MACHINE PREPARATION MODEL**

| Step | Task                                              | Command / Description                                        |
| ---- | ------------------------------------------------- | ------------------------------------------------------------ |
| 3.1  | Log in as `adminpdavidson` or local Administrator | Ensures clean, machine-wide registry and file write permissions |
| 3.2  | Create root program directory                     | `mkdir "C:\Program Files\WF1"`                               |
| 3.3  | Create shared program data root                   | `mkdir "C:\ProgramData\WF1"`                                 |
| 3.4  | Set base ACL inheritance                          | `icacls "C:\Program Files\WF1" /inheritance:e`               |
| 3.5  | Pre-create subfolders per app area                | `mkdir "C:\Program Files\WF1\TunnelOps"`, etc.               |

All installs and configs live within these predictable, group-controllable paths.

------

## **4. INSTALLATION PROTOCOL**

| Type                   | Install As                                       | Path                             | Notes                                               |
| ---------------------- | ------------------------------------------------ | -------------------------------- | --------------------------------------------------- |
| **Local desktop apps** | `adminpdavidson`                                 | `C:\Program Files\WF1\<AppName>` | Always use “Install for all users” where offered    |
| **Network share apps** | Install once to network path                     | `\\WF1-FS01\Apps\<AppName>`      | Ensure `WF1_App_*` groups have read/execute         |
| **Web apps**           | None                                             | GPO shortcut only                | Shortcut points to internal web address or PowerApp |
| **Office Add-ins**     | System-wide via Office Customization Tool or MSI | -                                | Installed as admin once; not user-context           |

------

## **5. NTFS PERMISSION TEMPLATE**

Apply this to **each app folder** after installation.

### Example: Wind Tunnel Engineer tools

```
$AppDir = "C:\Program Files\WF1\WindTunnelEngineer"
$DataDir = "C:\ProgramData\WF1\WindTunnelEngineer"

icacls "$AppDir" /inheritance:e /grant "WF1_App_WindTunnelEngineer:(RX)" "Administrators:(F)" "SYSTEM:(F)"
icacls "$DataDir" /inheritance:e /grant "WF1_App_WindTunnelEngineer:(M)" "Administrators:(F)" "SYSTEM:(F)"
```

For **network share apps:**

```
icacls "\\WF1-FS01\Apps\TunnelOps" /grant "WF1_App_TunnelOps:(RX)" "Administrators:(F)"
icacls "\\WF1-FS01\Data\TunnelOps" /grant "WF1_App_TunnelOps:(M)" "Administrators:(F)"
```

This means:

- Members of `WF1_App_TunnelOps` can launch and modify within their role boundaries.
- All others are denied by omission (no explicit deny, just no allow).

------

## **6. GROUP POLICY CONFIGURATION**

### 6.1 Shortcut & Web Access Policy

Use **Group Policy Preferences → Shortcuts**.

| Target Group                 | Shortcut Path                                                | Destination               |
| ---------------------------- | ------------------------------------------------------------ | ------------------------- |
| `WF1_App_TunnelOps`          | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TunnelOps.lnk` | Target path to EXE or URL |
| `WF1_App_WindTunnelEngineer` | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Wind Tunnel Tools.lnk` | As required               |

This ensures each role only sees relevant Start Menu items.

------

### 6.2 Network Share Mapping (if applicable)

Use **GPO → User Configuration → Preferences → Drive Maps**

Example:

```
Action: Replace
Location: \\WF1-FS01\TunnelOpsData
Label: TunnelOps Data
Reconnect: Yes
Target Group: WF1_App_TunnelOps
```

------

### 6.3 Printer / Device Mappings (optional)

If specific workstations or printers are role-based (e.g. AeroPlotter01), target those by group as well.

------

## **7. TESTING PROTOCOL**

1. Log in as local admin → verify installation locations.
2. Log in as a **user not in any WF1_App_ group** → apps should not launch.
3. Log in as a **member of WF1_App_TunnelOps** → confirm access works, config loads.
4. Log in as a **member of another role** → verify separation.
5. Run `whoami /groups` → confirm correct group membership visible.
6. If an app fails to start → check ACLs and HKLM registry references (permissions usually too tight).

------

## **8. HYBRID / M365 SYNC**

Because this is hybrid AD:

- Make sure all `WF1_App_*` groups are **security-enabled and sync to Entra** (via AD Connect).
- This allows Intune, SharePoint, Teams, and PowerApps to reference the same groups for web-based role control.
- Your web apps (internal SharePoint, PowerApps, etc.) should use those same groups for permissions.

This gives one unified identity plane across:

- Windows logon
- On-prem file shares
- SharePoint sites
- PowerApps access
- In-house web apps

------

## **9. ONBOARDING PROCESS**

| Step | Action                                          |
| ---- | ----------------------------------------------- |
| 1    | Create AD user (`firstname.lastname`)           |
| 2    | Add to correct `WF1_App_*` groups               |
| 3    | User logs in → access auto-propagates           |
| 4    | Confirm `whoami /groups` matches expected roles |
| 5    | Done — no local configuration required          |

------

## **10. EXAMPLE: FULL ROLE IMPLEMENTATION**

**Role:** Wind Tunnel Engineer
**Apps:** AeroView, TunnelOps, Wind Tunnel Planner
**Web:** SharePoint TunnelOps Docs, PowerApp Test Planner
**Drives:** `\\WF1-FS01\AeroData`
**Group:** `WF1_App_WindTunnelEngineer`

### Setup Commands

```
# Local folder permissions
icacls "C:\Program Files\WF1\TunnelOps" /grant "WF1_App_WindTunnelEngineer:(RX)"
icacls "C:\ProgramData\WF1\TunnelOps" /grant "WF1_App_WindTunnelEngineer:(M)"

# Network data
icacls "\\WF1-FS01\AeroData" /grant "WF1_App_WindTunnelEngineer:(M)"
```

### GPO Preferences

- Shortcut: TunnelOps.lnk
- Drive Map: `Z:` → `\\WF1-FS01\AeroData`
- Web shortcut: `https://sharepoint/wf1/tunnelops`

------

## **11. MAINTENANCE**

| Task                   | Frequency      | Command / Tool                |
| ---------------------- | -------------- | ----------------------------- |
| Audit group membership | Monthly        | `Get-ADGroupMember WF1_App_*` |
| Reapply ACLs           | After installs | `icacls /verify` scripts      |
| Review GPOs            | Quarterly      | `gpresult /r`                 |
| Backup config          | Monthly        | Export OU & GPO XMLs          |

------

## **12. SUMMARY: WHY THIS WORKS**

- No user-context dependencies
- Simple AD-based control (one toggle = one access change)
- Easy to clone across business units
- Works for local + network + web apps
- No AppLocker, no registry pain, no rewriting
- Future-proof — hybrid sync to M365 already in place

------

If you like, I can generate **the full PowerShell + GPO starter pack** for one business area (say *TunnelOps Engineering*) — including:

- Group creation
- Folder ACL commands
- GPO XML export references
- Validation checks

Would you like me to produce that next, so you’ve got a fully runnable template for deployment and documentation?

##### You said:

do this as a sample and using best practice, If you like, I can generate the full PowerShell + GPO starter pack for one business area (say TunnelOps Engineering) — including: • Group creation • Folder ACL commands • GPO XML export references • Validation checks Would you like me to produce that next, so you’ve got a fully runnable template for deployment and documentation? be clear and not over complicate, keep it simple

###### ChatGPT said:

Perfect.
Here’s a **clean, production-ready starter pack** for one department — **TunnelOps Engineering** — written in your preferred *UT-NoBS* precision style.
No bloat, no “Microsoft theatre.” It’s exactly what you’d execute to implement role-based access properly.

------

# **WF1 Role-Based Access Template – TunnelOps Engineering**

## **Purpose**

Establish a self-contained, role-based app access model for all *TunnelOps Engineering* users.
Members of the AD group `WF1_App_TunnelOpsEngineer` will automatically gain access to local and network applications, data folders, and shortcuts when logging into authorised machines.

------

## **1. AD Group Creation**

**Command:**

```
# Run from a Domain Controller or RSAT PowerShell with AD module
New-ADGroup -Name "WF1_App_TunnelOpsEngineer" `
    -SamAccountName "WF1_App_TunnelOpsEngineer" `
    -GroupCategory Security -GroupScope Global `
    -Path "OU=WF1_Apps,DC=Factory,DC=WF1" `
    -Description "Role group for TunnelOps Engineering application access"
```

**Purpose:**
Creates a single global security group used to control all application, network, and web resource access for the TunnelOps Engineering role.

------

## **2. Local Directory ACLs**

**Command (run on each workstation or via deployment script):**

```
# Define paths
$AppDir  = "C:\Program Files\WF1\TunnelOpsEngineer"
$DataDir = "C:\ProgramData\WF1\TunnelOpsEngineer"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $AppDir,$DataDir | Out-Null

# Apply ACLs
icacls "$AppDir"  /inheritance:e /grant "WF1_App_TunnelOpsEngineer:(RX)" "Administrators:(F)" "SYSTEM:(F)"
icacls "$DataDir" /inheritance:e /grant "WF1_App_TunnelOpsEngineer:(M)"  "Administrators:(F)" "SYSTEM:(F)"
```

**Purpose:**

- Allows group members to run executables (Read/Execute).
- Allows write access to configuration and cache data in ProgramData.
- Keeps control with Administrators and SYSTEM only.

------

## **3. Network Share ACLs**

**Command (run on file server hosting the data):**

```
# Example paths
$ShareApp  = "\\WF1-FS01\Apps\TunnelOpsEngineer"
$ShareData = "\\WF1-FS01\Data\TunnelOpsEngineer"

icacls "$ShareApp"  /grant "WF1_App_TunnelOpsEngineer:(RX)" "Administrators:(F)"
icacls "$ShareData" /grant "WF1_App_TunnelOpsEngineer:(M)"  "Administrators:(F)"
```

**Purpose:**
Same model — read/execute for binaries, modify for working data.

------

## **4. GPO – Shortcuts & Drive Maps**

### **4.1 Shortcut Creation**

Use *Group Policy Management Console*
Path:
`User Configuration → Preferences → Windows Settings → Shortcuts`

| Setting     | Value                                                        |
| ----------- | ------------------------------------------------------------ |
| Action      | Replace                                                      |
| Name        | TunnelOps Engineer Tools                                     |
| Target Path | `C:\Program Files\WF1\TunnelOpsEngineer\TunnelOps.exe`       |
| Start In    | `C:\Program Files\WF1\TunnelOpsEngineer`                     |
| Location    | Start Menu                                                   |
| Targeting   | Item-level targeting → Security Group: `WF1_App_TunnelOpsEngineer` |

------

### **4.2 Drive Map**

Path:
`User Configuration → Preferences → Windows Settings → Drive Maps`

| Setting      | Value                                       |
| ------------ | ------------------------------------------- |
| Action       | Replace                                     |
| Location     | `\\WF1-FS01\Data\TunnelOpsEngineer`         |
| Drive Letter | `Z:`                                        |
| Label        | TunnelOps Data                              |
| Targeting    | Security Group: `WF1_App_TunnelOpsEngineer` |

**Export Reference:**
Once configured, you can export the GPO XML with:

```
Backup-Gpo -Name "WF1 TunnelOps Engineering" -Path "C:\GPO_Backups"
```

------

## **5. Validation Commands**

**Run on a workstation logged in as a TunnelOps Engineer user:**

```
# Check group membership
whoami /groups | findstr WF1_App_TunnelOpsEngineer

# Verify folder permissions
icacls "C:\Program Files\WF1\TunnelOpsEngineer"
icacls "C:\ProgramData\WF1\TunnelOpsEngineer"

# Confirm drive map and shortcut
Get-PSDrive | findstr Z:
Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TunnelOps Engineer Tools.lnk"
```

**Expected Results:**

- Group appears in `whoami /groups`
- `RX` and `M` permissions are correct
- `Z:` drive mapped correctly
- Shortcut visible in Start Menu

------

## **6. Summary**

| Layer      | Controlled By               | Description                               |
| ---------- | --------------------------- | ----------------------------------------- |
| AD Group   | `WF1_App_TunnelOpsEngineer` | Defines who can access                    |
| NTFS ACL   | Local machine / File server | Defines what can be accessed              |
| GPO        | Domain policy               | Defines how access appears                |
| User login | firstname.lastname          | Gains access automatically via membership |

------

## **7. Replication to Other Business Areas**

Repeat exactly with these variable replacements:

| Variable         | Replace With Example                |
| ---------------- | ----------------------------------- |
| Group Name       | WF1_App_WindTunnelAero              |
| AppDir / DataDir | C:\Program Files\WF1\WindTunnelAero |
| Share Paths      | \WF1-FS01\Apps\WindTunnelAero       |
| GPO Name         | WF1 WindTunnel Aero                 |

No redesign required — only the identifiers change.

------

### **Result**

- Zero shared accounts
- Single AD toggle for enable/disable
- Simple ACL model (RX for Program Files, M for ProgramData)
- Consistent GPO delivery of Start Menu & drive access
- Fully hybrid-compatible (groups sync to Entra if needed)







-------------------------------------------







This *is* completely doable, and it’s not nearly as complicated as it sounds once you strip out the Microsoft waffle.
Let’s break it down so you can see it clearly.

------

## **1. What you’re trying to achieve**

You want every **TunnelOps** machine to:

- Let any **firstname.lastname** user log in.
- Automatically have access to all the right tools — local, network, and web.
- Without using a shared account.
- Without reinstalling or reconfiguring apps per user.

That’s the essence: **machine-wide apps + AD-based permissions**.

------

## **2. The simple logic**

Think of it like this:

| Layer                  | What it does                                             | Example                                              |
| ---------------------- | -------------------------------------------------------- | ---------------------------------------------------- |
| **AD Group**           | Decides who can use what                                 | WF1_App_WindTunnelEngineer                           |
| **Local Install**      | Puts apps on the machine (for all users)                 | Installed under `C:\Program Files\WF1\TunnelOps\...` |
| **Permissions (ACLs)** | Let that AD group actually run those apps                | icacls gives Read/Execute to the group               |
| **Group Policy (GPO)** | Gives the user the right shortcut, mapped drive, or link | Shows only what their group should see               |

That’s it.
Four moving parts — **AD, ACL, GPO, and the local app install** — and they work together cleanly.

------

## **3. The workflow**

### Step 1: Create the role groups (once)

Example:

```
WF1_App_WindTunnelEngineer
WF1_App_WindTunnelAero
WF1_App_WindTunnelSystems
```

Anyone added to those groups instantly inherits the correct access.

------

### Step 2: Install the apps on the machine (once)

Log in as your admin account (e.g. `adminpdavidson`)
Install everything **for all users** — not for “just me”.

Local apps go under:

```
C:\Program Files\WF1\TunnelOps\<AppName>
C:\ProgramData\WF1\TunnelOps\<AppName>
```

Network apps live on:

```
\\WF1-FS01\Apps\TunnelOps\<AppName>
```

Web apps are just URLs you’ll deploy via shortcut.

------

### Step 3: Apply permissions (ACLs)

Give the right AD group permission to run the right folders.

Example:

```
icacls "C:\Program Files\WF1\TunnelOps\WindTunnelEngineer" /grant "WF1_App_WindTunnelEngineer:(RX)"
icacls "C:\ProgramData\WF1\TunnelOps\WindTunnelEngineer"  /grant "WF1_App_WindTunnelEngineer:(M)"
```

That means:

- Members of that group can run the apps and save configs.
- Others can’t.

------

### Step 4: Use Group Policy to “light up” the desktop

Each group gets its own GPO that:

- Adds the Start Menu shortcut.
- Maps the correct drive.
- Optionally adds the SharePoint or web links.

Example:

| Group                      | Shortcut                                                     | Drive                                          |
| -------------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| WF1_App_WindTunnelEngineer | `C:\Program Files\WF1\TunnelOps\WindTunnelEngineer\TunnelOps.exe` | `\\WF1-FS01\Data\TunnelOps\WindTunnelEngineer` |
| WF1_App_WindTunnelAero     | `C:\Program Files\WF1\TunnelOps\WindTunnelAero\AeroView.exe` | `\\WF1-FS01\Data\TunnelOps\WindTunnelAero`     |

Result: each role logs in, and their environment builds itself automatically.

------

### Step 5: Syncs cleanly to Office 365 / Entra

Because these are **security groups** in AD, they’ll sync via AD Connect —
so the same group can also control access in SharePoint, PowerApps, Teams, etc.

That’s your “hybrid” magic — one identity plane.

------

## **4. What you end up with**

| Person        | Role               | AD Group                   | Tools they see                                         |
| ------------- | ------------------ | -------------------------- | ------------------------------------------------------ |
| Paul Davidson | WindTunnelEngineer | WF1_App_WindTunnelEngineer | TunnelOps.exe, Engineer Data (Z:), Engineer SharePoint |
| Rafal Janik   | WindTunnelAero     | WF1_App_WindTunnelAero     | AeroView.exe, Aero Data (Z:), Aero SharePoint          |
| Chris Hicks   | WindTunnelSystems  | WF1_App_WindTunnelSystems  | SysManager.exe, Systems Data (Z:), Systems Portal      |

Each person logs into *their own* account on the same PC and everything just works.
No reinstallation, no profile cloning, no shared logins.

------

## **5. How hard is this to maintain?**

**Low.**
Once you build it once:

- Adding a new person? → Just put them in the correct group.
- Rebuilding a PC? → Just install apps again in the same place.
- Adding a new app? → Drop it under the right folder and ACL it.

No more managing user profiles or per-user setups.

------

## **6. Why this works**

- Windows checks the user’s group membership at logon.
- The folders, shares, and shortcuts are tied to those groups.
- So the desktop environment self-assembles per role.

It’s the same principle that big enterprises use for role-based access.
Yours is just tighter and simpler.

------

## **7. Bottom line**

- You’re **not rewriting** or redeploying applications.
- You’re **standardising install locations** and **controlling access** through AD.
- It’s **clean, hybrid-compatible**, and completely **repeatable** for all departments.

------

If you’d like, I can write you a **single PowerShell script** that:

- Creates all three AD groups
- Sets up the folder structure and permissions
- Outputs a ready-to-import GPO XML for the shortcuts and drives

So the whole role-based model can be built on any new workstation in minutes.
Would you like me to generate that next?