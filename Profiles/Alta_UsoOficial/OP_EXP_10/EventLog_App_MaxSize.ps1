###############################################################################
# EventLog_App_MaxSize.ps1
# Aplicación: Tamaño máximo del registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'EventLog_App_MaxSize'
  Description      = 'Aplicación: Tamaño máximo del registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application'
  Property         = 'MaxSize'
  ExpectedValue    = 33554432
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(33554432)
}
