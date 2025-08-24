###############################################################################
# 09_Service_CscService.ps1
# Archivos sin conexión (CscService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '09_Service_CscService'
  Description   = 'Archivos sin conexión (CscService)'
  Type          = 'Service'
  ServiceName   = 'CscService'
  ExpectedValue = 'Disabled'
}
