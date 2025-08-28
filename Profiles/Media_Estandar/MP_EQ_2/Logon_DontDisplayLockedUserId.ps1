###############################################################################
# Logon_DontDisplayLockedUserId.ps1
# Inicio de sesión interactivo: mostrar información de usuario cuando se bloquee
# la sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Logon_DontDisplayLockedUserId'
  Description      = 'Inicio de sesión interactivo: mostrar información de usuario cuando se bloquee la sesión'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'DontDisplayLockedUserId'
  ExpectedValue    = 3
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
