###############################################################################
# 48_Service_fhsvc.ps1
# Servicio de historial de archivos (fhsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '48_Service_fhsvc'
  Description   = 'Servicio de historial de archivos (fhsvc)'
  Type          = 'Service'
  ServiceName   = 'fhsvc'
  ExpectedValue = 'Disabled'
}
