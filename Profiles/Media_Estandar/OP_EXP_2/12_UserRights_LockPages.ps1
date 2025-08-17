###############################################################################
# 12_UserRights_LockPages.ps1
# Bloquear páginas en la memoria
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '12_UserRights_LockPages'
  Description      = 'Bloquear páginas en la memoria'
  Type             = 'Security'
  Area             = 'Privilege Rights'
  Property         = 'SeLockMemoryPrivilege'
  ExpectedValue    = @()
  ComparisonMethod = 'PrivilegeSet'
}
