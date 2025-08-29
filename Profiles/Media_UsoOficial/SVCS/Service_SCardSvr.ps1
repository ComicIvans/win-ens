###############################################################################
# Service_SCardSvr.ps1
# Tarjeta inteligente (SCardSvr)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_SCardSvr'
  Description   = 'Tarjeta inteligente (SCardSvr)'
  Type          = 'Service'
  ServiceName   = 'SCardSvr'
  ExpectedValue = 'Automatic'
}
