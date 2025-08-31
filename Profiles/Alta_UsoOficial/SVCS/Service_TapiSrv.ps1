###############################################################################
# Service_TapiSrv.ps1
# Telefonía (TapiSrv)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_TapiSrv'
  Description   = 'Telefonía (TapiSrv)'
  Type          = 'Service'
  ServiceName   = 'TapiSrv'
  ExpectedValue = 'Disabled'
}
