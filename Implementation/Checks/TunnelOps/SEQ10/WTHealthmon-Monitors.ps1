# Get-WTHealthmon-Monitors.ps1
# Purpose:
#   - Dump the current monitor mapping with DISPLAY number and bounds
#   - Used to verify that Windows sees monitors as expected before we pin apps

Add-Type -AssemblyName System.Windows.Forms

Write-Host "`n[WT-Healthmon] Current monitor layout:" -ForegroundColor Cyan

[System.Windows.Forms.Screen]::AllScreens |
        Sort-Object DeviceName |
        ForEach-Object {
            $dev  = $_.DeviceName
            $b    = $_.Bounds
            $disp = $dev.Replace("\\.\DISPLAY","")
            "{0} -> {1}  ({2}x{3} at {4},{5})" -f $dev, "DISPLAY$disp", $b.Width, $b.Height, $b.X, $b.Y
        } | Write-Host
