###############################################################################
# Screensaver_Enable.ps1
# Configuración de usuario/Panel de control/Personalización/Habilitar protector
# de pantalla
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Screensaver_Enable'
  Description      = 'Configuración de usuario/Panel de control/Personalización/Habilitar protector de pantalla'
  Type             = 'Registry'
  Path             = 'HKCU:\Control Panel\Desktop'
  Property         = 'ScreenSaveActive'
  ExpectedValue    = 1
  ValueKind        = 'String'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @('1')
}
