#from the web, years ago...

$Cycles = (Get-WmiObject -Class BatteryCycleCount -Namespace ROOT\WMI).CycleCount
Write-Host "Charge cycles:`t $Cycles"

$DesignCapacity = (Get-WmiObject -Class BatteryStaticData -Namespace ROOT\WMI).DesignedCapacity
Write-Host "Design capacity: $DesignCapacity mAh"

$FullCharge = (Get-WmiObject -Class BatteryFullChargedCapacity -Namespace ROOT\WMI).FullChargedCapacity
Write-Host "Full charge:`t $FullCharge mAh"

$BatteryHealth = ($FullCharge/$DesignCapacity)*100
$BatteryHealth = [math]::Round($BatteryHealth,2)
Write-Host "Battery health:`t $BatteryHealth%"

$Discharge = (Get-WmiObject -Class BatteryStatus -Namespace ROOT\WMI).DischargeRate
Write-Host "Discharge rate:`t $Discharge mA"

$Charging = (Get-WmiObject -Class BatteryStatus -Namespace ROOT\WMI).ChargeRate
Write-Host "Charging rate:`t $Charging mA"
