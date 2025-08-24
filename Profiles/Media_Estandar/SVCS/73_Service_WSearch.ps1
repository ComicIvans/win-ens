###############################################################################
# 73_Service_WSearch.ps1
# Windows Search (WSearch)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '73_Service_WSearch'
  Description   = 'Windows Search (WSearch)'
  Type          = 'Service'
  ServiceName   = 'WSearch'
  ExpectedValue = 'Disabled'
}
