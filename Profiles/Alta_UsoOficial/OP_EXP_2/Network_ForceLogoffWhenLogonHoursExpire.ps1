###############################################################################
# Network_ForceLogoffWhenLogonHoursExpire.ps1
# Seguridad de red: forzar el cierre de sesión cuando expire la hora de inicio
# de sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_ForceLogoffWhenLogonHoursExpire'
  Description      = 'Seguridad de red: forzar el cierre de sesión cuando expire la hora de inicio de sesión'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'ForceLogoffWhenHourExpire'
  ExpectedValue    = 1
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
