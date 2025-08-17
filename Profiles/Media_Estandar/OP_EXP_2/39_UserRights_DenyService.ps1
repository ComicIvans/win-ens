###############################################################################
# 39_UserRights_DenyService.ps1
# Denegar el inicio de sesión como servicio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '39_UserRights_DenyService'
  Description      = 'Denegar el inicio de sesión como servicio'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDenyServiceLogonRight'
  ExpectedValue    = @('*S-1-5-32-546', '*S-1-5-7')
  ComparisonMethod = 'PrivilegeSet'
}
