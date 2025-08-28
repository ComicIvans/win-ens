###############################################################################
# UserRights_ProfileSingleProcess.ps1
# Generar perfiles de un solo proceso
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ProfileSingleProcess'
  Description      = 'Generar perfiles de un solo proceso'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeProfileSingleProcessPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
