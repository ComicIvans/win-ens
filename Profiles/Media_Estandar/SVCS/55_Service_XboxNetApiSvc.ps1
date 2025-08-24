###############################################################################
# 55_Service_XboxNetApiSvc.ps1
# Servicio de red de Xbox Live (XboxNetApiSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '55_Service_XboxNetApiSvc'
  Description   = 'Servicio de red de Xbox Live (XboxNetApiSvc)'
  Type          = 'Service'
  ServiceName   = 'XboxNetApiSvc'
  ExpectedValue = 'Disabled'
}
