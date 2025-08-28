###############################################################################
# EventLog_Sys_RetentionMethod.ps1
# Sistema: Método de retención del registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'EventLog_Sys_RetentionMethod'
  Description      = 'Sistema: Método de retención del registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System'
  Property         = 'Retention'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
