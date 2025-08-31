###############################################################################
# UserRights_RestoreFilesAndDirs.ps1
# Restaurar archivos y directorios
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UserRights_RestoreFilesAndDirs'
  Description      = 'Restaurar archivos y directorios'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeRestorePrivilege'
  ExpectedValue    = @('*S-1-5-32-544', '*S-1-5-32-551')
  ComparisonMethod = 'PrivilegeSet'
}
