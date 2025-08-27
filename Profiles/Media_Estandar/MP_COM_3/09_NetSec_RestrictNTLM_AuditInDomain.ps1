###############################################################################
# 09_NetSec_RestrictNTLM_AuditInDomain.ps1
# Seguridad de red: restringir NTLM: auditar la autenticación NTLM
# en este dominio
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '09_NetSec_RestrictNTLM_AuditInDomain'
  Description      = 'Seguridad de red: restringir NTLM: auditar la autenticación NTLM en este dominio'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
  Property         = 'AuditNtlmInDomain'
  ExpectedValue    = 7
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(7)
}
