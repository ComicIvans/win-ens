###############################################################################
# UserRights_Undock.ps1
# Quitar equipo de la estación de acoplamiento
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_Undock'
  Description      = 'Quitar equipo de la estación de acoplamiento'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeUndockPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
