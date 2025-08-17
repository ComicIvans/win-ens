###############################################################################
# 52_System_StrengthenDefaultSystemObjects.ps1
# Objetos de sistema: reforzar los permisos predeterminados de los objetos
# internos del sistema (por ejemplo, vínculos simbólicos)
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '52_System_StrengthenDefaultSystemObjects'
  Description      = 'Objetos de sistema: reforzar los permisos predeterminados de los objetos internos del sistema (por ejemplo, vínculos simbólicos)'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
  Property         = 'ProtectionMode'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
