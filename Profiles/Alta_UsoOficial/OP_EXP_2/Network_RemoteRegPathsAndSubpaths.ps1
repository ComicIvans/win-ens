###############################################################################
# Network_RemoteRegPathsAndSubpaths.ps1
# Acceso a redes: rutas y subrutas del Registro accesibles remotamente
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name             = 'Network_RemoteRegPathsAndSubpaths'
  Description      = 'Acceso a redes: rutas y subrutas del Registro accesibles remotamente'
  Type             = 'Registry'
  Path             = 'HKLM:\System\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths'
  Property         = 'Machine'
  ValueKind        = 'MultiString'
  ExpectedValue    = @(
    'Software\Microsoft\OLAP Server',
    'Software\Microsoft\Windows NT\CurrentVersion\Perflib',
    'Software\Microsoft\Windows NT\CurrentVersion\Print',
    'Software\Microsoft\Windows NT\CurrentVersion\Windows',
    'System\CurrentControlSet\Control\ContentIndex',
    'System\CurrentControlSet\Control\Print\Printers',
    'System\CurrentControlSet\Control\Terminal Server',
    'System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration',
    'System\CurrentControlSet\Control\Terminal Server\UserConfig',
    'System\CurrentControlSet\Services\CertSvc',
    'System\CurrentControlSet\Services\EventLog',
    'System\CurrentControlSet\Services\SysmonLog',
    'System\CurrentControlSet\Services\WINS'
  )
  ComparisonMethod = 'ExactSet'
}
