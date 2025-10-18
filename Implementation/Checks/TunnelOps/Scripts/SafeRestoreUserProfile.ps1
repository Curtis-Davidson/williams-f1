# Run as Admin while 'shr-tunops-wtm' is logged off; browsers closed
robocopy "C:\Backup\TunnelOps" "C:\Users\shr-tunops-wtm" `
  /E /COPY:DAT /DCOPY:DAT /XJ /ZB /R:1 /W:1 /MT:16 /NP /NFL /NDL `
  /XD "AppData\Local\Microsoft\Credentials" `
      "AppData\Local\Microsoft\Crypto" `
      "AppData\Local\Temp" `
      "AppData\Local\Packages" `
      "AppData\LocalLow" `
      "AppData\Local\Microsoft\WindowsApps" `
      "AppData\Local\Microsoft\Teams" `
      "AppData\Local\ConnectedDevicesPlatform" `
      "AppData\Local\TileDataLayer" `
      "AppData\Local\Microsoft\Windows\INetCache" `
      "AppData\Local\Microsoft\Windows\WebCache" `
      "AppData\Local\Microsoft\Windows\Caches" `
      "FCCCache" `
      "Cache" "Code Cache" "GPUCache" "Service Worker" "Crashpad" "ShaderCache" `
  /XF "NTUSER.DAT" "NTUSER.DAT.LOG*" "NTUSER.DAT{*}" `
      "UsrClass.dat" "UsrClass.dat.LOG*" "UsrClass.dat{*}" `
      "SAM" "SECURITY" "SYSTEM" "SOFTWARE" `
      "LOCK" "*.lck" "*.lock" "*.tmp" "*.temp" "*.log" `
  /LOG:"C:\Temp\TunnelOps_to_shr-tunops-wtm_RESTORE.log"