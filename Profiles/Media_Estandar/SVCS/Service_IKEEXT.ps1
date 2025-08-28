###############################################################################
# Service_IKEEXT.ps1
# Módulos de creación de claves de IPsec para IKE y AuthIP (IKEEXT)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_IKEEXT'
  Description   = 'Módulos de creación de claves de IPsec para IKE y AuthIP (IKEEXT)'
  Type          = 'Service'
  ServiceName   = 'IKEEXT'
  ExpectedValue = 'Manual'
}
