###############################################################################
# Service_workfolderssvc.ps1
# Carpetas de trabajo (workfolderssvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_workfolderssvc'
  Description   = 'Carpetas de trabajo (workfolderssvc)'
  Type          = 'Service'
  ServiceName   = 'workfolderssvc'
  ExpectedValue = 'Disabled'
}
