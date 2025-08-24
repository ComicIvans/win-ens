###############################################################################
# 67_Service_TermService.ps1
# Servicios de Escritorio remoto (TermService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '67_Service_TermService'
  Description   = 'Servicios de Escritorio remoto (TermService)'
  Type          = 'Service'
  ServiceName   = 'TermService'
  ExpectedValue = 'Disabled'
}
