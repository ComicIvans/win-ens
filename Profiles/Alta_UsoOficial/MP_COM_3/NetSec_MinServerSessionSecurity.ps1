###############################################################################
# NetSec_MinServerSessionSecurity.ps1
# Seguridad de red: seguridad de sesión mínima para servidores NTLM basados en
# SSP (incluida RPC segura)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetSec_MinServerSessionSecurity'
  Description      = 'Seguridad de red: seguridad de sesión mínima para servidores NTLM basados en SSP (incluida RPC segura)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
  Property         = 'NtlmMinServerSec'
  ExpectedValue    = 537395200
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(537395200)
}
