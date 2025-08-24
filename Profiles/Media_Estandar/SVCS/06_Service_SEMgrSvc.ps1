###############################################################################
# 06_Service_SEMgrSvc.ps1
# Administrador de pagos y NFC/SE (SEMgrSvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '06_Service_SEMgrSvc'
  Description   = 'Administrador de pagos y NFC/SE (SEMgrSvc)'
  Type          = 'Service'
  ServiceName   = 'SEMgrSvc'
  ExpectedValue = 'Disabled'
}
