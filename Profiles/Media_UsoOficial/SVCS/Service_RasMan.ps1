###############################################################################
# Service_RasMan.ps1
# Administrador de conexiones de acceso remoto (RasMan)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_RasMan'
  Description   = 'Administrador de conexiones de acceso remoto (RasMan)'
  Type          = 'Service'
  ServiceName   = 'RasMan'
  ExpectedValue = 'Automatic'
}
