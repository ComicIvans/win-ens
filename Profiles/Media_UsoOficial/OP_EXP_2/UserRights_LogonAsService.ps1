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
  ExpectedValue    = @('*S-1-5-80-0', '*S-1-5-83-0')
  ComparisonMethod = 'PrivilegeSet'
}
