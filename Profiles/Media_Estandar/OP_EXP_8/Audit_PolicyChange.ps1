###############################################################################
# Audit_PolicyChange.ps1
# Auditar el cambio de directivas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_PolicyChange'
  Description      = 'Auditar el cambio de directivas'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditPolicyChange'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
