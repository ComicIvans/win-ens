###############################################################################
# Audit_PrivilegeUse.ps1
# Auditar el uso de privilegios
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_PrivilegeUse'
  Description      = 'Auditar el uso de privilegios'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditPrivilegeUse'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
