###############################################################################
# 14_NetSec_LocalSystemUseComputerIdentityForNTLM.ps1
# Seguridad de red: permitir que LocalSystem use la identidad del equipo para
# NTLM
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '14_NetSec_LocalSystemUseComputerIdentityForNTLM'
  Description      = 'Seguridad de red: permitir que LocalSystem use la identidad del equipo para NTLM'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'UseMachineId'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
