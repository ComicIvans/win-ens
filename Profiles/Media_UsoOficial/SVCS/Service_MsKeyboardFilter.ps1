###############################################################################
# Service_MsKeyboardFilter.ps1
# Filtro de teclado de Microsoft (MsKeyboardFilter)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_MsKeyboardFilter'
  Description   = 'Filtro de teclado de Microsoft (MsKeyboardFilter)'
  Type          = 'Service'
  ServiceName   = 'MsKeyboardFilter'
  ExpectedValue = 'Disabled'
}
