###############################################################################
# EventLog_Sec_MaxSize.ps1
# Seguridad: Tamaño máximo del registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'EventLog_Sec_MaxSize'
  Description      = 'Seguridad: Tamaño máximo del registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security'
  Property         = 'MaxSize'
  ExpectedValue    = 167772160
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(167772160)
}
