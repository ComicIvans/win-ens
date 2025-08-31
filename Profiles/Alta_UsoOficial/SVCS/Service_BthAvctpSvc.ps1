###############################################################################
# Service_BthAvctpSvc.ps1
# Servicio AVCTP (BthAvctpSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_BthAvctpSvc'
  Description   = 'Servicio AVCTP (BthAvctpSvc)'
  Type          = 'Service'
  ServiceName   = 'BthAvctpSvc'
  ExpectedValue = 'Automatic'
}
