###############################################################################
# UserRights_IncreaseQuota.ps1
# Ajustar las cuotas de memoria para un proceso
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_IncreaseQuota'
  Description      = 'Ajustar las cuotas de memoria para un proceso'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeIncreaseQuotaPrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
