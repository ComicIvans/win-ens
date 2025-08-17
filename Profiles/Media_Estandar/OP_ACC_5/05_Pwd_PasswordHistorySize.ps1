###############################################################################
# 05_Pwd_PasswordHistorySize.ps1
# Exigir historial de contraseñas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '05_Pwd_PasswordHistorySize'
  Description      = 'Exigir historial de contraseñas'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'PasswordHistorySize'
  ExpectedValue    = 24
  ComparisonMethod = 'GreaterOrEqual'
}
