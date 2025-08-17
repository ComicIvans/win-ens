###############################################################################
# 47_Network_EveryoneIncludesAnonymous.ps1
# Acceso a redes: permitir la aplicación de los permisos Todos a los usuarios
# anónimos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '47_Network_EveryoneIncludesAnonymous'
  Description      = 'Acceso a redes: permitir la aplicación de los permisos Todos a los usuarios anónimos'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'EveryoneIncludesAnonymous'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
