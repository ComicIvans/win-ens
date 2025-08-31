###############################################################################
# Network_RemoteRegPaths.ps1
# Acceso a redes: rutas del Registro accesibles remotamente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_RemoteRegPaths'
  Description      = 'Acceso a redes: rutas del Registro accesibles remotamente'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths'
  Property         = 'Machine'
  ValueKind        = 'MultiString'
  ExpectedValue    = @(
    'software\microsoft\windows nt\currentversion',
    'system\currentcontrolset\control\productoptions',
    'system\currentcontrolset\control\server applications'
  )
  ComparisonMethod = 'ExactSet'
}
