###############################################################################
# Templates.ps1
# Templates for various objects
###############################################################################

# Template for Config
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ConfigTemplate = [PSCustomObject]@{
  EnforceMinimumPolicyValues       = $false
  TestOnlyEnabled                  = $false
  SaveResultsAsCSV                 = $false
  StopOnProfileError               = $true
  MaxValidationIterations          = 5
  RemoveUnknownPrivilegeSetEntries = $false
  ScriptsEnabled                   = [ordered]@{}
}

# Template for CustomPolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$CustomPolicyMetaTemplate = [PSCustomObject]@{
  Name        = ''
  Description = ''
  Type        = 'Custom'
  IsValid     = $null
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
  Area             = ''
  Property         = ''
  ExpectedValue    = $null
  ComparisonMethod = ''
}

# Template for ServicePolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ServicePolicyMetaTemplate = [PSCustomObject]@{
  Name          = ''
  Description   = ''
  Type          = 'Service'
  ServiceName   = ''
  ExpectedValue = ''
}