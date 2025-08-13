###############################################################################
# Templates.ps1
# Templates for various objects
###############################################################################

# Template for Config
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ConfigTemplate = [PSCustomObject]@{
  EnforceMinimumPolicyValues = $false
  TestOnlyEnabled            = $false
  ScriptsEnabled             = [ordered]@{}
}

# Template for CustomPolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$CustomPolicyMetaTemplate = [PSCustomObject]@{
  Name        = ''
  Description = ''
  Type        = 'Custom'
}

# Template for RegistryPolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$RegistryPolicyMetaTemplate = [PSCustomObject]@{
  Name             = ''
  Description      = ''
  Type             = 'Registry'
  Path             = ''
  Property         = ''
  ExpectedValue    = $null
  ValueKind        = ''
  ComparisonMethod = ''
}

# Template for SecurityPolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$SecurityPolicyMetaTemplate = [PSCustomObject]@{
  Name             = ''
  Description      = ''
  Type             = 'Security'
  Property         = ''
  ExpectedValue    = $null
  ComparisonMethod = ''
}
