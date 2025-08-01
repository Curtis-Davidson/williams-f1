<#
.SYNOPSIS
Disables OneDrive Desktop folder backup, clears OneDrive folder mapping cache, and prevents future automatic Known Folder Move (KFM) reinstatement.

.EXECUTION
Run this as the logged-in user. No admin needed unless enforcing HKLM policy.

.DESIGNED FOR
- Personal or enterprise machines with rogue OneDrive Desktop backup behaviour.
#>

Write-Host "Disabling OneDrive Desktop backup..." -ForegroundColor Cyan

# 1. Disable backup via GUI-initiated registry state (cached mapping) $onedriveRegPaths = @(
"HKCU:\Software\Microsoft\OneDrive\Accounts\Business1\ScopeIdToMountPointPathCache",
"HKCU:\Software\Microsoft\OneDrive\Accounts\Business1\ScopeIdToPath"
)

foreach ($path in $onedriveRegPaths) {
if (Test-Path $path) {
Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Removed mapping: $path"
} else {
Write-Host "Mapping path not found (already removed): $path"
}
}

# 2. Block Known Folder Move opt-in for this user $policyKeyHKCU = "HKCU:\Software\Policies\Microsoft\OneDrive"
New-Item -Path $policyKeyHKCU -Force | Out-Null

Set-ItemProperty -Path $policyKeyHKCU -Name "KFMBlockOptIn" -Value 1 -Type DWord -Force Write-Host "Set KFMBlockOptIn = 1 (user policy)"

# 3. Remove silent opt-in keys (in case they exist) Remove-ItemProperty -Path $policyKeyHKCU -Name "KFMSilentOptIn" -ErrorAction SilentlyContinue Remove-ItemProperty -Path $policyKeyHKCU -Name "KFMSilentOptInFolderList" -ErrorAction SilentlyContinue

# 4. (Optional) Prevent auto-opt-in for new profiles (local machine level) $policyKeyHKLM = "HKLM:\Software\Policies\Microsoft\OneDrive"
if (Test-Path $policyKeyHKLM) {
try {
Set-ItemProperty -Path $policyKeyHKLM -Name "PreventKFMAutoOptIn" -Value 1 -Type DWord -Force
Write-Host "Set PreventKFMAutoOptIn = 1 (machine-wide)"
} catch {
Write-Host "HKLM write failed. Run with elevation if machine policy required."
}
}

Write-Host "OneDrive Desktop backup should now stay OFF." -ForegroundColor Green Write-Host "Restart OneDrive or reboot for full effect." -ForegroundColor Yellow
