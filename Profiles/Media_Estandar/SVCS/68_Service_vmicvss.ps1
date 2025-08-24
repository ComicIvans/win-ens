###############################################################################
# 68_Service_vmicvss.ps1
# Solicitante de instantáneas de volumen de Hyper-V (vmicvss)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '68_Service_vmicvss'
  Description   = 'Solicitante de instantáneas de volumen de Hyper-V (vmicvss)'
  Type          = 'Service'
  ServiceName   = 'vmicvss'
  ExpectedValue = 'Disabled'
}
