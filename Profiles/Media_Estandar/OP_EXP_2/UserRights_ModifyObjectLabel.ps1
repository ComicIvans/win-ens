###############################################################################
# UserRights_ModifyObjectLabel.ps1
# Modificar la etiqueta de un objeto
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ModifyObjectLabel'
  Description      = 'Modificar la etiqueta de un objeto'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeRelabelPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
