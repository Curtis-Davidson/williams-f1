RULE 6 IMPLEMENTATION: CAD RDP LOCKDOWN – TUNNELOPS TEAM

Objective:
Only 10 users in TunnelOps can RDP into exactly 3 CAD machines — nothing more.

⸻

1. Create Dedicated RDP Access Group

 Exact Command:

New-ADGroup -Name "wt2-cad-RDP" `
            -SamAccountName "wt2-cad-RDP" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path "OU=Security Groups,OU=TunnelOps,OU=Factory,DC=williamsf1,DC=com" `
            -Description "RDP access to WT2 CAD machines for TunnelOps team (3 machines only)"


2. Add the 10 Approved Users to the Group

 Exact Command:

$users = @(
    "steve.buckley",
    "kevin.morris",
    "peter.watson",
    "duncan.martin",
    "richard.lane",
    "sophie.james",
    "tony.fields",
    "linda.ashley",
    "mark.evans",
    "ian.hobbs"
)

foreach ($u in $users) {
    Add-ADGroupMember -Identity "wt2-cad-RDP" -Members $u
}


3. Add the Group to the Local “Remote Desktop Users” Group on the 3 CAD Machines

 Per Machine Command (Run as Admin):

Add-LocalGroupMember -Group "Remote Desktop Users" -Member "WILLIAMS\wt2-cad-RDP"

Repeat for each CAD machine:
CAD-WT2-01, CAD-WT2-02, CAD-WT2-03

4. Block All Other Logins to Those Machines Except IT Admins

 Use GPO or Local Security Policy (if no central GPO):
•	On each CAD machine:
•	Open secpol.msc
•	Go to:
•	Local Policies → User Rights Assignment
•	Allow log on through Remote Desktop Services
•	Replace any wildcard groups (e.g., Domain Users) with:
•	WILLIAMS\wt2-cad-RDP
•	Domain Admins (or your IT admin group)

 This ensures only your RDP group and IT can RDP in.

⸻

5. Disable Unwanted Interactive Logins (Optional but Recommended)

To prevent anyone from logging in locally (keyboard/mouse) except admins:
•	Local Policy → Deny log on locally
•	Add wt2-cad-RDP

 This prevents someone walking up and logging in, while still allowing remote RDP for TunnelOps.

⸻

6. Audit and Lock Visibility

Ensure the CAD machines:
•	Are not part of general access groups
•	Are in their own OU if GPO targeting is needed
•	Have RDP firewall ports open internally via Group Policy

Verify with:

Get-LocalGroupMember -Group "Remote Desktop Users"

and confirm only:
•	WILLIAMS\wt2-cad-RDP
•	DOMAIN\Admins


Final Test Instruction

On a TunnelOps user’s machine:
1.	Attempt to RDP into one of the CAD boxes — should succeed
2.	Attempt from a user not in the group — should fail
3.	Confirm login events in the CAD machine’s Event Viewer under:
•	Security logs → Event ID 4624 (successful logon) or 4625 (failed)

Summary Snapshot

AD Group Name
wt2-cad-RDP
Users Allowed
10 named TunnelOps engineers
Machines Affected
CAD-WT2-01, CAD-WT2-02, CAD-WT2-03
Login Type Allowed
RDP only
Local Group Membership
Remote Desktop Users
Logon Restriction
Local login denied (optional)
Audit Visibility
Enabled via Event Viewer




Paths


