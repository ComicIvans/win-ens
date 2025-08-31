###############################################################################
# UserRights_LogonAsBatch.ps1
# Iniciar sesión como proceso por lotes
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_LogonAsBatch'
  Description      = 'Iniciar sesión como proceso por lotes'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeBatchLogonRight'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
