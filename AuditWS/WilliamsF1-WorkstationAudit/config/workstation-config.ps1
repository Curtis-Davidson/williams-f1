Set-Content -Path "C:\AuditDev\WilliamsF1-WorkstationAudit\config\workstation-config.ps1" -Encoding UTF8 -Value @"
# =============================================
# CONFIG: Williams F1 Workstation Audit v1.0
# Author: Curtis-Davidson & Urbantek
# =============================================

# Timestamp (UK Format)
\$ts = Get-Date -Format "dd-MM-yyyy_HH-mm"

# Output Directory
\$OutDir   = "\$PSScriptRoot\..\reports-polished"
\$csvOut   = "\$OutDir\WorkstationAudit-\$ts.csv"
\$mdOut    = "\$OutDir\WorkstationAudit-\$ts.md"
\$htmlOut  = "\$OutDir\WorkstationAudit-\$ts.html"
\$jsonOut  = "\$OutDir\WorkstationAudit-\$ts.json"
\$log      = "\$OutDir\WorkstationAudit-\$ts.log"

# Snapshot Path
\$snapDir  = "\$PSScriptRoot\..\snapshots"
\$snapFile = "\$snapDir\WorkstationAudit-\$ts.json"
"@