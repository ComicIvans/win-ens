###############################################################################
# 06_Audit_AccountManagement.ps1
# Auditar la administración de cuentas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '06_Audit_AccountManagement'
  Description      = 'Auditar la administración de cuentas'
  Type             = 'Security'
  Area             = 'Event Audit'
  Property         = 'AuditAccountManage'
  ExpectedValue    = 3
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(3)
}
