###############################################################################
# Network_AnonNamedPipes.ps1
# Acceso a redes: canalizaciones con nombre accesibles anónimamente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_AnonNamedPipes'
  Description      = 'Acceso a redes: canalizaciones con nombre accesibles anónimamente'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'NullSessionPipes'
  ExpectedValue    = @()
  ValueKind        = 'MultiString'
  ComparisonMethod = 'ExactSet'
}
