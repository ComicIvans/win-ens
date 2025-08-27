###############################################################################
# 04_Logon_InactivityTimeoutSecs.ps1
# Inicio de sesión interactivo: límite de inactividad del equipo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '04_Logon_InactivityTimeoutSecs'
  Description      = 'Inicio de sesión interactivo: límite de inactividad del equipo'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'InactivityTimeoutSecs'
  ExpectedValue    = 600
  ValueKind        = 'DWord'
  ComparisonMethod = 'LessOrEqual'
}
