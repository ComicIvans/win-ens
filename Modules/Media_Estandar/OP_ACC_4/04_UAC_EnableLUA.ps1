###############################################################################
# 04_UAC_EnableLUA.ps1
# Control de cuentas de usuario: ejecutar todos los administradores en Modo de
# aprobación de administrador
###############################################################################

# Object with policy metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyInfo = [PSCustomObject]@{
    Name   = '04_UAC_EnableLUA'
    Status = 'Pending'
}

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
    Name             = '04_UAC_EnableLUA'
    Description      = 'Control de cuentas de usuario: ejecutar todos los administradores en Modo de aprobación de administrador'
    Type             = 'Registry'
    Path             = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Property         = 'EnableLUA'
    ExpectedValue    = 1
    ValueKind        = 'DWord'
    ComparisonMethod = 'AllowedValues'
    AllowedValues    = @(1)
}