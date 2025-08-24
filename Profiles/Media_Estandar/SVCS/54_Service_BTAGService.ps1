###############################################################################
# 54_Service_BTAGService.ps1
# Servicio de puerta de enlace de audio de Bluetooth (BTAGService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '54_Service_BTAGService'
  Description   = 'Servicio de puerta de enlace de audio de Bluetooth (BTAGService)'
  Type          = 'Service'
  ServiceName   = 'BTAGService'
  ExpectedValue = 'Automatic'
}
