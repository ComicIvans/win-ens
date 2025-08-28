###############################################################################
# UserRights_ProfileSystemPerformance.ps1
# Generar perfiles de rendimiento del sistema
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ProfileSystemPerformance'
  Description      = 'Generar perfiles de rendimiento del sistema'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeSystemProfilePrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
