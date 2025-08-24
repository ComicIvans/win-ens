###############################################################################
# 74_Service_XboxGipSvc.ps1
# Xbox Accessory Management Service (XboxGipSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '74_Service_XboxGipSvc'
  Description   = 'Xbox Accessory Management Service (XboxGipSvc)'
  Type          = 'Service'
  ServiceName   = 'XboxGipSvc'
  ExpectedValue = 'Disabled'
}
