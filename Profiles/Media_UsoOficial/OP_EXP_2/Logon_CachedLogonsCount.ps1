###############################################################################
# Logon_CachedLogonsCount.ps1
# Inicio de sesión interactivo: número de inicios de sesión anteriores que se
# almacenarán en caché (si el controlador de dominio no está disponible)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Logon_CachedLogonsCount'
  Description      = 'Inicio de sesión interactivo: número de inicios de sesión anteriores que se almacenarán en caché (si el controlador de dominio no está disponible)'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'CachedLogonsCount'
  ExpectedValue    = '0'
  ValueKind        = 'String'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @('0')
}
