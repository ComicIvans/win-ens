###############################################################################
# Service_Netlogon.ps1
# Net Logon (Netlogon)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_Netlogon'
  Description   = 'Net Logon (Netlogon)'
  Type          = 'Service'
  ServiceName   = 'Netlogon'
  ExpectedValue = 'Disabled'
}
