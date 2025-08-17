###############################################################################
# 01_AccountLockoutThreshold.ps1
# Umbral de bloqueo de cuenta
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '01_AccountLockoutThreshold'
  Description      = 'Umbral de bloqueo de cuenta'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'LockoutBadCount'
  ExpectedValue    = 5
  ComparisonMethod = 'LessOrEqual'
}
