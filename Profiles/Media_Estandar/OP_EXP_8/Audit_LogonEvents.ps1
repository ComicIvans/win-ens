###############################################################################
# Audit_LogonEvents.ps1
# Auditar eventos de inicio de sesión
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_LogonEvents'
  Description      = 'Auditar eventos de inicio de sesión'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditLogonEvents'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
