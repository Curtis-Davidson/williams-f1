# =====================================================================
# Script: Get-FullChassisReport.ps1
# Purpose: Prompt for machine(s) and return type, model, serial, etc.
# Usage: Run from elevated PowerShell console with domain credentials
# =====================================================================

# Prompt for computer names (comma separated)
$inputString = Read-Host "Enter computer name(s), comma separated (e.g. M3079,M3076)"
$computers = $inputString -split ',' | ForEach-Object { $_.Trim() }

# Chassis type ID to friendly name
$chassisMap = @{
    1 = "Other"; 2 = "Unknown"; 3 = "Desktop"; 4 = "Low Profile Desktop"
    5 = "Pizza Box"; 6 = "Mini Tower"; 7 = "Tower"; 8 = "Portable"
    9 = "Laptop"; 10 = "Notebook"; 11 = "Handheld"; 12 = "Docking Station"
    13 = "All-in-One"; 14 = "Sub-Notebook"; 15 = "Space-Saving"
    16 = "Lunch Box"; 17 = "Main System Chassis"; 18 = "Expansion Chassis"
    21 = "Peripheral Chassis"; 23 = "Tablet"; 30 = "Stick PC"
}

foreach ($computer in $computers) {
    try {
        $sys     = Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem -ErrorAction Stop
        $bios    = Get-WmiObject -ComputerName $compauter -Class Win32_BIOS -ErrorAction Stop
        $chassis = Get-WmiObject -ComputerName $computer -Class Win32_SystemEnclosure -ErrorAction Stop

        $typeIDs = $chassis.ChassisTypes
        $type    = if ($typeIDs) {
            ($typeIDs | ForEach-Object { $chassisMap[$_] }) -join ", "
        } else {
            "Not Reported"
        }

        Write-Host "`n==========================="
        Write-Host "Machine:       ${computer}"
        Write-Host "Model:         $($sys.Model)"
        Write-Host "Manufacturer:  $($sys.Manufacturer)"
        Write-Host "Serial:        $($bios.SerialNumber)"
        Write-Host "Chassis Type:  $type"
    }
    catch {
        Write-Host "${computer}: ERROR - $($_.Exception.Message)"
    }
}
