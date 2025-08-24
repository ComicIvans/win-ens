###############################################################################
# 01_Service_XblAuthManager.ps1
# Administración de autenticación de Xbox Live (XblAuthManager)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '01_Service_XblAuthManager'
  Description   = 'Administración de autenticación de Xbox Live (XblAuthManager)'
  Type          = 'Service'
  ServiceName   = 'XblAuthManager'
  ExpectedValue = 'Disabled'
}
