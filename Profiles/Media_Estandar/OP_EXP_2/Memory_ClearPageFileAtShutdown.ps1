###############################################################################
# Memory_ClearPageFileAtShutdown.ps1
# Apagado: borrar el archivo de paginación de la memoria virtual
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Memory_ClearPageFileAtShutdown'
  Description      = 'Apagado: borrar el archivo de paginación de la memoria virtual'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
  Property         = 'ClearPageFileAtShutdown'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
