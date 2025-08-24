###############################################################################
# 12_Service_SharedAccess.ps1
# Conexión compartida a Internet (ICS) (SharedAccess)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '12_Service_SharedAccess'
  Description   = 'Conexión compartida a Internet (ICS) (SharedAccess)'
  Type          = 'Service'
  ServiceName   = 'SharedAccess'
  ExpectedValue = 'Disabled'
}
