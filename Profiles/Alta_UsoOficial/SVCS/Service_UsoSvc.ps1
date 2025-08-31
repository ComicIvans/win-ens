###############################################################################
# Service_UsoSvc.ps1
# Servicio orquestador de actualizaciones (UsoSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_UsoSvc'
  Description   = 'Servicio orquestador de actualizaciones (UsoSvc)'
  Type          = 'Service'
  ServiceName   = 'UsoSvc'
  ExpectedValue = 'Automatic'
}
