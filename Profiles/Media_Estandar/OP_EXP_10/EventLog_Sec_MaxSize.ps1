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
  ExpectedValue    = 16777216
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(16777216)
}
