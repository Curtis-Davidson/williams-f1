Can It Be Used on Multiple Workstations in a Department?

Yes — but with modifications or the right deployment method.

 Option 1: Manual Deployment (Single Run Per Host)

You run the script locally on each target machine — either manually, via login script, or scheduled task.
Good for small sets or test departments.

 Option 2: Remote Execution via PowerShell Remoting (Enterprise Grade)

With a one-line wrapper, this becomes multi-machine capable.

You can use something like:

-------------

$targets = @("WS101", "WS102", "WS103")
foreach ($machine in $targets) {
    Invoke-Command -ComputerName $machine -FilePath "C:\AuditScripts\scripts\williamsf1-workstation-audit.ps1"
}

--------------

Requirements:
	•	PowerShell Remoting enabled (WinRM)
	•	Admin rights on remote hosts
	•	Unblocked firewall for port 5985 (default)
	•	Network profile not set to “Public”

 ---

 Can It Be Run Over the Network Without Installing Anything?

Not directly unless:
	1.	The script is copied temporarily via SMB share or pushed via SCCM / Intune
	2.	Remoting is enabled and you trust the network context
	3.	You redesign the script to query remote machines from a central node rather than run locally

⸻

 Modular Upgrade (Recommended)

We can split your logic into:

##  Modular Upgrade (Recommended)

We can split your logic into:

| Component           | Mode                                      | Comment                                  |
|---------------------|-------------------------------------------|------------------------------------------|
| **Profile Enumeration** | Remote-capable via `Get-CimInstance`       |  |
| **Event Log Pulling**   | Use `Get-WinEvent -ComputerName`           |    Needs admin access |
| **Mapped Drives**       | Local-only unless remote session           |    Won’t work without user session |
| **Rights/GPO**          | Can extract via `secedit` remotely         |   |
| **App Inventory**       | `Invoke-Command` or remote reg read        |   |

---

##  Final Answer

| Question                                         | Answer                                                           |
|--------------------------------------------------|------------------------------------------------------------------|
| **Can it audit a department of machines?**       | **Yes**, with remote execution or deployment                    |
| **Can it be run from your machine to others?**   | **Yes**, via `Invoke-Command` or script distribution            |
| **Is it safe to run?**                           | **Yes**, read-only queries (registry, WMI, event log)           |
| **Can we make it centralised and scheduled?**    | **Yes**, using a PowerShell job scheduler or `Task Scheduler` GPO |
