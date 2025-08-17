###############################################################################
# 58_Devices_RestrictFloppy.ps1
# Dispositivos: restringir el acceso a disquetes sólo al usuario con sesión
# iniciada localmente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '58_Devices_RestrictFloppy'
  Description      = 'Dispositivos: restringir el acceso a disquetes sólo al usuario con sesión iniciada localmente'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'AllocateFloppies'
  ExpectedValue    = '1'
  ValueKind        = 'String'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @('1')
}
