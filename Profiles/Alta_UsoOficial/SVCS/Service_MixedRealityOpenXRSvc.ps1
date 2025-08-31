###############################################################################
# Service_MixedRealityOpenXRSvc.ps1
# Servicio OpenXR de Windows Mixed Reality (MixedRealityOpenXRSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_MixedRealityOpenXRSvc'
  Description   = 'Servicio OpenXR de Windows Mixed Reality (MixedRealityOpenXRSvc)'
  Type          = 'Service'
  ServiceName   = 'MixedRealityOpenXRSvc'
  ExpectedValue = 'Disabled'
}
