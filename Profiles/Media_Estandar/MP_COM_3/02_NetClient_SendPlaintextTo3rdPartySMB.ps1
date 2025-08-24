###############################################################################
# 02_NetClient_SendPlaintextTo3rdPartySMB.ps1
# Cliente de redes de Microsoft: enviar contraseña sin cifrar
# a servidores SMB de terceros
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '02_NetClient_SendPlaintextTo3rdPartySMB'
  Description      = 'Cliente de redes de Microsoft: enviar contraseña sin cifrar a servidores SMB de terceros'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
  Property         = 'EnablePlainTextPassword'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
