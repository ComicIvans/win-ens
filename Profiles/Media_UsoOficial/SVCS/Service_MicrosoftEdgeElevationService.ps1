###############################################################################
# Service_MicrosoftEdgeElevationService.ps1
# Microsoft Edge Elevation Service (MicrosoftEdgeElevationService) (MicrosoftEdgeElevationService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_MicrosoftEdgeElevationService'
  Description   = 'Microsoft Edge Elevation Service (MicrosoftEdgeElevationService) (MicrosoftEdgeElevationService)'
  Type          = 'Service'
  ServiceName   = 'MicrosoftEdgeElevationService'
  ExpectedValue = 'Disabled'
}
