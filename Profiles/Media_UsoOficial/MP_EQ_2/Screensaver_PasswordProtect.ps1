###############################################################################
# Screensaver_PasswordProtect.ps1
# Configuración de usuario/Panel de control/Personalización/Proteger el
# protector de pantalla mediante contraseña
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Screensaver_PasswordProtect'
  Description      = 'Configuración de usuario/Panel de control/Personalización/Proteger el protector de pantalla mediante contraseña'
  Type             = 'Registry'
  Path             = 'HKCU:\Control Panel\Desktop'
  Property         = 'ScreenSaverIsSecure'
  ExpectedValue    = 1
  ValueKind        = 'String'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @('1')
}
