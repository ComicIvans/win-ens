###############################################################################
# 09_DC_RefuseMachinePwdChange.ps1
# Controlador de dominio: no permitir los cambios de contraseña de cuenta de equipo
###############################################################################

# Object with policy's execution information
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyInfo = [PSCustomObject]@{
  Name   = '09_DC_RefuseMachinePwdChange'
  Status = 'Pending'
}

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '09_DC_RefuseMachinePwdChange'
  Description      = 'Controlador de dominio: no permitir los cambios de contraseña de cuenta de equipo'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'RefusePasswordChange'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
