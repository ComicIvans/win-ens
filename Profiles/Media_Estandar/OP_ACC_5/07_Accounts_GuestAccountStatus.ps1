###############################################################################
# 07_Accounts_GuestAccountStatus.ps1
# Cuentas: estado de la cuenta de invitado
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '07_Accounts_GuestAccountStatus'
  Description      = 'Cuentas: estado de la cuenta de invitado'
  Type             = 'Security'
  Property         = 'EnableGuestAccount'
  ExpectedValue    = 0
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
