###############################################################################
# UAC_UIAccessDesktop.ps1
# Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan
# confirmación de elevación sin usar el escritorio seguro
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
    Name             = 'UAC_UIAccessDesktop'
    Description      = 'Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan confirmación de elevación sin usar el escritorio seguro'
    Type             = 'Registry'
    Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Property         = 'EnableUIADesktopToggle'
    ExpectedValue    = 0
    ValueKind        = 'DWord'
    ComparisonMethod = 'AllowedValues'
    AllowedValues    = @(0)
}
