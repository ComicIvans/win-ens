###############################################################################
# 41_Service_DeviceAssociationService.ps1
# Servicio de asociación de dispositivos (DeviceAssociationService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '41_Service_DeviceAssociationService'
  Description   = 'Servicio de asociación de dispositivos (DeviceAssociationService)'
  Type          = 'Service'
  ServiceName   = 'DeviceAssociationService'
  ExpectedValue = 'Manual'
}
