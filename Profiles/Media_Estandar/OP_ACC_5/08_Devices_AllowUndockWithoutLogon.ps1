###############################################################################
# 08_Devices_AllowUndockWithoutLogon.ps1
# Dispositivos: permitir desacoplamiento sin tener que iniciar sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '08_Devices_AllowUndockWithoutLogon'
  Description      = 'Dispositivos: permitir desacoplamiento sin tener que iniciar sesión'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'UndockWithoutLogon'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
