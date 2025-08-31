###############################################################################
# Service_PlugPlay.ps1
# Plug and Play (PlugPlay)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_PlugPlay'
  Description   = 'Plug and Play (PlugPlay)'
  Type          = 'Service'
  ServiceName   = 'PlugPlay'
  ExpectedValue = 'Automatic'
}
