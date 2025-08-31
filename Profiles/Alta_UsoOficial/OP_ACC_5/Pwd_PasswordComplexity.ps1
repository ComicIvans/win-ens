###############################################################################
# Pwd_PasswordComplexity.ps1
# La contraseña debe cumplir los requisitos de complejidad
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Pwd_PasswordComplexity'
  Description      = 'La contraseña debe cumplir los requisitos de complejidad'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'PasswordComplexity'
  ExpectedValue    = 1
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
