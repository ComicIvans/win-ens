###############################################################################
# AccountLockoutDuration.ps1
# Duración del bloqueo de cuenta
#
# AVISO: Esta política debe aplicarse para también pueda que la siguiente,
# AccountLockoutResetTime. Debe utilizarse un valor de -1 o uno mayor
# o igual al de la siguiente.
#
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'AccountLockoutDuration'
  Description      = 'Duración del bloqueo de cuenta'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'LockoutDuration'
  ExpectedValue    = -1
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(-1)
}
