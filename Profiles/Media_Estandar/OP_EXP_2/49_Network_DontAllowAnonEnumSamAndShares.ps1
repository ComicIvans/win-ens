###############################################################################
# 49_Network_DontAllowAnonEnumSamAndShares.ps1
# Acceso a redes: no permitir enumeraciones anónimas de cuentas y recursos
# compartidos SAM
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '49_Network_DontAllowAnonEnumSamAndShares'
  Description      = 'Acceso a redes: no permitir enumeraciones anónimas de cuentas y recursos compartidos SAM'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'RestrictAnonymous'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
