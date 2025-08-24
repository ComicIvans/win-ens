###############################################################################
# 13_Service_SessionEnv.ps1
# Configuración de Escritorio remoto (SessionEnv)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name          = '13_Service_SessionEnv'
  Description   = 'Configuración de Escritorio remoto (SessionEnv)'
  Type          = 'Service'
  ServiceName   = 'SessionEnv'
  ExpectedValue = 'Disabled'
}
