###############################################################################
# 62_Service_SmsRouter.ps1
# Servicio enrutador de SMS de Microsoft Windows. (SmsRouter)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '62_Service_SmsRouter'
  Description   = 'Servicio enrutador de SMS de Microsoft Windows. (SmsRouter)'
  Type          = 'Service'
  ServiceName   = 'SmsRouter'
  ExpectedValue = 'Disabled'
}
