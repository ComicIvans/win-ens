###############################################################################
# Main_Media_Estandar.ps1
# PERFIL MEDIO-ESTÁNDAR: Categoría = Media, Calificación = Estándar
###############################################################################

# Objeto con metadatos del perfil
$Media_Estandar_Info = [PSCustomObject]@{
    Category      = 'Media'
    Qualification = 'Estándar'
    Status        = 'Pending'
    Error         = ''
    Groups        = @()  # Contendrá referencias a objetos Info de cada grupo
}

# Añadimos $Media_Estandar_Info a $Global:GlobalInfo.Profile como referencia
$Global:GlobalInfo.Profile += $Media_Estandar_Info
$Media_Estandar_Info.Status = 'Running'
Save-GlobalInfo

# Cabecera
Show-Header3Lines "PERFIL MEDIA-ESTÁNDAR"
Show-Info "Ejecutando la acción '$($Global:GlobalInfo.Action)' en el perfil 'Media_Estandar'." $true

# Recopilamos subcarpetas del directorio actual
$subfolders = Get-ChildItem -Path $PSScriptRoot -Directory

foreach ($folder in $subfolders) {
    # Construimos el nombre del script principal en cada subcarpeta
    $mainFileName = "Main_{0}.ps1" -f $folder.BaseName
    $mainFilePath = Join-Path $folder.FullName $mainFileName

    if (Test-Path $mainFilePath) {
        try {
            # Ejecutamos el script principal de la subcarpeta
            & $mainFilePath
        }
        catch {
            $errMsg = "Ha ocurrido un problema ejecutando '$mainFileName': $_"
            $Media_Estandar_Info.Error = $errMsg
            Show-Error $errMsg
            Save-GlobalInfo
        }
    }
    else {
        $errMsg = "No se encontró el script principal '$mainFileName' en la carpeta '$($folder.FullName)'."
        $Media_Estandar_Info.Error = $errMsg
        Show-Error $errMsg
        Save-GlobalInfo
    }
}

# Guardamos el estado del perfil
$Media_Estandar_Info.Status = 'Completed'
Save-GlobalInfo