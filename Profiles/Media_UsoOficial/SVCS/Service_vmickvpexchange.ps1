###############################################################################
# Service_vmickvpexchange.ps1
# Servicio de intercambio de datos de Hyper-V (vmickvpexchange)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_vmickvpexchange'
  Description   = 'Servicio de intercambio de datos de Hyper-V (vmickvpexchange)'
  Type          = 'Service'
  ServiceName   = 'vmickvpexchange'
  ExpectedValue = 'Disabled'
}
