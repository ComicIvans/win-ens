###############################################################################
# UserRights_RemoteShutdown.ps1
# Forzar cierre desde un sistema remoto
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_RemoteShutdown'
  Description      = 'Forzar cierre desde un sistema remoto'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeRemoteShutdownPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
