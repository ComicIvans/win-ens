###############################################################################
# Service_AJRouter.ps1
# Servicio de enrutador de AllJoyn (AJRouter)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_AJRouter'
  Description   = 'Servicio de enrutador de AllJoyn (AJRouter)'
  Type          = 'Service'
  ServiceName   = 'AJRouter'
  ExpectedValue = 'Disabled'
}
