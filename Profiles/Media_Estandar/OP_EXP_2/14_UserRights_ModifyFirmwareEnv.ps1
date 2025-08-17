###############################################################################
# 14_UserRights_ModifyFirmwareEnv.ps1
# Modificar valores de entorno firmware
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '14_UserRights_ModifyFirmwareEnv'
  Description      = 'Modificar valores de entorno firmware'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeSystemEnvironmentPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
