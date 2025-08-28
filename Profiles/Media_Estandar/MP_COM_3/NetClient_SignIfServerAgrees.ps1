###############################################################################
# NetClient_SignIfServerAgrees.ps1
# Cliente de redes de Microsoft: firmar digitalmente las comunicaciones
# (si el servidor lo permite)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetClient_SignIfServerAgrees'
  Description      = 'Cliente de redes de Microsoft: firmar digitalmente las comunicaciones (si el servidor lo permite)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
  Property         = 'EnableSecuritySignature'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
