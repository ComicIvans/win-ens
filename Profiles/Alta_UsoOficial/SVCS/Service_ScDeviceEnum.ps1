###############################################################################
# Service_ScDeviceEnum.ps1
# Servicio de enumeración de dispositivos de tarjeta inteligente (ScDeviceEnum)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_ScDeviceEnum'
  Description   = 'Servicio de enumeración de dispositivos de tarjeta inteligente (ScDeviceEnum)'
  Type          = 'Service'
  ServiceName   = 'ScDeviceEnum'
  ExpectedValue = 'Automatic'
}
