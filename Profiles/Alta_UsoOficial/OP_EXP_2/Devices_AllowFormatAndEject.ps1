###############################################################################
# Devices_AllowFormatAndEject.ps1
# Dispositivos: permitir formatear y expulsar medios extraíbles
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Devices_AllowFormatAndEject'
  Description      = 'Dispositivos: permitir formatear y expulsar medios extraíbles'
  Type             = 'Registry'
  Path             = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Property         = 'AllocateDASD'
  ExpectedValue    = 0
  ValueKind        = 'DWord'
  ComparisonMethod = 'AllowedValues'
  AllowedValues    = @(0)
}
