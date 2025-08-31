###############################################################################
# Service_SSDPSRV.ps1
# Detección SSDP (SSDPSRV)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_SSDPSRV'
  Description   = 'Detección SSDP (SSDPSRV)'
  Type          = 'Service'
  ServiceName   = 'SSDPSRV'
  ExpectedValue = 'Automatic'
}
