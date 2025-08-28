###############################################################################
# DomainMember_SealWhenPossible.ps1
# Miembro de dominio: cifrar digitalmente datos de un canal seguro
# (cuando sea posible)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DomainMember_SealWhenPossible'
  Description      = 'Miembro de dominio: cifrar digitalmente datos de un canal seguro (cuando sea posible)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'SealSecureChannel'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
