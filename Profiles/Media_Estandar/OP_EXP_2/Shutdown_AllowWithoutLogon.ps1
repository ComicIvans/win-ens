###############################################################################
# Shutdown_AllowWithoutLogon.ps1
# Apagado: permitir apagar el sistema sin tener que iniciar sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Shutdown_AllowWithoutLogon'
  Description      = 'Apagado: permitir apagar el sistema sin tener que iniciar sesión'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'ShutdownWithoutLogon'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
