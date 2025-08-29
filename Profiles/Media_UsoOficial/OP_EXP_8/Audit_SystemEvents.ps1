###############################################################################
# Audit_SystemEvents.ps1
# Auditar eventos del sistema
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_SystemEvents'
  Description      = 'Auditar eventos del sistema'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditSystemEvents'
  ExpectedValue    = 1
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1, 3)
}
