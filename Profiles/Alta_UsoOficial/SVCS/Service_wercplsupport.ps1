###############################################################################
# Service_wercplsupport.ps1
# Soporte técnico del panel de control Informes de problemas (wercplsupport)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_wercplsupport'
  Description   = 'Soporte técnico del panel de control Informes de problemas (wercplsupport)'
  Type          = 'Service'
  ServiceName   = 'wercplsupport'
  ExpectedValue = 'Disabled'
}
