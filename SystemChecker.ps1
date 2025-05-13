Get-Module -ListAvailableGet-Module -ListAvailableGet-Module -ListAvailable# Set variable for the script.
$PC = Get-WmiObject -Class Win32_ComputerSystem | Select -ExpandProperty PSComputerName
$datetime   = Get-Date -f 'yyyyMMddHHmmss'
$Message = "You are currently running this script on:"

Start-Transcript -Path "$PSScriptRoot\Logs\$PC-Status-$datetime.txt" -Force -NoClobber

# Import the needed custom functions.
Import-Module $PSScriptRoot/SystemCheckerFunction.ps1

# Information About device.
Write-Information -MessageData $Message -InformationAction Continue
Write-Output "$PC"

# Wait a bit after showing the hostname of the current device.
Start-Sleep -Seconds 2

#More Variables for the script.
$Prompt = @(
    "What Task is required?"
    "`n1. Check Windows Build; 2. Check Disk Space; 3. Get Battery Info; 4. Check the boot up time; 99. Stop the Script"
    "`nChoice"
    )
$Task = Read-Host $Prompt

# Wait a bit after picking a task.
Start-Sleep -Seconds 3

If ($Task -contains "Build" -or $Task -contains "1") {

    # Set variable for the build check.
    $Build = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber 
    $MininumBuild = "22621"
    $MaximumBuild = "22631"

    # Waring of Build version is lower than the mininum.
    If ($Build -lt "$MininumBuild") {
        Write-Warning "Windows is running at Build version $Build, this is lower than the required mininum build version ($MininumBuild), please upgrade!"
        Exit 1
    }

    # Recommendation to update Windows if build version is between the mininum and maximum build version.
    Elseif ($Build -gt "$MininumBuild" -and $Build -lt "$MaximumBuild") {
        Write-Warning "You are at build $Build, this Build is fairly resent, but updating is recommended."
        Exit 0
    }

    # Warning about downgrading if the maximum build version is exceeded.
    Elseif ($Build -gt "MaximumBuild") {
        Write-Warning "The build version is greater than build version $MaximumBuild, a downgrade is recommended."
        Exit 1
    }

    # Message that the build version is ok.
    Else {
        Write-Host "No Action Needed, currently at build version $Build" -ForegroundColor Green
        Exit 0
    }
}

# Look for information about the status of the HDD or SSD
Elseif ($Task -contains "Disk" -or $Task -contains "2") {
    $Disk = Get-WmiObject -Class CIM_LogicalDisk | Select-Object DeviceID,Description,FileSystem,Size,FreeSpace
    $Message = "This is the current status of the Disk"

    Write-Information -MessageData $Message -InformationAction Continue
    Write-Output $Disk
}

# Look for information about the status of the battery.
Elseif ($Task -contains "Battery" -or $Task -contains "3") {

    # Set variable for the Bettery check.
    $BatteryStatus = Get-WmiObject -Class Win32_Battery | Select -ExpandProperty Status
    $BatteryRemainingCharge = Get-WmiObject -Class Win32_Battery | Select -ExpandProperty EstimatedChargeRemaining
    $BatteryEstimatedRunTime = Get-WmiObject -Class Win32_Battery | Select -ExpandProperty EstimatedRunTime
    $BatteryHealth = Get-BatteryHealth

    # Messages with the battery status.
    $Message = "`nThis is the current status of the battery:`n"
    Write-Information -MessageData $Message -InformationAction Continue

    Write-Host "The Battery status is $BatteryStatus."
    Write-Host "The battery is charged to $BatteryRemainingCharge%."
    Write-Host "The battery will last $BatteryEstimatedRunTime minute(s) before you have to charge again."

    $Message = "`nThis is the current health of the battery:`n"
    Write-Information -MessageData $Message -InformationAction Continue
    Write-Host "$BatteryHealth"
}

# Check of the uptime
Elseif ($Task -contains "Boot" -or $Task -contains "4") {

    $BootUpTime = Get-SystemUptime
    $AwakeToLong = Get-Date
    $Message = "This system hasn't shut down since:"

    Write-Information -MessageData $Message -InformationAction Continue
    Write-Output $BootUpTime

    If ($BootUpTime -lt $AwakeToLong.AddDays(-5)) {
    Write-Warning "The system hasn't shutdown in the last 5 day's, a reboot is required."
    }

    Elseif ($BootUpTime -lt $AwakeToLong.AddDays(-3)) {
        Write-Warning "The system hasn't shutdown in the last 3 day's, a reboot is recommended."
    }

    Else {
        Write-Host "The last shutdown was recently, no action needed." -ForegroundColor Green
    }
}

# Stops the script.
Elseif ($Task -contains "Stop" -or $Task -contains "99") {
    Write-Host "Exiting the Script!"
    Start-Sleep -Seconds 1
    Write-Host "1"
    Start-Sleep -Seconds 1
    Write-Host "2"
    Start-Sleep -Seconds 1
    Write-Host "3"
    Start-Sleep -Seconds 1
    Write-Host "Bye Bye"
    Exit 0
}

# Error if no task is specified
Else {
    Write-Warning "No task specified, exiting the script"
    Exit 1
}

Stop-Transcript