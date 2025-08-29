###############################################################################
# Service_XblGameSave.ps1
# Partida guardada en Xbox Live (XblGameSave)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_XblGameSave'
  Description   = 'Partida guardada en Xbox Live (XblGameSave)'
  Type          = 'Service'
  ServiceName   = 'XblGameSave'
  ExpectedValue = 'Disabled'
}
