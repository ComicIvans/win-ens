###############################################################################
# 20_UserRights_TakeOwnership.ps1
# Tomar posesión de archivos y otros objetos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '20_UserRights_TakeOwnership'
  Description      = 'Tomar posesión de archivos y otros objetos'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeTakeOwnershipPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
