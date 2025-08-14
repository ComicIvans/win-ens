###############################################################################
# 12_NetSec_NoLMHash.ps1
# Seguridad de red: no almacenar hash LAN Manager en el próximo cambio de
# contraseña
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '12_NetSec_NoLMHash'
  Description      = 'Seguridad de red: no almacenar valor de hash de LAN Manager en el próximo cambio de contraseña'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'NoLMHash'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
