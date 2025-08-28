###############################################################################
# Service_spectrum.ps1
# Servicio de percepción de Windows (spectrum)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_spectrum'
  Description   = 'Servicio de percepción de Windows (spectrum)'
  Type          = 'Service'
  ServiceName   = 'spectrum'
  ExpectedValue = 'Disabled'
}
