###############################################################################
# Service_W32Time.ps1
# Hora de Windows (W32Time)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_W32Time'
  Description   = 'Hora de Windows (W32Time)'
  Type          = 'Service'
  ServiceName   = 'W32Time'
  ExpectedValue = 'Automatic'
}
