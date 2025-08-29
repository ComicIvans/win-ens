###############################################################################
# Logon_DisableCAD.ps1
# Inicio de sesión interactivo: no requerir Ctrl+Alt+Supr
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Logon_DisableCAD'
  Description      = 'Inicio de sesión interactivo: no requerir Ctrl+Alt+Supr'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'DisableCAD'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
