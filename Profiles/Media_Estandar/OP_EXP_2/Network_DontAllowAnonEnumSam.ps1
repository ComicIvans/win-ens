###############################################################################
# Network_DontAllowAnonEnumSam.ps1
# Acceso a redes: no permitir enumeraciones anónimas de cuentas SAM
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_DontAllowAnonEnumSam'
  Description      = 'Acceso a redes: no permitir enumeraciones anónimas de cuentas SAM'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'RestrictAnonymousSAM'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
