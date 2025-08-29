###############################################################################
# UserRights_TrustedCredManAccess.ps1
# Obtener acceso al administrador de credenciales como un llamador de confianza
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_TrustedCredManAccess'
  Description      = 'Obtener acceso al administrador de credenciales como un llamador de confianza'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeTrustedCredManAccessPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
