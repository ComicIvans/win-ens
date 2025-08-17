###############################################################################
# 03_AccountLockoutResetTime.ps1
# Restablecer el bloqueo de cuenta después de
#
# AVISO: Esta política para poder aplicarse requiere que la anterior,
# 02_AccountLockoutDuration, se aplique tamibién con un valor de -1 o uno mayor
# o igual al de esta.
#
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '03_AccountLockoutResetTime'
  Description      = 'Restablecer el bloqueo de cuenta después de'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'ResetLockoutCount'
  ExpectedValue    = 15
  ComparisonMethod = 'GreaterOrEqual'
}
