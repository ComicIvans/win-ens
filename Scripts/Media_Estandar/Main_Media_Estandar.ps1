###############################################################################
# Main_Media_Estandar.ps1
# PERFIL MEDIA ESTANDAR: Categoría = Media, Calificación = Estándar
###############################################################################

# Object with profile metadata
$ProfileInfo = [PSCustomObject]@{
    Name   = 'Media_Estandar'
    Status = 'Pending'
    Error  = ''
    Groups = @()  # Will contain references to Info objects of each group
}

# Add this profile's metadata object to $Global:Info.Profile as a reference
$Global:Info.Profile = $ProfileInfo
$ProfileInfo.Status = 'Running'
Save-GlobalInfo

# Header
Show-Header3Lines "PERFIL $($ProfileInfo.Name.Replace('_', ' ').ToUpper())"
Show-Info -Message "Ejecutando la acción '$($Global:Info.Action)' en el perfil '$($ProfileInfo.Name)'." -LogOnly

# Gather subfolders from the current directory
$subfolders = Get-ChildItem -Path $PSScriptRoot -Directory

foreach ($folder in $subfolders) {
    # Build the main script name in each subfolder
    $mainFileName = "Main_{0}.ps1" -f $folder.BaseName
    $mainFilePath = Join-Path $folder.FullName $mainFileName

    if (Test-Path $mainFilePath) {
        try {
            # Execute the main script of the subfolder
            & $mainFilePath
        }
        catch {
            $errMsg = "Ha ocurrido un problema ejecutando '$mainFileName': $_"
            $ProfileInfo.Error = $errMsg
            Show-Error $errMsg
            Save-GlobalInfo
        }
    }
    else {
        $errMsg = "No se encontró el script principal '$mainFileName' en la carpeta '$($folder.FullName)'."
        $ProfileInfo.Error = $errMsg
        Show-Error $errMsg
        Save-GlobalInfo
    }
}

# Save the profile status as completed
$ProfileInfo.Status = 'Completed'
Save-GlobalInfo