###############################################################################
# 40_UserRights_DenyFromNetwork.ps1
# Denegar el acceso a este equipo desde la red
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '40_UserRights_DenyFromNetwork'
  Description      = 'Denegar el acceso a este equipo desde la red'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDenyNetworkLogonRight'
  ExpectedValue    = @('*S-1-5-32-546', '*S-1-5-7')
  ComparisonMethod = 'PrivilegeSet'
}
