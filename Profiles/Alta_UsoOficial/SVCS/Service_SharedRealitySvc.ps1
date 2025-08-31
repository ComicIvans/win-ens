###############################################################################
# Service_SharedRealitySvc.ps1
# Servicio de datos espacial (SharedRealitySvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_SharedRealitySvc'
  Description   = 'Servicio de datos espacial (SharedRealitySvc)'
  Type          = 'Service'
  ServiceName   = 'SharedRealitySvc'
  ExpectedValue = 'Disabled'
}
