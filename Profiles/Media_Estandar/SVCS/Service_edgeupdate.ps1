###############################################################################
# Service_edgeupdate.ps1
# Microsoft Edge Update Service (edgeupdate) (edgeupdate)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_edgeupdate'
  Description   = 'Microsoft Edge Update Service (edgeupdate) (edgeupdate)'
  Type          = 'Service'
  ServiceName   = 'edgeupdate'
  ExpectedValue = 'Disabled'
}
