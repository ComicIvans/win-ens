###############################################################################
# Service_TroubleshootingSvc.ps1
# Servicio de solución de problemas recomendado (TroubleshootingSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_TroubleshootingSvc'
  Description   = 'Servicio de solución de problemas recomendado (TroubleshootingSvc)'
  Type          = 'Service'
  ServiceName   = 'TroubleshootingSvc'
  ExpectedValue = 'Disabled'
}
