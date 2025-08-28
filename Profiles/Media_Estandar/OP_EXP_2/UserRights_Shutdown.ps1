###############################################################################
# UserRights_Shutdown.ps1
# Apagar el sistema
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_Shutdown'
  Description      = 'Apagar el sistema'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeShutdownPrivilege'
  ExpectedValue    = @('*S-1-5-32-544', '*S-1-5-32-545')
  ComparisonMethod = 'PrivilegeSet'
}
