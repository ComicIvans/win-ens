###############################################################################
# 20_Service_autotimesvc.ps1
# Hora de la red de telefonía móvil (autotimesvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '20_Service_autotimesvc'
  Description   = 'Hora de la red de telefonía móvil (autotimesvc)'
  Type          = 'Service'
  ServiceName   = 'autotimesvc'
  ExpectedValue = 'Disabled'
}
