###############################################################################
# NetSec_LDAPClientSigning.ps1
# Seguridad de red: requisitos de firma de cliente LDAP
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'NetSec_LDAPClientSigning'
  Description      = 'Seguridad de red: requisitos de firma de cliente LDAP'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LDAP'
  Property         = 'LDAPClientIntegrity'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1, 2)
}
