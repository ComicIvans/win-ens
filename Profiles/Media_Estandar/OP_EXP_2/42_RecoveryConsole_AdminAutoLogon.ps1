###############################################################################
# 42_RecoveryConsole_AdminAutoLogon.ps1
# Consola de recuperación: permitir el inicio de sesión administrativo automático
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '42_RecoveryConsole_AdminAutoLogon'
  Description      = 'Consola de recuperación: permitir el inicio de sesión administrativo automático'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole'
  Property         = 'SecurityLevel'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
