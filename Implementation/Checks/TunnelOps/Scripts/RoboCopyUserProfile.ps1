# Use this ONLY if you want the destination to match source exactly (deletes extras):
robocopy "C:\Backup\TunnelOps" "C:\Users\shr-tunops-wtm" `
  /MIR /COPY:DAT /DCOPY:DAT /XJ /ZB /R:1 /W:1 /MT:16 /NP /NFL /NDL `
  /XD "AppData\Local\Microsoft\Credentials" `
      "AppData\Local\Microsoft\Crypto" `
      "AppData\Local\Temp" `
      "AppData\Local\Packages" `
      "AppData\LocalLow" `
      "AppData\Local\Microsoft\WindowsApps" `
      "FCCCache" `
  /XF "NTUSER.DAT" "NTUSER.DAT.LOG*" "NTUSER.DAT{*}" `
      "UsrClass.dat" "UsrClass.dat.LOG*" "UsrClass.dat{*}" `
      "SAM" "SECURITY" "SYSTEM" "SOFTWARE" `
      "*.lck" "*.lock" "*.tmp" "*.temp" `
  /LOG:"C:\Temp\TunnelOps_to_shr-tunops-wtm_RESTORE_MIR.log"