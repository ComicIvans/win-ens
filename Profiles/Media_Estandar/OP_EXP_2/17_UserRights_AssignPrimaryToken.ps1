###############################################################################
# 17_UserRights_AssignPrimaryToken.ps1
# Reemplazar un símbolo (token) de nivel de proceso
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '17_UserRights_AssignPrimaryToken'
  Description      = 'Reemplazar un símbolo (token) de nivel de proceso'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeAssignPrimaryTokenPrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20')
  ComparisonMethod = 'PrivilegeSet'
}
