###############################################################################
# 09_Crypto_ForceStrongKeyProtection.ps1
# Criptografía de sistema: forzar la protección con claves seguras para las
# claves de usuario almacenadas en el equipo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '09_Crypto_ForceStrongKeyProtection'
  Description      = 'Criptografía de sistema: forzar la protección con claves seguras para las claves de usuario almacenadas en el equipo'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography'
  Property         = 'ForceKeyProtection'
  ExpectedValue    = 2
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(2)
}
