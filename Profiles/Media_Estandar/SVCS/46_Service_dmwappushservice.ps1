###############################################################################
# 46_Service_dmwappushservice.ps1
# Servicio de enrutamiento de mensajes de inserción del Protocolo de aplicación inalámbrica (WAP) de administración de dispositivos (dmwappushservice)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '46_Service_dmwappushservice'
  Description   = 'Servicio de enrutamiento de mensajes de inserción del Protocolo de aplicación inalámbrica (WAP) de administración de dispositivos (dmwappushservice)'
  Type          = 'Service'
  ServiceName   = 'dmwappushservice'
  ExpectedValue = 'Disabled'
}
