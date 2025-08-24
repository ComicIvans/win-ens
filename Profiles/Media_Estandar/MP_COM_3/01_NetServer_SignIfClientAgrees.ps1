###############################################################################
# 01_NetServer_SignIfClientAgrees.ps1
# Servidor de red Microsoft: firmar digitalmente las comunicaciones
# (si el cliente lo permite)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '01_NetServer_SignIfClientAgrees'
  Description      = 'Servidor de red Microsoft: firmar digitalmente las comunicaciones (si el cliente lo permite)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'EnableSecuritySignature'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
