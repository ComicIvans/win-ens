###############################################################################
# 16_Service_diagsvc.ps1
# Diagnostic Execution Service (diagsvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '16_Service_diagsvc'
  Description   = 'Diagnostic Execution Service (diagsvc)'
  Type          = 'Service'
  ServiceName   = 'diagsvc'
  ExpectedValue = 'Disabled'
}
