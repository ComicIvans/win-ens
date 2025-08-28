###############################################################################
# UserRights_CreateGlobal.ps1
# Crear objetos globales
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_CreateGlobal'
  Description      = 'Crear objetos globales'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeCreateGlobalPrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544', '*S-1-5-6')
  ComparisonMethod = 'PrivilegeSet'
}
