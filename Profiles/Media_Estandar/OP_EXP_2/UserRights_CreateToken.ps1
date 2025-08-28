###############################################################################
# UserRights_CreateToken.ps1
# Crear un objeto símbolo (token)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_CreateToken'
  Description      = 'Crear un objeto símbolo (token)'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeCreateTokenPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
