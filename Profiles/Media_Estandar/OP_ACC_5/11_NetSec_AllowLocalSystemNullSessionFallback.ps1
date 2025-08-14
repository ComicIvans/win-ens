###############################################################################
# 11_NetSec_AllowLocalSystemNullSessionFallback.ps1
# Seguridad de red: permitir retroceso a sesión NULL de LocalSystem
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '11_NetSec_AllowLocalSystemNullSessionFallback'
  Description      = 'Seguridad de red: permitir retroceso a sesión NULL de LocalSystem'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
  Property         = 'AllowNullSessionFallback'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
