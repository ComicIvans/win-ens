###############################################################################
# 37_Service_camsvc.ps1
# Servicio Administrador de funcionalidad de acceso (camsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '37_Service_camsvc'
  Description   = 'Servicio Administrador de funcionalidad de acceso (camsvc)'
  Type          = 'Service'
  ServiceName   = 'camsvc'
  ExpectedValue = 'Manual'
}
