###############################################################################
# Audit_ObjectAccess.ps1
# Auditar el acceso a objetos
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_ObjectAccess'
  Description      = 'Auditar el acceso a objetos'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditObjectAccess'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
