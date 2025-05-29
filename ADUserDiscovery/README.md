# ADUserDiscovery – WilliamsF1 Enterprise Audit Script

## Purpose
Performs Active Directory user discovery, including:
- Group Membership
- OU Path & GPO Inheritance
- ACL Enumeration
- MFA Status (via Defender/Entra hybrid)
- Last Logon Tracking
- Simulation of Account Disable Impact

## Rule 6 Execution

**Command**
```bash
make.ps1 run-user-discovery -Username "target.user"