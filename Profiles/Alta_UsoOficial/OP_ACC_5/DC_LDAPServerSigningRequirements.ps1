###############################################################################
# DC_LDAPServerSigningRequirements.ps1
# Controlador de dominio: requisitos de firma de servidor LDAP
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DC_LDAPServerSigningRequirements'
  Description      = 'Controlador de dominio: requisitos de firma de servidor LDAP'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
  Property         = 'LDAPServerIntegrity'
  ExpectedValue    = 2
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(2)
}
