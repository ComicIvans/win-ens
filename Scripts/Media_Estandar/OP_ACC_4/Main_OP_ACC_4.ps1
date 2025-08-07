###############################################################################
# Main_OP_ACC_4.ps1
# op.acc.4: Proceso de gestión de derechos de acceso
###############################################################################

# Object with group metadata
$GroupInfo = [PSCustomObject]@{
    Name     = 'OP_ACC_4'
    Status   = 'Pending'
    Error    = ''
    Policies = @()  # Here we will store references to the Info objects of each policy
}

# Backup file and object for this group's policies
$backupFilePath = if ($Global:BackupFolderPath) { Join-Path $Global:BackupFolderPath "$($GroupInfo.Name).json" } else { $null }
$backup = @{}

# Function to save the backup to disk
function Save-Backup {
    # Convert the backup to a JSON string and save it to the file
    try {
        $jsonString = $backup | ConvertTo-Json -Depth 10
        $jsonString | Out-File -FilePath $backupFilePath -Encoding UTF8
        Show-Info -Message "Archivo de respaldo $($GroupInfo.Name).json guardado." -LogOnly
        return $true
    }
    catch {
        $errMsg = "No se ha podido guardar el archivo de respaldo $($GroupInfo.Name).json. $_"
        if ($PolicyInfo) {
            $PolicyInfo.Error = $errMsg
        }
        else {
            $GroupInfo.Error = $errMsg
        }
        Show-Error $errMsg
        Save-GlobalInfo
        return $false
    }
}

$Global:Info.Profile.Groups += $GroupInfo
$GroupInfo.Status = 'Running'
Save-GlobalInfo

Show-Header1Line $GroupInfo.Name.Replace('_', '.').ToLower()
Show-Info -Message "Ejecutando el grupo $($GroupInfo.Name)." -LogOnly

# If action is Test, show table header
if ($Global:Info.Action -eq "Test") {
    Show-TableHeader
}
elseif ($Global:Info.Action -eq "Set") {
    # Initialize backup file with empty JSON object
    if (-not (Save-Backup)) {
        $GroupInfo.Status = 'Completed'
        Save-GlobalInfo
        return
    }
}
elseif ($Global:Info.Action -eq "Restore") {
    # Load the backup file if it exists
    if (Test-Path $backupFilePath) {
        $backup = ConvertTo-HashtableRecursive (Get-Content -Path $backupFilePath | ConvertFrom-Json)
    }
    else {
        Show-Info -Message "Omitiendo el grupo $($GroupInfo.Name) porque no existe archivo de respaldo." -LogOnly
        $GroupInfo.Status = 'Skipped'
        Save-GlobalInfo
        return
    }
}

# Get the name of the current script
$currentScriptName = $MyInvocation.MyCommand.Name

# Get all .ps1 files in the folder except this one
$policyScripts = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" |
Where-Object { $_.Name -ne $currentScriptName }

# Load script and invoke the <Action>-Policy function
foreach ($script in $policyScripts) {
    try {
        # Load the script using dot sourcing, this includes the $PolicyInfo object
        . $script.FullName
        
        # Skip if the policy is not enabled in the configuration or if the backup does not contain the policy
        if ($Global:Info.Action -eq "Set" -and -not $Global:Config.Scripts[$ProfileInfo.Name][$GroupInfo.Name][$PolicyInfo.Name] -eq $true) {
            $PolicyInfo.Status = 'Skipped'
            Show-Info -Message "[$($PolicyInfo.Name)] Política no habilitada en la configuración. Saltando ejecución."
            Save-GlobalInfo
            continue
        }
        elseif ($Global:Info.Action -eq "Restore" -and -not $backup.ContainsKey($PolicyInfo.Name)) {
            $PolicyInfo.Status = 'Skipped'
            Show-Info -Message "[$($PolicyInfo.Name)] Política no encontrada en el archivo de respaldo. Saltando ejecución."
            Save-GlobalInfo
            continue
        }

        # Execute the function
        & "$($Global:Info.Action)-Policy"
    }
    catch {
        $errMsg = "Ha ocurrido un problema cargando o ejecutando '$script': $_"
        $GroupInfo.Error = $errMsg
        Show-Error $errMsg
        Save-GlobalInfo
    }
}

# Save the group state
$GroupInfo.Status = 'Completed'
Save-GlobalInfo