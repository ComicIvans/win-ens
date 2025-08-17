###############################################################################
# 27_UserRights_ChangeTimeZone.ps1
# Cambiar la zona horaria
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '27_UserRights_ChangeTimeZone'
  Description      = 'Cambiar la zona horaria'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeTimeZonePrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
