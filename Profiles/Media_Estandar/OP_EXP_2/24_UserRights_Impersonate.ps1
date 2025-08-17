###############################################################################
# 24_UserRights_Impersonate.ps1
# Suplantar a un cliente tras la autenticación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '24_UserRights_Impersonate'
  Description      = 'Suplantar a un cliente tras la autenticación'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeImpersonatePrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544', '*S-1-5-6')
  ComparisonMethod = 'PrivilegeSet'
}
