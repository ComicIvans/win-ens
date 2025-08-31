###############################################################################
# Logon_PasswordExpiryWarning.ps1
# Inicio de sesión interactivo: pedir al usuario que cambie la contraseña
# antes de que expire
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Logon_PasswordExpiryWarning'
  Description      = 'Inicio de sesión interactivo: pedir al usuario que cambie la contraseña antes de que expire'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'PasswordExpiryWarning'
  ExpectedValue    = 10
  ValueKind        = 'DWord'
  ComparisonMethod = 'LessOrEqual'
}
