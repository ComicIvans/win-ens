###############################################################################
# 02_Pwd_MaximumPasswordAge.ps1
# Vigencia máxima de la contraseña
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '02_Pwd_MaximumPasswordAge'
  Description      = 'Vigencia máxima de la contraseña'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'MaximumPasswordAge'
  ExpectedValue    = 60
  ComparisonMethod = 'LessOrEqual'
}
