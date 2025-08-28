###############################################################################
# Service_FDResPub.ps1
# Publicación de recurso de detección de función (FDResPub)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_FDResPub'
  Description   = 'Publicación de recurso de detección de función (FDResPub)'
  Type          = 'Service'
  ServiceName   = 'FDResPub'
  ExpectedValue = 'Automatic'
}
