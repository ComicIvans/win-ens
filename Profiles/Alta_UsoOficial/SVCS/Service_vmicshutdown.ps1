###############################################################################
# Service_vmicshutdown.ps1
# Servicio de cierre de invitado de Hyper-V (vmicshutdown)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_vmicshutdown'
  Description   = 'Servicio de cierre de invitado de Hyper-V (vmicshutdown)'
  Type          = 'Service'
  ServiceName   = 'vmicshutdown'
  ExpectedValue = 'Disabled'
}
