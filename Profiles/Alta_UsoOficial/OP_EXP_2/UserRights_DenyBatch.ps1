###############################################################################
# UserRights_DenyBatch.ps1
# Denegar el inicio de sesión como trabajo por lotes
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_DenyBatch'
  Description      = 'Denegar el inicio de sesión como trabajo por lotes'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeDenyBatchLogonRight'
  ExpectedValue    = @('*S-1-5-32-546', '*S-1-5-7')
  ComparisonMethod = 'PrivilegeSet'
}
