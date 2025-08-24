###############################################################################
# 53_Service_RetailDemo.ps1
# Servicio de prueba comercial (RetailDemo)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '53_Service_RetailDemo'
  Description   = 'Servicio de prueba comercial (RetailDemo)'
  Type          = 'Service'
  ServiceName   = 'RetailDemo'
  ExpectedValue = 'Disabled'
}
