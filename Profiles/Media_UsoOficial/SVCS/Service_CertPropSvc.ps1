###############################################################################
# Service_CertPropSvc.ps1
# Propagación de certificados (CertPropSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_CertPropSvc'
  Description   = 'Propagación de certificados (CertPropSvc)'
  Type          = 'Service'
  ServiceName   = 'CertPropSvc'
  ExpectedValue = 'Automatic'
}
