###############################################################################
# NetClient_SignAlways.ps1
# Cliente de redes de Microsoft: firmar digitalmente las comunicaciones (siempre)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetClient_SignAlways'
  Description      = 'Cliente de redes de Microsoft: firmar digitalmente las comunicaciones (siempre)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
  Property         = 'RequireSecuritySignature'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
