###############################################################################
# 21_UserRights_DenyLocalLogon.ps1
# Denegar el inicio de sesión local
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '21_UserRights_DenyLocalLogon'
  Description      = 'Denegar el inicio de sesión local'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDenyInteractiveLogonRight'
  ExpectedValue    = @('*S-1-5-32-546', '*S-1-5-7')
  ComparisonMethod = 'PrivilegeSet'
}
