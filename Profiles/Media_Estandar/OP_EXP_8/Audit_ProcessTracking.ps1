###############################################################################
# Audit_ProcessTracking.ps1
# Auditar el seguimiento de procesos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_ProcessTracking'
  Description      = 'Auditar el seguimiento de procesos'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditProcessTracking'
  ExpectedValue    = 0
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
