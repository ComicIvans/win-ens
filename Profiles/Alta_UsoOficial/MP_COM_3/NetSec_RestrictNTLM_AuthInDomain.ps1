###############################################################################
# NetSec_RestrictNTLM_AuthInDomain.ps1
# Seguridad de red: restringir NTLM: autenticación NTLM en este dominio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetSec_RestrictNTLM_AuthInDomain'
  Description      = 'Seguridad de red: restringir NTLM: autenticación NTLM en este dominio'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'RestrictNTLMInDomain'
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  ExpectedValue    = 1
  AllowedValues    = @(1, 3, 5, 7)
}
