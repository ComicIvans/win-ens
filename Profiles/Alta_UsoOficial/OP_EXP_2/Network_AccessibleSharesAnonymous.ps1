###############################################################################
# Network_AccessibleSharesAnonymous.ps1
# Acceso a redes: recursos compartidos accesibles anónimamente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_AccessibleSharesAnonymous'
  Description      = 'Acceso a redes: recursos compartidos accesibles anónimamente'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
  Property         = 'NullSessionShares'
  ExpectedValue    = @()
  ValueKind        = 'MultiString'
  ComparisonMethod = 'ExactSet'
}
