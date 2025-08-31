###############################################################################
# RecoveryConsole_AllowFloppyAndAllDrives.ps1
# Consola de recuperación: permitir la copia de disquetes y el acceso a todas
# las unidades y carpetas
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'RecoveryConsole_AllowFloppyAndAllDrives'
  Description      = 'Consola de recuperación: permitir la copia de disquetes y el acceso a todas las unidades y carpetas'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole'
  Property         = 'SetCommand'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
