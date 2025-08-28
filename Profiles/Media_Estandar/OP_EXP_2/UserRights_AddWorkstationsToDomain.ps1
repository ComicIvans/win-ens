###############################################################################
# UserRights_AddWorkstationsToDomain.ps1
# Agregar estaciones de trabajo al dominio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_AddWorkstationsToDomain'
  Description      = 'Agregar estaciones de trabajo al dominio'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeMachineAccountPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
