ADGroupDiscovery.ps1 — What It Does

Tracks Active Directory group data with full export and change tracking:
•	Group metadata (name, description, type, scope)
•	All resolved members (recursive expansion)
•	ACLs on the group object
•	Markdown + HTML reports
•	JSON snapshot cache + diff detection
•	Optional future use in Jupyter post-analysis


Rule 6 Instruction Set for ADGroupDiscovery.ps1


1. Exact Command
.\ADGroupDiscovery.ps1 -GroupName "Finance-UK"


2. Full File Path
/scripts/ADGroupDiscovery.ps1

3. Directory Creation (if needed)
New-Item -Path "../exports/<GroupName>" -ItemType Directory -Force

4. File Creation/Edit Command
   code /scripts/ADGroupDiscovery.ps1


5. Then verify:
•	Markdown: ..\exports\Finance-UK\group_report_<timestamp>.md
•	HTML: ..\exports\Finance-UK\group_report_<timestamp>.html
•	Diff (if any): ..\exports\Finance-UK\diff_summary.md
•	Snapshot: ..\exports\Finance-UK\group_snapshot_<timestamp>.json

