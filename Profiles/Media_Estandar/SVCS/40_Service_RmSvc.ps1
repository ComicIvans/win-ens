###############################################################################
# 40_Service_RmSvc.ps1
# Servicio de administración de radio (RmSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '40_Service_RmSvc'
  Description   = 'Servicio de administración de radio (RmSvc)'
  Type          = 'Service'
  ServiceName   = 'RmSvc'
  ExpectedValue = 'Disabled'
}
