###############################################################################
# UserRights_AccessFromNetwork.ps1
# Tener acceso a este equipo desde la red
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_AccessFromNetwork'
  Description      = 'Tener acceso a este equipo desde la red'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeNetworkLogonRight'
  ExpectedValue    = @('*S-1-5-32-544', '*S-1-5-32-545')
  ComparisonMethod = 'PrivilegeSet'
}
