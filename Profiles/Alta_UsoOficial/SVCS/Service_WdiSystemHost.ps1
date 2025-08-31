###############################################################################
# Service_WdiSystemHost.ps1
# Host de sistema de diagnóstico (WdiSystemHost)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WdiSystemHost'
  Description   = 'Host de sistema de diagnóstico (WdiSystemHost)'
  Type          = 'Service'
  ServiceName   = 'WdiSystemHost'
  ExpectedValue = 'Disabled'
}
