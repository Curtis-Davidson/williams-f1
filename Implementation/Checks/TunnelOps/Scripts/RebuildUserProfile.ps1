# E) Copy data in (safe; no ACLs; no registry hives; no junk). Run as Admin, with the user logged off.
robocopy "C:\Backup\TunnelOps" "C:\Users\shr-tunops-wtm" `
  /E /COPY:DAT /DCOPY:DAT /XJ /ZB /R:1 /W:1 /MT:16 /NP /NFL /NDL `
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
  /LOG:"C:\Temp\TunnelOps_to_shr-tunops-wtm_REBUILD.log"

# F) Give the user full rights to their (new) profile just in case
takeown /F "C:\Users\shr-tunops-wtm" /R /D Y
icacls "C:\Users\shr-tunops-wtm" /grant "shr-tunops-wtm:(OI)(CI)F" /T /C
icacls "C:\Users\shr-tunops-wtm" /inheritance:e /T /C