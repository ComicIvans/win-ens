###############################################################################
# Service_DPS.ps1
# Servicio de directivas de diagnóstico (DPS)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_DPS'
  Description   = 'Servicio de directivas de diagnóstico (DPS)'
  Type          = 'Service'
  ServiceName   = 'DPS'
  ExpectedValue = 'Disabled'
}
