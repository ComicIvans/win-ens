###############################################################################
# 09_EventLog_Sys_RestrictGuest.ps1
# Sistema: Evitar que el grupo de invitados locales tenga acceso al registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '09_EventLog_Sys_RestrictGuest'
  Description      = 'Sistema: Evitar que el grupo de invitados locales tenga acceso al registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System'
  Property         = 'RestrictGuestAccess'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
