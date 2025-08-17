###############################################################################
# 02_UserRights_BackupFilesAndDirs.ps1
# Hacer copias de seguridad de archivos y directorios
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '02_UserRights_BackupFilesAndDirs'
  Description      = 'Hacer copias de seguridad de archivos y directorios'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeBackupPrivilege'
  ExpectedValue    = @('*S-1-5-32-544', '*S-1-5-32-551')
  ComparisonMethod = 'PrivilegeSet'
}
