###############################################################################
# Service_WerSvc.ps1
# Servicio Informe de errores de Windows (WerSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WerSvc'
  Description   = 'Servicio Informe de errores de Windows (WerSvc)'
  Type          = 'Service'
  ServiceName   = 'WerSvc'
  ExpectedValue = 'Disabled'
}
