###############################################################################
# 65_Service_vmicvmsession.ps1
# Servicio PowerShell Direct de Hyper-V (vmicvmsession)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '65_Service_vmicvmsession'
  Description   = 'Servicio PowerShell Direct de Hyper-V (vmicvmsession)'
  Type          = 'Service'
  ServiceName   = 'vmicvmsession'
  ExpectedValue = 'Disabled'
}
