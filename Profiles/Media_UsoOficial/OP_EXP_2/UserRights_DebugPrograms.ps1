###############################################################################
# UserRights_DebugPrograms.ps1
# Depurar programas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_DebugPrograms'
  Description      = 'Depurar programas'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDebugPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
