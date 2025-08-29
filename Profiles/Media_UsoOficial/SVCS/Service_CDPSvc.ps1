###############################################################################
# Service_CDPSvc.ps1
# Servicio de plataforma de dispositivos conectados (CDPSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_CDPSvc'
  Description   = 'Servicio de plataforma de dispositivos conectados (CDPSvc)'
  Type          = 'Service'
  ServiceName   = 'CDPSvc'
  ExpectedValue = 'Automatic'
}
