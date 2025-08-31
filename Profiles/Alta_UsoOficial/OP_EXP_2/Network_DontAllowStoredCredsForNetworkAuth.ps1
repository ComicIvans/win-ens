###############################################################################
# Network_DontAllowStoredCredsForNetworkAuth.ps1
# Acceso a redes: no permitir el almacenamiento de contraseñas y credenciales
# para la autenticación de la red
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_DontAllowStoredCredsForNetworkAuth'
  Description      = 'Acceso a redes: no permitir el almacenamiento de contraseñas y credenciales para la autenticación de la red'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'DisableDomainCreds'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
