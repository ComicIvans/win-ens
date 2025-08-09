###############################################################################
# Templates.ps1
# Templates for various objects
###############################################################################

# Template for Config
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ConfigTemplate = [PSCustomObject]@{
  EnforceMinimumPolicyValues = $false
  ScriptsEnabled             = [ordered]@{}
}

# Template for ProfileInfo
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$ProfileInfoTemplate = [PSCustomObject]@{
  Name   = ""
  Status = ""
  Groups = @()
}

# Template for GroupInfo
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$GroupInfoTemplate = [PSCustomObject]@{
  Name     = ""
  Status   = ""
  Policies = @()
}

# Template for PolicyInfo
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyInfoTemplate = [PSCustomObject]@{
  Name   = ""
  Status = ""
}

# Template for PolicyMeta
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMetaTemplate = [PSCustomObject]@{
  Name        = ""
  Description = ""
  Type        = ""
}