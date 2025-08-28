###############################################################################
# Audit_AccountLogonEvents.ps1
# Auditar eventos de inicio de sesión de cuenta
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Audit_AccountLogonEvents'
  Description      = 'Auditar eventos de inicio de sesión de cuenta'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditAccountLogon'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
