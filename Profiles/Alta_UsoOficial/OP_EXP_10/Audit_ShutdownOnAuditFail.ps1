###############################################################################
# Audit_ShutdownOnAuditFail.ps1
# Auditoría: apagar el sistema de inmediato si no se pueden registrar las
# auditorías de seguridad
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_ShutdownOnAuditFail'
  Description      = 'Auditoría: apagar el sistema de inmediato si no se pueden registrar las auditorías de seguridad'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'CrashOnAuditFail'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
