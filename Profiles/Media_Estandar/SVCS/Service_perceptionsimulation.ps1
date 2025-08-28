###############################################################################
# Service_perceptionsimulation.ps1
# Servicio de simulación de percepción de Windows (perceptionsimulation)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_perceptionsimulation'
  Description   = 'Servicio de simulación de percepción de Windows (perceptionsimulation)'
  Type          = 'Service'
  ServiceName   = 'perceptionsimulation'
  ExpectedValue = 'Automatic'
}
