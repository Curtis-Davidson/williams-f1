# ---------------------------------------------------------------
# Script Name: Get-LogonAuditReport.ps1
# Description: Extracts Security Log Event 4624 ("Logon Success")
#              over the last 30 days, showing key details such as
#              username, logon type, source IP, elevation status.
#              Outputs to CSV and HTML for compliance and audit.
# Author: Curtis-Davidson for WilliamsF1 | Urbantek
# ---------------------------------------------------------------

# C:\AuditScripts\Security\Get-LogonAuditReport.ps1
# Purpose: Extract all user logon activity (Event ID 4624) from last 30 days, output to CSV + HTML

# Define variables

# === STEP 1: Setup ===
$DaysBack = 30
$LogonEvents = @()
$StartDate = (Get-Date).AddDays(-$DaysBack)
$OutputDir = "C:\AuditScripts\Output"
$dateStamp = Get-Date -Format 'yyyyMMdd_HHmm'

New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

# === STEP 2: LogonType Translation Table ===
$logonTypeMap = @{
    0  = "System"
    2  = "Interactive"
    3  = "Network"
    4  = "Batch"
    5  = "Service"
    7  = "Unlock"
    8  = "NetworkCleartext"
    9  = "NewCredentials"
    10 = "RemoteInteractive"
    11 = "CachedInteractive"
    12 = "CachedRemoteInteractive"
    13 = "CachedUnlock"
}

# === STEP 3: Query Security Log (Event ID 4624) ===
$FilterHash = @{
    LogName   = 'Security'
    ID        = 4624
    StartTime = $StartDate
}
$Events = Get-WinEvent -FilterHashtable $FilterHash -ErrorAction SilentlyContinue

# === STEP 4: Process Each Event Record ===
foreach ($event in $Events) {
    $Xml = [xml]$event.ToXml()
    $rawLogonType = $Xml.Event.EventData.Data | Where-Object { $_.Name -eq "LogonType" } | Select-Object -ExpandProperty '#text'
    $translatedLogonType = $logonTypeMap[$rawLogonType] | ForEach-Object { if ($_ -eq $null) { "Unknown ($rawLogonType)" } else { "$_ ($rawLogonType)" } }

    $Data = @{
        TimeCreated        = $event.TimeCreated
        TargetUserName     = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetUserName"} | Select-Object -ExpandProperty '#text'
        TargetDomainName   = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetDomainName"} | Select-Object -ExpandProperty '#text'
        LogonType          = $translatedLogonType
        WorkstationName    = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "WorkstationName"} | Select-Object -ExpandProperty '#text'
        IpAddress          = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "IpAddress"} | Select-Object -ExpandProperty '#text'
        ElevatedToken      = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "ElevatedToken"} | Select-Object -ExpandProperty '#text'
        ProcessName        = $Xml.Event.EventData.Data | Where-Object {$_.Name -eq "ProcessName"} | Select-Object -ExpandProperty '#text'
    }

    $LogonEvents += New-Object PSObject -Property $Data
}

# === STEP 5: Define Output Paths ===
$CsvPath  = Join-Path $OutputDir "LogonAuditReport_$dateStamp.csv"
$HtmlPath = Join-Path $OutputDir "LogonAuditReport_$dateStamp.html"

# === STEP 6: Export to CSV ===
$LogonEvents | Sort-Object TimeCreated -Descending |
        Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

# === STEP 7: Export to HTML ===
$LogonEvents | Sort-Object TimeCreated -Descending |
        ConvertTo-Html -Property TimeCreated,TargetUserName,TargetDomainName,LogonType,WorkstationName,IpAddress,ElevatedToken,ProcessName `
                  -Title "30 Day Logon Audit Report" |
        Out-File -FilePath $HtmlPath -Encoding UTF8

# === STEP 8: Final Message ===
Write-Output " Logon audit complete."
Write-Output " CSV Report:  $CsvPath"
Write-Output " HTML Report: $HtmlPath"