###############################################################################
# Service_vmicrdv.ps1
# Servicio de virtualización de Escritorio remoto de Hyper-V (vmicrdv)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_vmicrdv'
  Description   = 'Servicio de virtualización de Escritorio remoto de Hyper-V (vmicrdv)'
  Type          = 'Service'
  ServiceName   = 'vmicrdv'
  ExpectedValue = 'Disabled'
}
