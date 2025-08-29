###############################################################################
# NetServer_AutoDisconnect.ps1
# Servidor de red Microsoft: tiempo de inactividad requerido antes de suspender
# la sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetServer_AutoDisconnect'
  Description      = 'Servidor de red Microsoft: tiempo de inactividad requerido antes de suspender la sesión'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'AutoDisconnect'
  ExpectedValue    = 15
  ValueKind        = 'DWord'
  ComparisonMethod = 'LessOrEqual'
}
