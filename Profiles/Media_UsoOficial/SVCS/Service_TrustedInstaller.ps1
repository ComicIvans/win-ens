###############################################################################
# Service_TrustedInstaller.ps1
# Instalador de módulos de Windows (TrustedInstaller)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = 'Service_TrustedInstaller'
  Description   = 'Instalador de módulos de Windows (TrustedInstaller)'
  Type          = 'Service'
  ServiceName   = 'TrustedInstaller'
  ExpectedValue = 'Manual'
}
