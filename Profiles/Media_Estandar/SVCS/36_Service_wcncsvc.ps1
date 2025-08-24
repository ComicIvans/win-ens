###############################################################################
# 36_Service_wcncsvc.ps1
# Registrador de configuración de Windows Connect Now (wcncsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '36_Service_wcncsvc'
  Description   = 'Registrador de configuración de Windows Connect Now (wcncsvc)'
  Type          = 'Service'
  ServiceName   = 'wcncsvc'
  ExpectedValue = 'Disabled'
}
