###############################################################################
# Service_Themes.ps1
# Temas (Themes)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_Themes'
  Description   = 'Temas (Themes)'
  Type          = 'Service'
  ServiceName   = 'Themes'
  ExpectedValue = 'Disabled'
}
