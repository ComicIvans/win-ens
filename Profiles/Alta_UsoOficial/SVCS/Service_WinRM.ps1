###############################################################################
# Service_WinRM.ps1
# Administración remota de Windows (WS-Management) (WinRM)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_WinRM'
  Description   = 'Administración remota de Windows (WS-Management) (WinRM)'
  Type          = 'Service'
  ServiceName   = 'WinRM'
  ExpectedValue = 'Automatic'
}
