# =============================================
# Williams F1 Shared Account Audit – Core Functions
# File Path: /lib/core-functions.ps1
# Author: Curtis-Davidson & Urbantek
# Version: 2025.6.4
# =============================================

# ------------------------------------------------
# Function: Get-AllUsers
# Purpose: Return all enabled AD users with full properties
# Expected: Full [ADUser] object list
# ------------------------------------------------
function Get-AllUsers {
    return Get-ADUser -Filter * -Properties * | Where-Object { $_.Enabled -eq $true }
}

# ------------------------------------------------
# Function: Get-AllGroups
# Purpose: Return all AD groups with descriptions
# Expected: Full [ADGroup] object list
# ------------------------------------------------
function Get-AllGroups {
    return Get-ADGroup -Filter * -Properties Description
}

# ------------------------------------------------
# Function: Get-OUPath
# Purpose: Extract OU path from user DN
# Expected: Clean OU path
# ------------------------------------------------
function Get-OUPath {
    param ([string]$dn)
    return ($dn -split ",", 2)[1]
}

# ------------------------------------------------
# Function: Get-NestedGroups
# Purpose: Recursively resolve nested group memberships
# Expected: Unique list of group names
# ------------------------------------------------
function Get-NestedGroups {
    param ([string]$groupDN)
    try {
        $group = Get-ADGroup $groupDN
        $nested = @()
        $subs = Get-ADGroupMember $group -Recursive | Where-Object { $_.objectClass -eq "group" }
        foreach ($sub in $subs) {
            $nested += $sub.Name
        }
        return $nested
    } catch {
        return @()
    }
}

# ------------------------------------------------
# Function: Describe-Group
# Purpose: Human-readable translation of group purpose
# Expected: Descriptive string
# ------------------------------------------------
function Describe-Group {
    param ([string]$GroupName)

    switch -Wildcard ($GroupName.ToLower()) {
        "*admin*"      { return "$GroupName → Admin level group" }
        "*read*"       { return "$GroupName → Read-only access" }
        "*write*"      { return "$GroupName → Write permission group" }
        "*ftp*"        { return "$GroupName → FTP system binding" }
        "*powerbi*"    { return "$GroupName → BI publishing group" }
        default        { return "$GroupName → [Unknown purpose]" }
    }
}

# ------------------------------------------------
# Function: Get-ACLsForUser
# Purpose: Return ACL entries on known shares referencing user
# Expected: List of share and permission mappings
# ------------------------------------------------
function Get-ACLsForUser {
    param ([string]$sam)

    $results = @()
    foreach ($path in $script:knownShares) {
        try {
            $acl = Get-Acl -Path $path
            foreach ($ace in $acl.Access) {
                if ($ace.IdentityReference -match $sam) {
                    $results += "$($path) : $($ace.FileSystemRights)"
                }
            }
        } catch {
            $results += "$path : [Access Denied or Not Found]"
        }
    }
    return $results
}

# ------------------------------------------------
# Function: Get-MappedDrives
# Purpose: Lookup mapped drives from user profile (placeholder)
# Expected: List of drive mappings
# ------------------------------------------------
function Get-MappedDrives {
    param ([string]$SamAccountName)

    try {
        # Placeholder for registry pull
        return @("MappedDrive: [Simulated] Requires registry access")
    } catch {
        return @("Error resolving mapped drives for $SamAccountName")
    }
}

# ------------------------------------------------
# Function: Get-ExchangeBindings
# Purpose: Placeholder for Exchange shared mailbox bindings
# Expected: List of shared mailboxes or N/A
# ------------------------------------------------
function Get-ExchangeBindings {
    param ([string]$SamAccountName)
    return @("ExchangeBinding: [Simulated or requires remote Exchange session]")
}

# ------------------------------------------------
# Function: Get-GPOsForUser
# Purpose: Return placeholder GPOs per user's OU
# Expected: List of GPO names or message
# ------------------------------------------------
function Get-GPOsForUser {
    param ([string]$DistinguishedName)

    try {
        $ou = ($DistinguishedName -split ",", 2)[1]
        return @("GPO Link: [Simulated for OU $ou]") # Placeholder
    } catch {
        return @("GPO Resolution Failed")
    }
}

# ------------------------------------------------
# Function: Score-RiskProfile (disabled for now)
# Purpose: Placeholder only. Scoring deactivated in full audit mode.
# ------------------------------------------------
function Score-RiskProfile {
    param (
        [object]$user,
        [array]$groupNames,
        [array]$patterns
    )

    return [PSCustomObject]@{
        Score   = 0
        Reasons = @("Scoring disabled for global audit mode")
    }
}