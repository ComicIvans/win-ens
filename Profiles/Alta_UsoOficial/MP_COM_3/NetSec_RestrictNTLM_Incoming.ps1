###############################################################################
# NetSec_RestrictNTLM_Incoming.ps1
# Seguridad de red: restringir NTLM: tráfico NTLM entrante
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetSec_RestrictNTLM_Incoming'
  Description      = 'Seguridad de red: restringir NTLM: tráfico NTLM entrante'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
  Property         = 'RestrictReceivingNTLMTraffic'
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  ExpectedValue    = 1
  AllowedValues    = @(1, 2)
}
