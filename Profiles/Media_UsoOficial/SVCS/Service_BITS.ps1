###############################################################################
# Service_BITS.ps1
# Servicio de transferencia inteligente en segundo plano (BITS)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_BITS'
  Description   = 'Servicio de transferencia inteligente en segundo plano (BITS)'
  Type          = 'Service'
  ServiceName   = 'BITS'
  ExpectedValue = 'Manual'
}
