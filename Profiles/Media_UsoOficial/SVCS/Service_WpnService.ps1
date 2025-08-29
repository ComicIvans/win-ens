###############################################################################
# Service_WpnService.ps1
# Servicio del sistema de notificaciones de inserción de Windows (WpnService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WpnService'
  Description   = 'Servicio del sistema de notificaciones de inserción de Windows (WpnService)'
  Type          = 'Service'
  ServiceName   = 'WpnService'
  ExpectedValue = 'Automatic'
}
