###############################################################################
# 12_Devices_PreventPrinterDriverInstall.ps1
# Dispositivos: impedir que los usuarios instalen controladores de impresora
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '12_Devices_PreventPrinterDriverInstall'
  Description      = 'Dispositivos: impedir que los usuarios instalen controladores de impresora'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers'
  Property         = 'AddPrinterDrivers'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
