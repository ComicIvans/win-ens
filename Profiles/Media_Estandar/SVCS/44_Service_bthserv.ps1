###############################################################################
# 44_Service_bthserv.ps1
# Servicio de compatibilidad con Bluetooth (bthserv)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '44_Service_bthserv'
  Description   = 'Servicio de compatibilidad con Bluetooth (bthserv)'
  Type          = 'Service'
  ServiceName   = 'bthserv'
  ExpectedValue = 'Automatic'
}
