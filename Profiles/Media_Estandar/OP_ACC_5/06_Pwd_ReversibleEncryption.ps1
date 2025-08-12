###############################################################################
# 06_Pwd_ReversibleEncryption.ps1
# Almacenar contraseñas con cifrado reversible
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '06_Pwd_ReversibleEncryption'
  Description      = 'Almacenar contraseñas con cifrado reversible'
  Type             = 'Security'
  Property         = 'ClearTextPassword'
  ExpectedValue    = 0
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
