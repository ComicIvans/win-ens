###############################################################################
# UserRights_ManageVolume.ps1
# Realizar tareas de mantenimiento del volumen
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_ManageVolume'
  Description      = 'Realizar tareas de mantenimiento del volumen'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeManageVolumePrivilege'
  ExpectedValue    = @('*S-1-5-32-544')
  ComparisonMethod = 'PrivilegeSet'
}
