###############################################################################
# Service_HvHost.ps1
# Servicio de host HV (HvHost)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_HvHost'
  Description   = 'Servicio de host HV (HvHost)'
  Type          = 'Service'
  ServiceName   = 'HvHost'
  ExpectedValue = 'Disabled'
}
