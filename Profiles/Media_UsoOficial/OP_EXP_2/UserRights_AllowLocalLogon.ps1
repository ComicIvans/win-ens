###############################################################################
# UserRights_AllowLocalLogon.ps1
# Permitir el inicio de sesión local
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_AllowLocalLogon'
  Description      = 'Permitir el inicio de sesión local'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeInteractiveLogonRight'
  ExpectedValue    = @('*S-1-5-32-544', '*S-1-5-32-545', '*S-1-5-32-551')
  ComparisonMethod = 'PrivilegeSet'
}
