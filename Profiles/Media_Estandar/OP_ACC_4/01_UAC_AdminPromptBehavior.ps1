###############################################################################
# 01_UAC_AdminPromptBehavior.ps1
# Control de cuentas de usuario: comportamiento de la petición de elevación
# para los administradores en Modo de aprobación de administrador
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
    Name             = '01_UAC_AdminPromptBehavior'
    Description      = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los administradores en Modo de aprobación de administrador'
    Type             = 'Registry'
    Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Property         = 'ConsentPromptBehaviorAdmin'
    ExpectedValue    = 2
    ValueKind        = 'DWord'
    ComparisonMethod = 'AllowedValues'
    AllowedValues    = @(1, 2)
}
