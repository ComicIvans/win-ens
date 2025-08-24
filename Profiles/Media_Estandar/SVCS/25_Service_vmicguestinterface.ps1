###############################################################################
# 25_Service_vmicguestinterface.ps1
# Interfaz de servicio invitado de Hyper-V (vmicguestinterface)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '25_Service_vmicguestinterface'
  Description   = 'Interfaz de servicio invitado de Hyper-V (vmicguestinterface)'
  Type          = 'Service'
  ServiceName   = 'vmicguestinterface'
  ExpectedValue = 'Disabled'
}
