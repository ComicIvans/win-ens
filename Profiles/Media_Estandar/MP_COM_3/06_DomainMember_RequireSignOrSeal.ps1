###############################################################################
# 06_DomainMember_RequireSignOrSeal.ps1
# Miembro de dominio: cifrar o firmar digitalmente datos de un canal
# seguro (siempre)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '06_DomainMember_RequireSignOrSeal'
  Description      = 'Miembro de dominio: cifrar o firmar digitalmente datos de un canal seguro (siempre)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'RequireSignOrSeal'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
