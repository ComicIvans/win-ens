###############################################################################
# UserRights_CreateSymlinks.ps1
# Crear vínculos simbólicos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_CreateSymlinks'
  Description      = 'Crear vínculos simbólicos'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeCreateSymbolicLinkPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
