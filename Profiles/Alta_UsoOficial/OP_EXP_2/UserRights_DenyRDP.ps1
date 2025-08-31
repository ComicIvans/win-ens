###############################################################################
# UserRights_DenyRDP.ps1
# Denegar inicio de sesión a través de Servicios de Escritorio remoto
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_DenyRDP'
  Description      = 'Denegar inicio de sesión a través de Servicios de Escritorio remoto'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDenyRemoteInteractiveLogonRight'
  ExpectedValue    = @('*S-1-1-0')
  ComparisonMethod = 'PrivilegeSet'
}
