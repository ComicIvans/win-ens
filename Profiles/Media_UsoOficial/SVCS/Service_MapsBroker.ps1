###############################################################################
# Service_MapsBroker.ps1
# Administrador de mapas descargados (MapsBroker)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_MapsBroker'
  Description   = 'Administrador de mapas descargados (MapsBroker)'
  Type          = 'Service'
  ServiceName   = 'MapsBroker'
  ExpectedValue = 'Disabled'
}
