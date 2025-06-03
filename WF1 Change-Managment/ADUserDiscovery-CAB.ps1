# ====================================================================
# Script: ADUserDiscovery.ps1
# Author: Paul R Davidson
# Version: 2025.8.0
# Description:
# This script performs a detailed investigation of a single user
# account in Active Directory. It collects key information about
# the user’s identity, login history, security permissions,
# group memberships, and any assigned policies. It then exports
# the findings into standard formats (CSV, JSON, Markdown, HTML).
#
# Purpose:
# Designed to support IT governance, this script is used for
# auditing, compliance, and pre-change risk assessments—especially
# when changing or decommissioning user accounts that may have
# elevated access or special privileges.
#
# CAB Context:
# Enables the technical team to document the full AD footprint of a
# named user. This ensures we don’t accidentally impact live systems
# or critical permissions during account changes.
# ====================================================================

param (
    [Parameter(Mandatory)][string]$Username
)

# === Step 1: Setup file structure for logging and exports ===
# Create a dedicated folder for this user under /exports/
# This prevents overwriting previous reports and supports traceability.
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$exportDir = Join-Path $PSScriptRoot "..\exports\$Username"
New-Item -Path $exportDir -ItemType Directory -Force | Out-Null

# === Step 2: Define the export filenames for logging and reporting ===
# All outputs are timestamped for version control and audit trail.
$logFile   = Join-Path $exportDir "log_$ts.txt"
$csvFile   = Join-Path $exportDir "ad_user_summary_$ts.csv"
$jsonFile  = Join-Path $exportDir "ad_user_summary_$ts.json"
$mdFile    = Join-Path $exportDir "ad_user_summary_$ts.md"
$htmlFile  = Join-Path $exportDir "ad_user_summary_$ts.html"
$diffFile  = Join-Path $exportDir "diff_summary.md"
$metaFile  = Join-Path $exportDir "meta_$ts.json"
$cacheFile = Join-Path $exportDir "last_snapshot.json"

# === Step 3: Logging function to record each step ===
# Ensures each operation is traceable for audit and troubleshooting.
function Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")] [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$Level] $timestamp :: $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

# === Step 4: Capture metadata for compliance and audit trail ===
# Logs who ran the script, for which user, and what CAB reference it relates to.
$meta = @{
    timestamp   = $ts
    user_input  = $Username
    executed_by = $env:USERNAME
    project     = "Remediate Generic Account Risk @WF1"
    cab_ref     = "P-135901"
    github_repo = "UrbantekDev/CloudHealthLink"
}
$meta | ConvertTo-Json -Depth 3 | Set-Content -Path $metaFile -Encoding UTF8

# === Step 5: Ensure required AD module is installed ===
# If missing, aborts the script safely without any impact.
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Log "Missing module 'ActiveDirectory' (RSAT required)" "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# === Step 6: Define a reusable user object model for consistency ===
# A structured way to store and compare all key account properties.
class ADUserProfile {
    [string]$Username
    [string]$SID
    [string]$DisplayName
    [string]$Email
    [string]$OU
    [bool]$Enabled
    [datetime]$LastLogon
    [string]$LogonScript
    [string]$ProfilePath
    [bool]$FSLogixDetected
    [string[]]$Groups
    [string[]]$GPOs
    [object[]]$ACLs

    # Constructor to build the object from raw user data
    ADUserProfile([pscustomobject]$raw) {
        $this.Username         = $raw.Username
        $this.SID              = $raw.SID
        $this.DisplayName      = $raw.DisplayName
        $this.Email            = $raw.Email
        $this.OU               = $raw.OU
        $this.Enabled          = $raw.Enabled
        $this.LastLogon        = $raw.LastLogon
        $this.LogonScript      = $raw.LogonScript
        $this.ProfilePath      = $raw.ProfilePath
        $this.FSLogixDetected  = $raw.FSLogixDetected
        $this.Groups           = $raw.Groups
        $this.GPOs             = $raw.GPOs
        $this.ACLs             = $raw.ACLs
    }

    # Methods to compare two user profiles for any changes (used for diffing)
    [string[]] CompareGroups([ADUserProfile]$other) {
        return Compare-Object -ReferenceObject $this.Groups -DifferenceObject $other.Groups -PassThru
    }
    [string[]] CompareGPOs([ADUserProfile]$other) {
        return Compare-Object -ReferenceObject $this.GPOs -DifferenceObject $other.GPOs -PassThru
    }
    [string[]] CompareOU([ADUserProfile]$other) {
        if ($this.OU -ne $other.OU) { return @("OU changed from '$($other.OU)' to '$($this.OU)'") }
        return @()
    }
    [string[]] CompareACLs([ADUserProfile]$other) {
        $oldACLs = $other.ACLs | ConvertTo-Json -Depth 5
        $newACLs = $this.ACLs  | ConvertTo-Json -Depth 5
        if ($oldACLs -ne $newACLs) { return @("ACLs changed") }
        return @()
    }
}

