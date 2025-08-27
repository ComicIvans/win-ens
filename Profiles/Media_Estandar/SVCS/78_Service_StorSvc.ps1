###############################################################################
# 78_Service_StorSvc.ps1
# Servicio de almacenamiento (StorSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '78_Service_StorSvc'
  Description   = 'Servicio de almacenamiento (StorSvc)'
  Type          = 'Service'
  ServiceName   = 'StorSvc'
  ExpectedValue = 'Automatic'
}
