###############################################################################
# Service_DoSvc.ps1
# Optimización de distribución (DoSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_DoSvc'
  Description   = 'Optimización de distribución (DoSvc)'
  Type          = 'Service'
  ServiceName   = 'DoSvc'
  ExpectedValue = 'Automatic'
}
