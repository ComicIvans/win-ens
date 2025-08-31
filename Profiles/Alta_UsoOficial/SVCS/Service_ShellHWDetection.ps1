###############################################################################
# Service_ShellHWDetection.ps1
# Detección de hardware shell (ShellHWDetection)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_ShellHWDetection'
  Description   = 'Detección de hardware shell (ShellHWDetection)'
  Type          = 'Service'
  ServiceName   = 'ShellHWDetection'
  ExpectedValue = 'Disabled'
}
