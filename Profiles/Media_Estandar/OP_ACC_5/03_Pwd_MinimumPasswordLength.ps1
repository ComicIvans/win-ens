###############################################################################
# 03_Pwd_MinimumPasswordLength.ps1
# Longitud mínima de la contraseña
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '03_Pwd_MinimumPasswordLength'
  Description      = 'Longitud mínima de la contraseña'
  Type             = 'Security'
  Property         = 'MinimumPasswordLength'
  ExpectedValue    = 10
  ComparisonMethod = 'GreaterOrEqual'
}
