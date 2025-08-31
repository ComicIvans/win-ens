###############################################################################
# Service_WdiServiceHost.ps1
# Host del servicio de diagnóstico (WdiServiceHost)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WdiServiceHost'
  Description   = 'Host del servicio de diagnóstico (WdiServiceHost)'
  Type          = 'Service'
  ServiceName   = 'WdiServiceHost'
  ExpectedValue = 'Disabled'
}
