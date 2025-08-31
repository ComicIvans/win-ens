###############################################################################
# UserRights_AllowRDP.ps1
# Permitir inicio de sesión a través de Servicios de Escritorio remoto
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_AllowRDP'
  Description      = 'Permitir inicio de sesión a través de Servicios de Escritorio remoto'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeRemoteInteractiveLogonRight'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
