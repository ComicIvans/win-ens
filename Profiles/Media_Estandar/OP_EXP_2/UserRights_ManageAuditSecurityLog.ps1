###############################################################################
# UserRights_ManageAuditSecurityLog.ps1
# Administrar registro de seguridad y auditoría
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ManageAuditSecurityLog'
  Description      = 'Administrar registro de seguridad y auditoría'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeSecurityPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
