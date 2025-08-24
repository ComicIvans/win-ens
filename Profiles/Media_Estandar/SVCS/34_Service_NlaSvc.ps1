###############################################################################
# 34_Service_NlaSvc.ps1
# Reconocimiento de ubicación de red (NlaSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '34_Service_NlaSvc'
  Description   = 'Reconocimiento de ubicación de red (NlaSvc)'
  Type          = 'Service'
  ServiceName   = 'NlaSvc'
  ExpectedValue = 'Automatic'
}
