###############################################################################
# DC_AllowServerOperatorsScheduleTasks.ps1
# Controlador de dominio: permitir a los operadores de servidor programar tareas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'DC_AllowServerOperatorsScheduleTasks'
  Description      = 'Controlador de dominio: permitir a los operadores de servidor programar tareas'
  Type             = 'Registry'
  Path             = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
  Property         = 'SubmitControl'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
