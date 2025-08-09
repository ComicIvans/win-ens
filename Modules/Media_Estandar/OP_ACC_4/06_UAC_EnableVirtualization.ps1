###############################################################################
# 06_UAC_EnableVirtualization.ps1
# Control de cuentas de usuario: virtualizar los errores de escritura de archivo
# y de Registro en diferentes ubicaciones por usuario
###############################################################################

# Object with policy's execution information
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyInfo = [PSCustomObject]@{
  Name   = '06_UAC_EnableVirtualization'
  Status = 'Pending'
}

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '06_UAC_EnableVirtualization'
  Description      = 'Control de cuentas de usuario: virtualizar los errores de escritura de archivo y de Registro en diferentes ubicaciones por usuario'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  Property         = 'EnableVirtualization'
  ExpectedValue    = 1
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(1)
}
