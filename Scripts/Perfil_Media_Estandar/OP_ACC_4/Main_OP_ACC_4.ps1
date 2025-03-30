###############################################################################
# Main_OP_ACC_4.ps1
# OP.ACC.4: Proceso de gestión de derechos de acceso
###############################################################################

# Objeto con metadatos del grupo
$OP_ACC_4_Info = [PSCustomObject]@{
    Name        = 'OP.ACC.4'
    Description = 'Proceso de gestión de derechos de acceso'
    Status      = 'Pending'
    Error       = ''
    Policies    = @()  # Aquí guardaremos referencias a los objetos .Info de cada política
}

$Global:GlobalInfo.Profile.Groups += $OP_ACC_4_Info
$Global:GlobalInfo.Profile.Status = 'Running'
Save-GlobalInfo

Show-Header1Line $OP_ACC_4_Info.Name
Show-Info "Ejecutando el grupo $($OP_ACC_4_Info.Name): $($OP_ACC_4_Info.Description)." $true

# Obtener el nombre del script actual
$currentScriptName = $MyInvocation.MyCommand.Name

# Obtener todos los .ps1 de la carpeta excepto este mismo
$policyScripts = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" |
Where-Object { $_.Name -ne $currentScriptName }

# Si es acción Test, mostramos cabecera de tabla
if ($Global:GlobalInfo.Action -eq "Test") {
    Show-TableHeader
}
else {
    # Creamos una carpeta para las copias de seguridad de esta categoría
    $backupSubfolderName = [System.IO.Path]::GetFileName($PSScriptRoot)
    $backupSubfolderPath = Join-Path $Global:BackupFolderPath $backupSubfolderName
    if (-not (Test-Path $backupSubfolderPath)) {
        New-Item -Path $backupSubfolderPath -ItemType Directory | Out-Null
    }
}

# Cargamos los scripts de políticas (dot-sourcing)
foreach ($script in $policyScripts) {
    . $script.FullName
}

# Invocamos la función <Action>-<BaseName>
foreach ($script in $policyScripts) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($script.Name)
    $functionName = "$($Global:GlobalInfo.Action)-$baseName"

    try {
        & $functionName
    }
    catch {
        $errMsg = "Ha ocurrido un problema ejecutando '$functionName': $_"
        $OP_ACC_4_Info.Error = $errMsg
        Show-Error $errMsg
        Save-GlobalInfo
    }
}

# Guardamos el estado del grupo
$OP_ACC_4_Info.Status = 'Completed'
Save-GlobalInfo