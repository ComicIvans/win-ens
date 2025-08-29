###############################################################################
# Service_TextInputManagementService.ps1
# Servicio de administración de entrada de texto (TextInputManagementService)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_TextInputManagementService'
  Description   = 'Servicio de administración de entrada de texto (TextInputManagementService)'
  Type          = 'Service'
  ServiceName   = 'TextInputManagementService'
  ExpectedValue = 'Disabled'
}
