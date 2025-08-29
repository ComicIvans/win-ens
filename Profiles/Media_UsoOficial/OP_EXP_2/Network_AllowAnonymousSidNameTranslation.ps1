###############################################################################
# Network_AllowAnonymousSidNameTranslation.ps1
# Acceso de red: permitir traducción SID/nombre anónima
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_AllowAnonymousSidNameTranslation'
  Description      = 'Acceso de red: permitir traducción SID/nombre anónima'
  Type             = 'Security'
  Area             = 'System Access'
  Property         = 'LSAAnonymousNameLookup'
  ExpectedValue    = 0
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
