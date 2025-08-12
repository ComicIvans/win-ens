###############################################################################
# 10_Accounts_LimitBlankPwdToConsole.ps1
# Cuentas: limitar el uso de contraseñas en blanco solo a inicio de sesión en
# consola
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '10_Accounts_LimitBlankPwdToConsole'
  Description      = 'Cuentas: limitar el uso de cuentas locales con contraseña en blanco sólo para iniciar sesión en la consola'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'LimitBlankPasswordUse'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
