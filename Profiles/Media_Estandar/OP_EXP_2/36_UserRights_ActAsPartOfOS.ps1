###############################################################################
# 36_UserRights_ActAsPartOfOS.ps1
# Actuar como parte del sistema operativo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '36_UserRights_ActAsPartOfOS'
  Description      = 'Actuar como parte del sistema operativo'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeTcbPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
