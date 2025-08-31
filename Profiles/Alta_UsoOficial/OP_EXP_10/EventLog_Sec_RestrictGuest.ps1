###############################################################################
# EventLog_Sec_RestrictGuest.ps1
# Seguridad: Evitar que el grupo de invitados locales tenga acceso al registro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'EventLog_Sec_RestrictGuest'
  Description      = 'Seguridad: Evitar que el grupo de invitados locales tenga acceso al registro'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security'
  Property         = 'RestrictGuestAccess'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
