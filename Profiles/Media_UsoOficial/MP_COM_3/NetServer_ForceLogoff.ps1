###############################################################################
# NetServer_ForceLogoff.ps1
# Servidor de red Microsoft: desconectar a los clientes cuando expire el tiempo
# de inicio de sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetServer_ForceLogoff'
  Description      = 'Servidor de red Microsoft: desconectar a los clientes cuando expire el tiempo de inicio de sesión'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'EnableForcedLogOff'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
