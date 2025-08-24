###############################################################################
# 61_Service_icssvc.ps1
# Servicio de zona con cobertura inalámbrica móvil de Windows (icssvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '61_Service_icssvc'
  Description   = 'Servicio de zona con cobertura inalámbrica móvil de Windows (icssvc)'
  Type          = 'Service'
  ServiceName   = 'icssvc'
  ExpectedValue = 'Disabled'
}
