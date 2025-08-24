###############################################################################
# 13_NetSec_LMCompatibilityLevel.ps1
# Seguridad de red: nivel de autenticación de LAN Manager
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '13_NetSec_LMCompatibilityLevel'
  Description      = 'Seguridad de red: nivel de autenticación de LAN Manager'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'LmCompatibilityLevel'
  ExpectedValue    = 5
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(5)
}
