###############################################################################
# 07_Service_StiSvc.ps1
# Adquisición de imágenes de Windows (WIA) (StiSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '07_Service_StiSvc'
  Description   = 'Adquisición de imágenes de Windows (WIA) (StiSvc)'
  Type          = 'Service'
  ServiceName   = 'StiSvc'
  ExpectedValue = 'Manual'
}
