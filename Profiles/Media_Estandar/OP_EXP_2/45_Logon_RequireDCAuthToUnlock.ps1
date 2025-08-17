###############################################################################
# 45_Logon_RequireDCAuthToUnlock.ps1
# Inicio de sesión interactivo: requerir la autenticación del controlador de
# dominio para desbloquear la estación de trabajo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '45_Logon_RequireDCAuthToUnlock'
  Description      = 'Inicio de sesión interactivo: requerir la autenticación del controlador de dominio para desbloquear la estación de trabajo'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'ForceUnlockLogon'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
