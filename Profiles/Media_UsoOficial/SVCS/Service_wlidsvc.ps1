###############################################################################
# Service_wlidsvc.ps1
# Ayudante para el inicio de sesión de cuenta Microsoft (wlidsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_wlidsvc'
  Description   = 'Ayudante para el inicio de sesión de cuenta Microsoft (wlidsvc)'
  Type          = 'Service'
  ServiceName   = 'wlidsvc'
  ExpectedValue = 'Disabled'
}
