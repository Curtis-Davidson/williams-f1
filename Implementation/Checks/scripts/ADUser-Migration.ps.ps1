robocopy "C:\Backup\TunnelOps" "C:\Users\shr-tunops-dia" /MIR /COPY:DAT /XJ /R:1 /W:1 `
/XD "AppData\Local\Microsoft\Credentials" `
    "AppData\Local\Microsoft\Crypto" `
    "AppData\Local\Temp" `
    "AppData\Local\Packages" `
    "AppData\LocalLow" `
/XF "NTUSER.DAT.LOG*" "UsrClass.dat.LOG*" "NTUSER.DAT{*}" `
    "SAM" "SECURITY" "SYSTEM" "SOFTWARE" `
/LOG:C:\Temp\TunnelOps_to_shr-tunops-dia_safe.log