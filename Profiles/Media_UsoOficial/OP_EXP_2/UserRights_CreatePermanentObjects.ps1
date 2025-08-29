###############################################################################
# UserRights_CreatePermanentObjects.ps1
# Crear objetos compartidos permanentes
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_CreatePermanentObjects'
  Description      = 'Crear objetos compartidos permanentes'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeCreatePermanentPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
