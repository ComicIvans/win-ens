###############################################################################
# UserRights_EnableDelegation.ps1
# Habilitar confianza con el equipo y las cuentas de usuario para delegación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_EnableDelegation'
  Description      = 'Habilitar confianza con el equipo y las cuentas de usuario para delegación'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeEnableDelegationPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
