###############################################################################
# UAC_SecureDesktopPrompt.ps1
# Control de cuentas de usuario: cambiar al escritorio seguro cuando se pida
# confirmación de elevación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'UAC_SecureDesktopPrompt'
  Description      = 'Control de cuentas de usuario: cambiar al escritorio seguro cuando se pida confirmación de elevación'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'PromptOnSecureDesktop'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
