###############################################################################
# Service_TokenBroker.ps1
# Administrador de cuentas web (TokenBroker)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_TokenBroker'
  Description   = 'Administrador de cuentas web (TokenBroker)'
  Type          = 'Service'
  ServiceName   = 'TokenBroker'
  ExpectedValue = 'Automatic'
}
