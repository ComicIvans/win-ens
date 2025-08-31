###############################################################################
# NetServer_SMB_SignAlways.ps1
# Servidor de red Microsoft: firmar digitalmente las comunicaciones (siempre)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetServer_SMB_SignAlways'
  Description      = 'Servidor de red Microsoft: firmar digitalmente las comunicaciones (siempre)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'RequireSecuritySignature'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
