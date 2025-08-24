###############################################################################
# 12_NetSec_RestrictNTLM_AuditIncoming.ps1
# Seguridad de red: restringir NTLM: auditar el tráfico NTLM entrante
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '12_NetSec_RestrictNTLM_AuditIncoming'
  Description      = 'Seguridad de red: restringir NTLM: auditar el tráfico NTLM entrante'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
  Property         = 'AuditReceivingNTLMTraffic'
  ExpectedValue    = 2
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(2)
}
