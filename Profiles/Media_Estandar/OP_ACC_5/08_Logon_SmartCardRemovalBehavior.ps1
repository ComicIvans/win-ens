###############################################################################
# 08_Logon_SmartCardRemovalBehavior.ps1
# Inicio de sesión interactivo: comportamiento de extracción de tarjeta
# inteligente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '08_Logon_SmartCardRemovalBehavior'
  Description      = 'Inicio de sesión interactivo: comportamiento de extracción de tarjeta inteligente'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'ScRemoveOption'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1, 2, 3)
}
