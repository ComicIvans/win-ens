###############################################################################
# 03_EventLog_App_RestrictGuest.ps1
# Aplicación: Evitar que el grupo de invitados locales tenga acceso al registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '03_EventLog_App_RestrictGuest'
  Description      = 'Aplicación: Evitar que el grupo de invitados locales tenga acceso al registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application'
  Property         = 'RestrictGuestAccess'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
