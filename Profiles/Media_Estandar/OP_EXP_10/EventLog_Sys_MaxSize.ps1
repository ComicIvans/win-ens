###############################################################################
# EventLog_Sys_MaxSize.ps1
# Sistema: Tamaño máximo del registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'EventLog_Sys_MaxSize'
  Description      = 'Sistema: Tamaño máximo del registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System'
  Property         = 'MaxSize'
  ExpectedValue    = 33554432
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(33554432)
}
