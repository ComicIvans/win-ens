###############################################################################
# Service_upnphost.ps1
# Dispositivo host de UPnP (upnphost)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_upnphost'
  Description   = 'Dispositivo host de UPnP (upnphost)'
  Type          = 'Service'
  ServiceName   = 'upnphost'
  ExpectedValue = 'Automatic'
}
