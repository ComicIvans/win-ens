###############################################################################
# 05_UserRights_CreatePagefile.ps1
# Crear un archivo de paginación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '05_UserRights_CreatePagefile'
  Description      = 'Crear un archivo de paginación'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeCreatePagefilePrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
