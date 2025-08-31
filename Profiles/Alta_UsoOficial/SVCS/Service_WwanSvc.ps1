###############################################################################
# Service_WwanSvc.ps1
# Configuración automática de WWAN (WwanSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WwanSvc'
  Description   = 'Configuración automática de WWAN (WwanSvc)'
  Type          = 'Service'
  ServiceName   = 'WwanSvc'
  ExpectedValue = 'Disabled'
}
