###############################################################################
# Service_vmictimesync.ps1
# Servicio de sincronización de hora de Hyper-V (vmictimesync)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_vmictimesync'
  Description   = 'Servicio de sincronización de hora de Hyper-V (vmictimesync)'
  Type          = 'Service'
  ServiceName   = 'vmictimesync'
  ExpectedValue = 'Disabled'
}
