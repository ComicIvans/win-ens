###############################################################################
# Service_UmRdpService.ps1
# Redirector de puerto en modo usuario de Servicios de Escritorio remoto (UmRdpService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_UmRdpService'
  Description   = 'Redirector de puerto en modo usuario de Servicios de Escritorio remoto (UmRdpService)'
  Type          = 'Service'
  ServiceName   = 'UmRdpService'
  ExpectedValue = 'Disabled'
}
