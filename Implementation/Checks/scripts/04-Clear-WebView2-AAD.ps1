# 1) Kill anything that keeps the WebView2 profile open
Get-Process msedge,msedgewebview2,Teams,OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force

# 2) Remove Edge WebView2 user data (this is the usual culprit for the Atlassian SSO window)
$wv2 = "$env:LOCALAPPDATA\Microsoft\EdgeWebView\User Data"
if (Test-Path $wv2) { Remove-Item $wv2 -Recurse -Force -ErrorAction SilentlyContinue }

# 3) (Optional but recommended) Clear Edge's main profile login state
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
if (Test-Path "$edge\Default") {
    Remove-Item "$edge\Default\Web Data"    -Force -ErrorAction SilentlyContinue
    Remove-Item "$edge\Default\Login Data"  -Force -ErrorAction SilentlyContinue
    Remove-Item "$edge\Default\Cookies"     -Force -ErrorAction SilentlyContinue
}

# 4) Reinstall / re-register the AAD broker so it starts from empty
Get-AppxPackage Microsoft.AAD.BrokerPlugin -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
Add-AppxPackage -Register "C:\Windows\SystemApps\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AppxManifest.xml" -DisableDevelopmentMode

# 5) Flush any residual TokenBroker
$tb = "$env:LOCALAPPDATA\Microsoft\TokenBroker"
if (Test-Path $tb) { Remove-Item $tb -Recurse -Force -ErrorAction SilentlyContinue }

# 6) Reboot
Restart-Computer