###############################################################################
# 04_Logon_DisplayLastLogonInfo.ps1
# Configuración del equipo/Componentes de Windows/Opciones de inicio de sesión
# de Windows/Mostrar información acerca de inicios de sesión anteriores durante
# inicio de sesión de usuario
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '04_Logon_DisplayLastLogonInfo'
  Description      = 'Configuración del equipo/Componentes de Windows/Opciones de inicio de sesión de Windows/Mostrar información acerca de inicios de sesión anteriores durante inicio de sesión de usuario'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'DisplayLastLogonInfo'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0, 1)
}
