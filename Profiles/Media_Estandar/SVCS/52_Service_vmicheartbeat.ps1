###############################################################################
# 52_Service_vmicheartbeat.ps1
# Servicio de latido de Hyper-V (vmicheartbeat)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '52_Service_vmicheartbeat'
  Description   = 'Servicio de latido de Hyper-V (vmicheartbeat)'
  Type          = 'Service'
  ServiceName   = 'vmicheartbeat'
  ExpectedValue = 'Disabled'
}
