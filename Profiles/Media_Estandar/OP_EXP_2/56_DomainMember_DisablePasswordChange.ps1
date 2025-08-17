###############################################################################
# 56_DomainMember_DisablePasswordChange.ps1
# Miembro de dominio: deshabilitar los cambios de contraseña de cuentas de
# equipo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '56_DomainMember_DisablePasswordChange'
  Description      = 'Miembro de dominio: deshabilitar los cambios de contraseña de cuentas de equipo'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'DisablePasswordChange'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
