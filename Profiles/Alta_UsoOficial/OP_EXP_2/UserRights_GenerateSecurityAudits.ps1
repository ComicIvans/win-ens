###############################################################################
# UserRights_GenerateSecurityAudits.ps1
# Generar auditorías de seguridad
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_GenerateSecurityAudits'
  Description      = 'Generar auditorías de seguridad'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeAuditPrivilege'
  ExpectedValue    = @('*S-1-5-19', '*S-1-5-20')
  ComparisonMethod = 'PrivilegeSet'
}
