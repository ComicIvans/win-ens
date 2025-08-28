###############################################################################
# Pwd_MinimumPasswordAge.ps1
# Vigencia mínima de la contraseña
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Pwd_MinimumPasswordAge'
  Description      = 'Vigencia mínima de la contraseña'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'MinimumPasswordAge'
  ExpectedValue    = 2
  ComparisonMethod = 'GreaterOrEqual'
}