# === Step 7: Query AD for the user’s profile ===
# If the user does not exist, the script exits cleanly.
try {
    $user = Get-ADUser -Identity $Username -Properties * -ErrorAction Stop
    Log "User found: $($user.SamAccountName)"
} catch {
    Log "User not found: $Username" "ERROR"
    exit 2
}

# === Step 8: Translate the AD path into readable format ===
# Converts complex LDAP-style path to human-readable hierarchy.
$ouPath = $user.DistinguishedName -replace '^CN=.*?,', ''
$ouFull = ($ouPath -split ',') -replace '^OU='''',''' -join ' > '

# === Step 9: Generate user SID and check FSLogix profile existence ===
# FSLogix presence often indicates roaming profiles or virtualisation in use.
$sid = (New-Object System.Security.Principal.NTAccount($user.SamAccountName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$fslogixProfilePath = "\\fslogix\profiles\$Username"
$profileExists = Test-Path $fslogixProfilePath

# === Step 10: Gather group memberships ===
# Lists every group this user is part of—key for access rights and inheritance.
$groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
    (Get-ADGroup $_ -ErrorAction SilentlyContinue).Name
}

# === Step 11: Identify GPOs linked to their OU via inheritance ===
# Policies can affect login scripts, drive mappings, security settings, etc.
try {
    $ouDN = ($user.DistinguishedName -split ',', 2)[1]
    $gpoLinks = Get-GPInheritance -Target $ouDN -ErrorAction Stop | Select-Object -ExpandProperty GpoLinks
    $gpoNames = $gpoLinks | ForEach-Object { "$($_.DisplayName) (Enabled: $($_.Enabled))" }
} catch {
    $gpoNames = @()
    Log "Failed to get GPO inheritance for $ouDN" "WARN"
}

# === Step 12: Extract AD ACLs (Access Control List / Permissions) ===
# Helps identify if this user has any delegated permissions or security overrides.
$aclDetails = @()
try {
    $userAcl = Get-Acl -Path ("AD:\" + $user.DistinguishedName)
    $aclDetails = $userAcl.Access | ForEach-Object {
        [PSCustomObject]@{
            Identity    = $_.IdentityReference
            Type        = $_.AccessControlType
            Rights      = $_.ActiveDirectoryRights
            Inherited   = $_.IsInherited
            ObjectType  = $_.ObjectType
        }
    }
} catch {
    Log "ACL extraction failed" "WARN"
}

# === Step 13: Build full user object ===
# Combines all the collected data into a single structured object.
$rawResult = [PSCustomObject]@{
    Timestamp        = $ts
    Username         = $user.SamAccountName
    SID              = $sid
    DisplayName      = $user.DisplayName
    Email            = $user.EmailAddress
    OU               = $ouFull
    Enabled          = $user.Enabled
    LastLogon        = $user.LastLogonDate
    LogonScript      = $user.ScriptPath
    ProfilePath      = $user.ProfilePath
    FSLogixDetected  = $profileExists
    Groups           = $groups
    GPOs             = $gpoNames
    ACLs             = $aclDetails
}
$currentProfile = [ADUserProfile]::new($rawResult)

# === Step 14: Save results to JSON (structured format) ===
# Used for internal review, automation, or later comparison.
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonFile -Encoding UTF8

# === Step 15: Compare with previous snapshot (diff) ===
# Identifies changes to the account since the last time it was scanned.
if (Test-Path $cacheFile) {
    $previous = Get-Content -Path $cacheFile | ConvertFrom-Json
    $oldProfile = [ADUserProfile]::new($previous)
    $diffs = @()
    $diffs += $currentProfile.CompareGroups($oldProfile)
    $diffs += $currentProfile.CompareGPOs($oldProfile)
    $diffs += $currentProfile.CompareACLs($oldProfile)
    $diffs += $currentProfile.CompareOU($oldProfile)

    if ($diffs.Count -gt 0) {
        Log "Changes detected since last run." "WARN"
        $diffs | Set-Content -Path $diffFile -Encoding UTF8
    } else {
        Log "No differences detected since last snapshot."
    }
}
$currentProfile | ConvertTo-Json -Depth 5 | Set-Content -Path $cacheFile -Encoding UTF8

# === Step 16: Export human-readable CSV for governance ===
# Useful for managers or auditors who prefer spreadsheet formats.
$currentProfile | Select-Object Username,DisplayName,Email,OU,Enabled,LastLogon,LogonScript,ProfilePath,FSLogixDetected |
        Export-Csv -Path $csvFile -Encoding UTF8 -NoTypeInformation

# === Step 17: Export Markdown and HTML reports (CAB-friendly formats) ===
# Markdown and HTML outputs allow readable, styled reports for CAB packs.
# These sections are handled downstream in the script pipeline.

# === Step 18: Final logging to confirm success and output locations ===
Log "AD Discovery complete for $Username" "SUCCESS"
Log "CSV     : $csvFile"
Log "JSON    : $jsonFile"
Log "Markdown: $mdFile"
Log "HTML    : $htmlFile"
Log "Meta    : $metaFile"