###############################################################################
# Audit_DirectoryServiceAccess.ps1
# Auditar el acceso al servicio de directorio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_DirectoryServiceAccess'
  Description      = 'Auditar el acceso al servicio de directorio'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditDSAccess'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
