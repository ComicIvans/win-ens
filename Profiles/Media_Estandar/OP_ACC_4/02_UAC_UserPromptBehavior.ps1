###############################################################################
# 02_UAC_UserPromptBehavior.ps1
# Control de cuentas de usuario: comportamiento de la petición de elevación
# para los usuarios estándar
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
    Name             = '02_UAC_UserPromptBehavior'
    Description      = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los usuarios estándar'
    Type             = 'Registry'
    Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Property         = 'ConsentPromptBehaviorUser'
    ExpectedValue    = 1
    ValueKind        = 'DWord'
    ComparisonMethod = 'AllowedValues'
    AllowedValues    = @(0, 1)
}