###############################################################################
# Pwd_ReversibleEncryption.ps1
# Almacenar contraseñas con cifrado reversible
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Pwd_ReversibleEncryption'
  Description      = 'Almacenar contraseñas con cifrado reversible'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'ClearTextPassword'
  ExpectedValue    = 0
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
