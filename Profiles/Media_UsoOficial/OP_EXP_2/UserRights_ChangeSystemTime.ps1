###############################################################################
# UserRights_ChangeSystemTime.ps1
# Cambiar la hora del sistema
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ChangeSystemTime'
  Description      = 'Cambiar la hora del sistema'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeSystemtimePrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
