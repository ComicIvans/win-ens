###############################################################################
# Service_cloudidsvc.ps1
# Servicio de identidad en la nube de Microsoft (cloudidsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_cloudidsvc'
  Description   = 'Servicio de identidad en la nube de Microsoft (cloudidsvc)'
  Type          = 'Service'
  ServiceName   = 'cloudidsvc'
  ExpectedValue = 'Disabled'
}
