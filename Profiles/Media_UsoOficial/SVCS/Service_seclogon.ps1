###############################################################################
# Service_seclogon.ps1
# Inicio de sesión secundario (seclogon)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_seclogon'
  Description   = 'Inicio de sesión secundario (seclogon)'
  Type          = 'Service'
  ServiceName   = 'seclogon'
  ExpectedValue = 'Disabled'
}
