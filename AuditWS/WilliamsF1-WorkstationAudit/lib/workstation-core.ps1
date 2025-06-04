# =====================================================================
# MODULE: Williams F1 Workstation Discovery Core
# Path: /lib/workstation-core.ps1
# Author: Paul R Davidson & Urbantek
# Version: 2025.6.4
# Status: Rule 6 Compliant - Canonical
# =====================================================================

# --- Get-InstalledApplications ---
function Get-InstalledApplications {
    <#
    .SYNOPSIS
    Enumerates installed applications from 32-bit and 64-bit registry locations.

    .OUTPUTS
    Array of PSCustomObject with Name, Version, Publisher, InstallDate.
    #>
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $apps = @()
    foreach ($path in $paths) {
        $apps += Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.DisplayName
                Version     = $_.DisplayVersion
                Publisher   = $_.Publisher
                InstallDate = $_.InstallDate
            }
        }
    }

    return $apps | Where-Object { $null -ne $_.Name } | Sort-Object Name -Unique
}

# --- Get-MappedDrives ---
function Get-MappedDrives {
    <#
    .SYNOPSIS
    Returns all mapped network drives.

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
    Parses the Security event log to find usernames who have logged in the last 30 days.

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
    Returns user rights assignments by exporting the security policy.

    .PARAMETER username
    Optional - if specified, filters only relevant entries.

    .OUTPUTS
    Hashtable of rights and assigned SIDs or usernames.
    #>
    param ([string]$username)

    $cfgFile = "$env:TEMP\secpol.cfg"
    secedit /export /cfg $cfgFile > $null
    $lines = Get-Content $cfgFile | Where-Object { $_ -like "Se*Privilege*" }

    $rights = @{}
    foreach ($line in $lines) {
        $key, $value = $line -split '='
        $users = $value.Trim().Split(',') | Where-Object {
            if ($username) {
                $_ -match $username
            } else {
                $true
            }
        }
        if ($users.Count -gt 0) {
            $rights[$key.Trim()] = $users
        }
    }

    return $rights
}

# --- Get-UserProfiles ---
function Get-UserProfiles {
    <#
    .SYNOPSIS
    Returns local user profiles with metadata.

    .OUTPUTS
    Array of PSCustomObject with SID, Path, LastUse, IsRoaming, IsLoaded, UserName.
    #>
    Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -like "C:\Users\*" } | ForEach-Object {
        [PSCustomObject]@{
            UserSID   = $_.SID
            Path      = $_.LocalPath
            UserName  = $_.LocalPath.Split('\')[-1]
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
    Describes profile status (Active, Inactive, Roaming, Stale).

    .PARAMETER ProfileObject
    The profile object returned by Get-UserProfiles.

    .OUTPUTS
    String
    #>
    param ([Parameter(Mandatory)] $ProfileObject)

    $ageDays = ((Get-Date) - $ProfileObject.LastUse).Days

    if ($ProfileObject.IsRoaming -eq $true) {
        return "Roaming Profile"
    } elseif ($ageDays -gt 90) {
        return "Stale Profile (>90 days)"
    } elseif ($ProfileObject.IsLoaded) {
        return "Active"
    } else {
        return "Inactive"
    }
}

# --- Test-FSLogixProfilePresence ---
function Test-FSLogixProfilePresence {
    <#
    .SYNOPSIS
    Checks for FSLogix profile folder presence under AppData.

    .PARAMETER username
    Username to inspect.

    .OUTPUTS
    Boolean
    #>
    param ([string]$username)

    $profilePath = "C:\Users\$username\AppData\Local\FSLogix"
    return (Test-Path $profilePath)
}

# --- Get-GPOReportForUser ---
function Get-GPOReportForUser {
    <#
    .SYNOPSIS
    Generates GPO HTML report for a user. Returns status only.

    .PARAMETER username
    The username to test GPO for.

    .OUTPUTS
    String (✔️ / ❌)
    #>
    param ([string]$username)

    $out = "$env:TEMP\gpresult-$username.html"
    try {
        gpresult /USER $username /H $out > $null 2>&1
        if (Test-Path $out) { return "✔️" } else { return "❌" }
    } catch {
        return "❌"
    }
}