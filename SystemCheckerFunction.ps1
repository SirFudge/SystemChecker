# function to get the Boot up time in a readable format.
function Get-SystemUptime
{
    $operatingSystem = Get-WmiObject Win32_OperatingSystem
    [Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)
}

function Get-BatteryHealth
{
    $DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
    $FullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
    Write-Host "Battery health ="($FullChargedCapacity/$DesignedCapacity).ToString("p")""
}