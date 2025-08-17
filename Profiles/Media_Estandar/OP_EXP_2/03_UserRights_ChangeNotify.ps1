###############################################################################
# 03_UserRights_ChangeNotify.ps1
# Omitir comprobación de recorrido
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '03_UserRights_ChangeNotify'
  Description      = 'Omitir comprobación de recorrido'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeChangeNotifyPrivilege'
  ExpectedValue    = @('*S-1-5-11', '*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
