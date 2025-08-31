###############################################################################
# NetServer_SPNTargetNameValidation.ps1
# Servidor de red Microsoft: nivel de validación de nombres
# de destino SPN del servidor
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetServer_SPNTargetNameValidation'
  Description      = 'Servidor de red Microsoft: nivel de validación de nombres de destino SPN del servidor'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'SmbServerNameHardeningLevel'
  ExpectedValue    = 2
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(2)
}