C:
HOMEPATH                       \Users\adminpdavidson
IGCCSVC_DB                     AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAxOhYeutYNUqBRGH6Az9VGAQAAAACAAAAAAAQZgAAAAEAACAAAAAaV...
JAVA_HOME                      C:\PLM\JAVA\X64\
JRE_HOME                       C:\PLM\JAVA\X64
JT_OGL41                       1
LOCALAPPDATA                   C:\Users\adminpdavidson\AppData\Local
LOGONSERVER                    \\FACT-DC01
NUMBER_OF_PROCESSORS           24
OneDrive                       C:\Users\adminpdavidson\OneDrive
OS                             Windows_NT
Path                           C:\PLM\JAVA\X64\bin\;C:\PLM\JAVA\X86\bin\;C:\Program Files (x86)\Common Files\Oracle\...
PATHEXT                        .COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL
PROCESSOR_ARCHITECTURE         AMD64
PROCESSOR_IDENTIFIER           Intel64 Family 6 Model 151 Stepping 2, GenuineIntel
PROCESSOR_LEVEL                6
PROCESSOR_REVISION             9702
ProgramData                    C:\ProgramData
ProgramFiles                   C:\Program Files
ProgramFiles(x86)              C:\Program Files (x86)
ProgramW6432                   C:\Program Files
PSModulePath                   C:\Users\adminpdavidson\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsP...
PUBLIC                         C:\Users\Public
SESSIONNAME                    RDP-Tcp#47
SN_AGENT_HOME_DIR              C:\Program Files\ServiceNow\agent-client-collector\
SPLM_LICENSE_SERVER            7000@FACT-LICA,7000@FACT-LICB,7000@FACT-LICC
SystemDrive                    C:
SystemRoot                     C:\windows
TCVIS_CLUSTER_PATH             C:\PLM\TC12\Visualization\Products\Mockup\VisView.exe
TEMP                           C:\Users\ADMINP~1\AppData\Local\Temp
TMP                            C:\Users\ADMINP~1\AppData\Local\Temp
UATDATA                        C:\windows\CCM\UATData\D9F8C395-CAB8-491d-B8AC-179A1FE1BE77
UGII_3DCONNEXION_DIR           C:\Program Files\3Dconnexion\3DxWare\3DxNX\ugii_dir\
UGII_3DCONNEXION_DIR32         C:\Program Files\3Dconnexion\3DxWare\3DxNX\ugii_dir32\
UGII_BASE_DIR                  C:\PLM\NX_2007_Series
UGII_LANG                      english
USERDNSDOMAIN                  FACTORY.WF1
USERDOMAIN                     FACTORY
USERDOMAIN_ROAMINGPROFILE      FACTORY
USERNAME                       adminpdavidson
USERPROFILE                    C:\Users\adminpdavidson
windir                         C:\windows
ZES_ENABLE_SYSMAN              1


portal.bat launches TeamCentre

@echo off
rem

setlocal

rem TPR is short for TC_PORTAL_ROOT to reduce command line length
title Teamcenter Rich Client

call "C:\PLM\TC12\Tc12407\install\tem_init.bat"

set TPR=C:\PLM\TC12\Tc12407\portal
if not defined FMS_HOME set FMS_HOME=C:\PLM\TC12\Tc12407\tccs

rem use AUX_PATH env var for any additional required paths
rem save original path for external applications
set ORIGINAL_PATH=%PATH%
rem for optimal startup performance, keep the PATH length at a minimum
set PATH=%SYSTEMROOT%\system32;%FMS_HOME%\bin;%FMS_HOME%\lib;%TPR%;%AUX_PATH%

set JAVA_HOME=%TC_JRE_HOME%
set JRE_HOME=%TC_JRE_HOME%


:start_portal

cd /d %TPR%

set CLASSPATH=.;

set VM_XMX=8G

set VM_XMS=8G



rem Set DJIPJL_VMARG environment variable

IF EXIST "%TPR%\djipjl\setenv.cmd" call "%TPR%\djipjl\setenv.cmd"



@echo Starting Teamcenter Rich Client...

start Teamcenter.exe %* -vm "%JRE_HOME%\bin\javaw.exe" -vmargs -Xmx%VM_XMX% -Xms%VM_XMS% -Xverify:none -XX:SurvivorRatio=6 -XX:+UseParallelGC -XX:+DisableExplicitGC -Dexpressioncache.enable=Y -XX:MaxPermSize=512m -Xbootclasspath/a:"%JRE_HOME%\lib\plugin.jar";"%JRE_HOME%\lib\deploy.jar";"%JRE_HOME%\lib\javaws.jar"



TeamCentre Members

Go for all of ATF:

Neil hayes
Mich Hackwood
Anna Perry
Keith Forsythe
Alex Wibawa
Thomas Sagar
Edward Ball
James Busfield
Calum Maciver
Ben Stokes
Christina Sullivan
Andrew Wilkie
Luke Deacon
Ben Hansen
Harrison Towell
Conor Crickmore





