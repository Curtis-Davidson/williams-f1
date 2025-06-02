# ==========================================================
# MODULE: Williams F1 Workstation Discovery Core
# Path: /lib/workstation-core.ps1
# Author: Paul R Davidson & Urbantek
# ==========================================================

# --- Get-InstalledApplications ---
function Get-InstalledApplications {
    <#
    .SYNOPSIS
    Returns a list of installed applications from registry.

    .DESCRIPTION
    Enumerates 32-bit and 64-bit registry paths to capture all MSI and manual installs.

    .OUTPUTS
    Array of PSCustomObject with Name, Version, Publisher, InstallDate.
    #>
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.DisplayName
                Version     = $_.DisplayVersion
                Publisher   = $_.Publisher
                InstallDate = $_.InstallDate
            }
        }
    }
}

# --- Get-MappedDrives ---
function Get-MappedDrives {
    <#
    .SYNOPSIS
    Returns currently mapped network drives.

    .OUTPUTS
    Array of PSCustomObject with DriveLetter, RemotePath.
    #>
    Get-WmiObject -Query "Select * from Win32_MappedLogicalDisk" | ForEach-Object {
        [PSCustomObject]@{
            DriveLetter = $_.DeviceID
            RemotePath  = $_.ProviderName
        }
    }
}

# --- Get-LoggedInUsers ---
function Get-LoggedInUsers {
    <#
    .SYNOPSIS
    Returns list of users logged in over last 30 days via Security log.

    .OUTPUTS
    Array of strings (usernames).
    #>
    $logins = Get-WinEvent -LogName Security -FilterHashtable @{ Id = 4624; StartTime = (Get-Date).AddDays(-30) } -MaxEvents 5000 |
            Where-Object { $_.Properties[5].Value -ne "ANONYMOUS LOGON" } |
            Select-Object -ExpandProperty Properties |
            Where-Object { $_.Value -match ".*\\.*" } |
            ForEach-Object { $_.Value.Split('\\')[1] } |
            Sort-Object -Unique

    return $logins
}

# --- Get-UserRightsAssignments ---
function Get-UserRightsAssignments {
    <#
    .SYNOPSIS
    Returns all user rights assignments (e.g., logon locally, shutdown system).

    .OUTPUTS
    Hashtable of privileges and corresponding users/groups.
    #>
    secedit /export /cfg "$env:TEMP\secedit.cfg" > $null
    $lines = Get-Content "$env:TEMP\secedit.cfg" | Where-Object { $_ -like "Se*Privilege*" }

    $rights = @{}
    foreach ($line in $lines) {
        $key, $value = $line -split '='
        $rights[$key.Trim()] = $value.Trim().Split(',')
    }

    return $rights
}

# --- Get-UserProfiles ---
function Get-UserProfiles {
    <#
    .SYNOPSIS
    Returns all local profiles with their size, last use, and SID.

    .OUTPUTS
    Array of PSCustomObject.
    #>
    Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -like "C:\Users\*" } | ForEach-Object {
        [PSCustomObject]@{
            UserSID   = $_.SID
            Path      = $_.LocalPath
            LastUse   = $_.LastUseTime
            IsRoaming = $_.RoamingConfigured
            IsLoaded  = $_.Loaded
        }
    }
}

# --- Get-ProfileState ---
function Get-ProfileState {
    <#
    .SYNOPSIS
    Returns the state of a user profile (active, stale, roaming).

    .PARAMETER ProfileObject
    One object from Get-UserProfiles.

    .OUTPUTS
    String describing state.
    #>
    param (
        [Parameter(Mandatory)]
        $ProfileObject
    )

    $ageDays = ((Get-Date) - $ProfileObject.LastUse).Days

    if ($ProfileObject.IsRoaming -eq $true) {
        return "Roaming Profile"
    }
    elseif ($ageDays -gt 90) {
        return "Stale Profile (>90 days)"
    }
    elseif ($ProfileObject.IsLoaded) {
        return "Active"
    }
    else {
        return "Inactive"
    }
}