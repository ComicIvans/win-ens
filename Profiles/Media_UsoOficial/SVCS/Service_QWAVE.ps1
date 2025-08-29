###############################################################################
# Service_QWAVE.ps1
# Experiencia de calidad de audio y vídeo de Windows (qWave) (QWAVE)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_QWAVE'
  Description   = 'Experiencia de calidad de audio y vídeo de Windows (qWave) (QWAVE)'
  Type          = 'Service'
  ServiceName   = 'QWAVE'
  ExpectedValue = 'Disabled'
}
