###############################################################################
# Service_edgeupdatem.ps1
# Microsoft Edge Update Service (edgeupdatem) (edgeupdatem)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_edgeupdatem'
  Description   = 'Microsoft Edge Update Service (edgeupdatem) (edgeupdatem)'
  Type          = 'Service'
  ServiceName   = 'edgeupdatem'
  ExpectedValue = 'Disabled'
}
