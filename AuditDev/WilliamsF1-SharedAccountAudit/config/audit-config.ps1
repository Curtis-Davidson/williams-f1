# =============================================
# CONFIG: Williams F1 AD Full Discovery Audit
# Author: Curtis-Davidson & G
# Version: 2025.6.4 - No Scoring Mode
# Author: Paul R Davidson & Urbantek
# =============================================

# Timestamp format (UK)
$ts = Get-Date -Format "dd-MM-yyyy_HH-mm"

# Output paths
$OutDir   = "$PSScriptRoot\..\reports"
$csvOut   = "$OutDir\AD-FullAudit-$ts.csv"
$mdOut    = "$OutDir\AD-FullAudit-$ts.md"
$htmlOut  = "$OutDir\AD-FullAudit-$ts.html"
$jsonOut  = "$OutDir\AD-FullAudit-$ts.json"
$log      = "$OutDir\AD-FullAudit-$ts.log"

# Shared account detection patterns
$patterns = @(
    "svc-", "ftp", "vault", "modelshop", "cnc", "cad", "preactor", "wtplanner",
    "sql_", "tracker", "printer", "powerbi", "telemetry", "robot", "windtunnel",
    "3dprint", "automation", "ebecs", "sap_", "ncr", "datahub"
)

# Known share anchors for ACL analysis
$knownShares = @(
    "\\factory\wf1\Department1",
    "\\factory\wf1\Department2",
    "\\factory\wf1\cncprogs",
    "\\fozzie\department1",
    "\\fozzie\department2",
    "\\fozzie\designdata",
    "\\wf1-isil01\inspection",
    "\\wf1-isil01\Accounts"
)

# Toggle advanced data collection
$CollectExchange = $true
$CollectLogonScripts = $true
$CollectProfiles = $true
$CollectRegistry = $false  # set true if registry scanning module active