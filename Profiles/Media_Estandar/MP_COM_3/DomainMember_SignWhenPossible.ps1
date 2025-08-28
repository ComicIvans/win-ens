###############################################################################
# DomainMember_SignWhenPossible.ps1
# Miembro de dominio: firmar digitalmente datos de un canal seguro
# (cuando sea posible)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DomainMember_SignWhenPossible'
  Description      = 'Miembro de dominio: firmar digitalmente datos de un canal seguro (cuando sea posible)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'SignSecureChannel'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
