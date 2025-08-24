###############################################################################
# 66_Service_PhoneSvc.ps1
# Servicio telefónico (PhoneSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '66_Service_PhoneSvc'
  Description   = 'Servicio telefónico (PhoneSvc)'
  Type          = 'Service'
  ServiceName   = 'PhoneSvc'
  ExpectedValue = 'Disabled'
}
