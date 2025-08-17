###############################################################################
# 26_UserRights_IncreaseWorkingSet.ps1
# Aumentar el espacio de trabajo de un proceso
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '26_UserRights_IncreaseWorkingSet'
  Description      = 'Aumentar el espacio de trabajo de un proceso'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeIncreaseWorkingSetPrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
