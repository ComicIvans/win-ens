###############################################################################
# DomainMember_MaximumMachineAccountPwdAge.ps1
# Miembro de dominio: duración máxima de contraseña de cuenta de equipo
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DomainMember_MaximumMachineAccountPwdAge'
  Description      = 'Miembro de dominio: duración máxima de contraseña de cuenta de equipo'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'MaximumPasswordAge'
  ExpectedValue    = 30
  ValueKind        = 'DWord'
  ComparisonMethod = 'LessOrEqual'
}
