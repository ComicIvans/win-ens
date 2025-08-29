###############################################################################
# UserRights_LoadUnloadDrivers.ps1
# Cargar y descargar controladores de dispositivo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_LoadUnloadDrivers'
  Description      = 'Cargar y descargar controladores de dispositivo'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeLoadDriverPrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
