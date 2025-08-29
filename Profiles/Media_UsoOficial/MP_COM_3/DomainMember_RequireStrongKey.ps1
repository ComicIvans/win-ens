###############################################################################
# DomainMember_RequireStrongKey.ps1
# Miembro de dominio: requerir clave de sesión segura
# (Windows 2000 o posterior)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DomainMember_RequireStrongKey'
  Description      = 'Miembro de dominio: requerir clave de sesión segura (Windows 2000 o posterior)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'RequireStrongKey'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
