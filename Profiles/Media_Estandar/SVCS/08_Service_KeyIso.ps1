###############################################################################
# 08_Service_KeyIso.ps1
# Aislamiento de claves CNG (KeyIso)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '08_Service_KeyIso'
  Description   = 'Aislamiento de claves CNG (KeyIso)'
  Type          = 'Service'
  ServiceName   = 'KeyIso'
  ExpectedValue = 'Automatic'
}
