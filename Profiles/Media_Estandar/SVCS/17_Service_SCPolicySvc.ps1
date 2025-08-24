###############################################################################
# 17_Service_SCPolicySvc.ps1
# Directiva de extracción de tarjetas inteligentes (SCPolicySvc)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '17_Service_SCPolicySvc'
  Description   = 'Directiva de extracción de tarjetas inteligentes (SCPolicySvc)'
  Type          = 'Service'
  ServiceName   = 'SCPolicySvc'
  ExpectedValue = 'Automatic'
}
