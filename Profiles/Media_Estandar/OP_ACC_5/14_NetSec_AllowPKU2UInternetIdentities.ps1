###############################################################################
# 14_NetSec_AllowPKU2UInternetIdentities.ps1
# Seguridad de red: permitir solicitudes de autenticación PKU2U a este equipo
#para usar identidades en Internet
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '14_NetSec_AllowPKU2UInternetIdentities'
  Description      = 'Seguridad de red: permitir solicitudes de autenticación PKU2U a este equipo para usar identidades en Internet'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u'
  Property         = 'AllowOnlineID'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
