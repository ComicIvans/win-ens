###############################################################################
# Service_fdPHost.ps1
# Host de proveedor de detección de función (fdPHost)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_fdPHost'
  Description   = 'Host de proveedor de detección de función (fdPHost)'
  Type          = 'Service'
  ServiceName   = 'fdPHost'
  ExpectedValue = 'Automatic'
}
