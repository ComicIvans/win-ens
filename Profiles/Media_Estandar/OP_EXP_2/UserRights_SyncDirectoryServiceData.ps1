###############################################################################
# UserRights_SyncDirectoryServiceData.ps1
# Sincronizar los datos del servicio de directorio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_SyncDirectoryServiceData'
  Description      = 'Sincronizar los datos del servicio de directorio'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeSyncAgentPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
