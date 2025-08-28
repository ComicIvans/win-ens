###############################################################################
# System_OptionalSubsystems.ps1
# Configuración del sistema: subsistemas opcionales
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'System_OptionalSubsystems'
  Description      = 'Configuración del sistema: subsistemas opcionales'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems'
  Property         = 'Optional'
  ExpectedValue    = @()
  ValueKind        = 'MultiString'
  ComparisonMethod = 'ExactSet'
}
