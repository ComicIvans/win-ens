###############################################################################
# UAC_AdminApprovalModeBuiltinAdmin.ps1
# Control de cuentas de usuario: Modo de aprobación de administrador para la
# cuenta predefinida Administrador
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UAC_AdminApprovalModeBuiltinAdmin'
  Description      = 'Control de cuentas de usuario: Modo de aprobación de administrador para la cuenta predefinida Administrador'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'FilterAdministratorToken'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
