###############################################################################
# Service_FrameServer.ps1
# Servicio FrameServer de la Cámara de Windows (FrameServer)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_FrameServer'
  Description   = 'Servicio FrameServer de la Cámara de Windows (FrameServer)'
  Type          = 'Service'
  ServiceName   = 'FrameServer'
  ExpectedValue = 'Automatic'
}
