###############################################################################
# 48_Network_SharingSecurityModel.ps1
# Acceso a redes: modelo de seguridad y uso compartido para cuentas locales
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '48_Network_SharingSecurityModel'
  Description      = 'Acceso a redes: modelo de seguridad y uso compartido para cuentas locales'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'ForceGuest'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
