###############################################################################
# UAC_EnableInstallerDetection.ps1
# Control de cuentas de usuario: detectar instalaciones de aplicaciones y pedir
# confirmación de elevación
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
    Name             = 'UAC_EnableInstallerDetection'
    Description      = 'Control de cuentas de usuario: detectar instalaciones de aplicaciones y pedir confirmación de elevación'
    Type             = 'Registry'
    Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Property         = 'EnableInstallerDetection'
    ExpectedValue    = 1
    ValueKind        = 'DWord'
    ComparisonMethod = 'AllowedValues'
    AllowedValues    = @(1)
}
