###############################################################################
# UserRights_IncreaseBasePriority.ps1
# Aumentar prioridad de programación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_IncreaseBasePriority'
  Description      = 'Aumentar prioridad de programación'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeIncreaseBasePriorityPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
