





**PIV BATCH START**
--------------------

@echo off
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 8
START "Robots Rebel Base" "C:\Program Files\ILA_5150\Motoman W Controller\Motoman_DX100.exe" -remoteServer -restore 0
TIMEOUT /T 2
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 2
START "Laser Rebel Base" "C:\Program Files (x86)\ILA_5150\Laser Control\lasercontrol2.exe" -remoteServer -restore 0
TIMEOUT /T 2
START "Laser Flaps Rebel Base" "C:\Program Files (x86)\ILA_5150\Flappers\flappers.exe" -remoteServer -restore 0
TIMEOUT /T 2
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 2
START "Scheduler" "C:\Program Files\ILA_5150\PIV Scheduler Master\PIVScheduler.exe"
TIMEOUT /T 2
START "Synchroniser" "C:\Program Files (x86)\ILA_5150\SigmaX\SigMaX.exe" -remoteServer
TIMEOUT /T 2
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 2
START "Tilts" "C:\Program Files (x86)\ILA_5150\Trvman\TrvMan.exe" -remoteServer -restore 0
TIMEOUT /T 2
START "Robots Dark Side" "C:\Program Files\ILA_5150\Motoman W Controller\Motoman_DX100.exe" -remoteServer -restore 1
TIMEOUT /T 2
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 2
START "Laser Dark Side" "C:\Program Files (x86)\ILA_5150\Laser Control\lasercontrol2.exe" -remoteServer -restore 1
TIMEOUT /T 2
START "Laser Flaps Dark Side" "C:\Program Files (x86)\ILA_5150\Flappers\flappers.exe" -remoteServer -restore 1
TIMEOUT /T 2
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 2
START "SystemManager" "C:\Program Files\ILA_5150\PIV System Manager\system_w.exe" -remoteServer -restore



**MOUNT PIV Systems**
---------------------

net use s: \\smb.wf1-isil01.factory.wf1\pivdata
net use m: \\w10172\c$
net use n: \\w10172\d$



**UPDATE iLA FILES from W10172**
--------------------------------

\\w10172\c$\Program Files\ILA_5150
\\w10172\c$\Program Files (x86)\ILA_5150
\\w10172\c$\Users\TunnelOps\AppData\Roaming\ILA_5150
\\w10172\c$\Users\TunnelOps\AppData\Roaming\ILA GmbH
\\w10172\c$\ProgramData\ILA_5150
\\w10172\d$\DB Files
\\w10172\d$\TRVman_setting
\\w10172\d$\Reference_Images
\\w10172\d$\par_Files
\\w10172\d$\Masks
\\w10172\d$\EOS_Settings
\\w10172\d$\cfg_Files
\\w10172\d$\Calib



**START ALL CAMERAS**
---------------------

@echo off
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 10
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 5
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 5
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 5
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 5
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 5


**START ROOF CAMERAS**
----------------------

@echo off
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1
TIMEOUT /T 10
START "ILA_Camware" "C:\Users\TunnelOps\AppData\Local\Programs\ILA_5150\ILACamware\ILACamWare_x64.exe" -remoteServer -log -eoslog -cmax1









