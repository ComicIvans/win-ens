###############################################################################
# 59_Devices_RestrictCDROM.ps1
# Dispositivos: restringir el acceso al CD-ROM sólo al usuario con sesión
# iniciada localmente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = '59_Devices_RestrictCDROM'
  Description      = 'Dispositivos: restringir el acceso al CD-ROM sólo al usuario con sesión iniciada localmente'
  Type             = 'Registry'
  Path             = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'AllocateCDRoms'
  ExpectedValue    = '1'
  ValueKind        = 'String'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @('1')
}
