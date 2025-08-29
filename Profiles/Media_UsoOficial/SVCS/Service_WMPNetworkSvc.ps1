###############################################################################
# Service_WMPNetworkSvc.ps1
# Servicio de uso compartido de red del Reproductor de Windows Media (WMPNetworkSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WMPNetworkSvc'
  Description   = 'Servicio de uso compartido de red del Reproductor de Windows Media (WMPNetworkSvc)'
  Type          = 'Service'
  ServiceName   = 'WMPNetworkSvc'
  ExpectedValue = 'Disabled'
}
