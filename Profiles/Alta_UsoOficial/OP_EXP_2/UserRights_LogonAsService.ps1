###############################################################################
# UserRights_LogonAsService.ps1
# Iniciar sesión como servicio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_LogonAsService'
  Description      = 'Iniciar sesión como servicio'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeServiceLogonRight'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
