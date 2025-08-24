###############################################################################
# 01_Logon_DontDisplayLastUserName.ps1
# Inicio de sesión interactivo: no mostrar el último nombre de usuario
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '01_Logon_DontDisplayLastUserName'
  Description      = 'Inicio de sesión interactivo: no mostrar el último nombre de usuario'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'DontDisplayLastUserName'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
