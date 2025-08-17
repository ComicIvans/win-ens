###############################################################################
# 55_Network_RestrictAnonPipesAndShares.ps1
# Acceso a redes: restringir acceso anónimo a canalizaciones con nombre y
# recursos compartidos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '55_Network_RestrictAnonPipesAndShares'
  Description      = 'Acceso a redes: restringir acceso anónimo a canalizaciones con nombre y recursos compartidos'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'RestrictNullSessAccess'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
