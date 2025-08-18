###############################################################################
# ProfileExecutor.ps1
# Functions to execute profiles, its groups and policies
###############################################################################

Import-Module "$PSScriptRoot\PolicyExecutor.ps1"

# Function to execute a profile
function Invoke-Profile {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  # Load the profile's info object
  $profilePath = Join-Path $PSScriptRoot "..\Profiles\$ProfileName"
  if (-Not (Test-Path $profilePath)) {
    Exit-WithError "[$ProfileName] No se encontró la carpeta del perfil."
  }

  # Object with profile's execution information
  $ProfileInfo = [PSCustomObject]@{
    Name   = $ProfileName
    Status = 'Pending'
    Groups = @()  # Will contain references to Info objects of each group
  }

  # Check if profile is enabled
  if (-not $Global:Config.ScriptsEnabled[$ProfileName]) {
    $ProfileInfo.Status = 'Skipped'
    Show-Info -Message "[$ProfileName] Perfil no habilitado en la configuración. Saltando ejecución."
    Save-GlobalInfo
    return
  }

  $Global:Info.Profile = $ProfileInfo
  $ProfileInfo.Status = 'Running'
  Save-GlobalInfo

  # Header
  Show-Header3Lines "PERFIL $($ProfileName.Replace('_', ' ').ToUpper())"
  Show-Info -Message "[$ProfileName] Ejecutando la acción '$($Global:Info.Action)'." -NoConsole

  # Gather subfolders from the current directory
  $subfolders = Get-ChildItem -Path $ProfilePath -Directory

  if (-not $subfolders) {
    Show-Warning "[$ProfileName] No se encontraron grupos en el perfil. No se ejecutará ninguna acción."
  }

  foreach ($folder in $subfolders) {
    try {
      Invoke-Group -ProfilePath $profilePath -ProfileInfo $ProfileInfo -GroupName $folder.BaseName
    }
    catch {
      ($ProfileInfo.Groups | Where-Object { $_.Name -eq $folder.BaseName } | Select-Object -First 1).Status = 'Aborted'
      Exit-WithError "[$ProfileName] Ha ocurrido un problema ejecutando el grupo '$($folder.BaseName)': $_"
    }
  }

  # If backup folder exists and it's empty, remove it
  if ($Global:BackupFolderPath -and -not (Get-ChildItem -Path $Global:BackupFolderPath)) {
    Remove-Item -Path $Global:BackupFolderPath -ErrorAction SilentlyContinue
  }

  # Save the profile status as completed
  $ProfileInfo.Status = 'Completed'
  Save-GlobalInfo
}

# Function to execute a group within a profile
function Invoke-Group {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ProfilePath,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$ProfileInfo,
    [Parameter(Mandatory = $true)]
    [string]$GroupName
  )

  # Load the group info object
  $groupPath = Join-Path $ProfilePath "$GroupName"
  if (-Not (Test-Path $groupPath)) {
    Exit-WithError "[$GroupName] Carpeta del grupo no encontrada."
  }

  # Object with group's execution information
  $GroupInfo = [PSCustomObject]@{
    Name     = $GroupName
    Status   = 'Pending'
    Policies = @()  # Here we will store references to the Info objects of each policy
  }

  $ProfileInfo.Groups += $GroupInfo

  # Check if group is enabled
  if (-not $Global:Config.ScriptsEnabled[$ProfileName][$GroupName]) {
    $GroupInfo.Status = 'Skipped'
    Write-Host ""
    Show-Info -Message "[$($GroupName)] Grupo no habilitado en la configuración. Saltando ejecución."
    Save-GlobalInfo
    return
  }

  $GroupInfo.Status = 'Running'
  Save-GlobalInfo

  # Backup file and object for this group's policies
  $backupFilePath = if ($Global:BackupFolderPath) { Join-Path $Global:BackupFolderPath "$($GroupName).json" } else { $null }
  $backup = [ordered]@{}

  # Get all .ps1 files in the folder
  $policyScripts = Get-ChildItem -Path $groupPath -Filter "*.ps1"

  if ($Global:Info.Action -eq "Test" -and $Global:Config.TestOnlyEnabled) {
    # Check if all policies in the group are disabled.
    $anyEnabled = $false
    foreach ($script in $policyScripts) {
      $policyName = $script.BaseName
      if ($Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$policyName]) {
        $anyEnabled = $true
        break
      }
    }
    if (-not $anyEnabled) {
      $GroupInfo.Status = 'Skipped'
      Show-Info -Message "[$($GroupName)] No se encontraron políticas habilitadas en el grupo." -NoConsole
      Save-GlobalInfo
      return
    }
  }

  Show-Header1Line $GroupName.Replace('_', '.').ToLower()
  Show-Info -Message "[$($GroupName)] Ejecutando grupo..." -NoConsole

  switch ($Global:Info.Action) {
    # If action is Test, show table header
    "Test" {
      Show-TableHeader
    }
    "Set" {
      # Initialize backup file with empty JSON object
      try {
        $backupFile = [System.IO.File]::Open($backupFilePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
        $backupFileWriter = [System.IO.StreamWriter]::new($backupFile, [System.Text.Encoding]::UTF8)
        $backupFileWriter.AutoFlush = $true
      }
      catch {
        Exit-WithError -Message "No se ha podido crear el archivo de respaldo: $backupFilePath. $_" -Code -1
      }
      Save-Backup
    }
    "Restore" {
      # Load the backup file if it exists
      if (Test-Path $backupFilePath) {
        $backup = ConvertTo-HashtableRecursive (Get-Content -Path $backupFilePath | ConvertFrom-Json)
      }
      else {
        Show-Info -Message "[$($GroupName)] Omitiendo por no existir archivo de respaldo." -NoConsole
        $GroupInfo.Status = 'Skipped'
        Save-GlobalInfo
        return
      }
    }
  }

  # Load script and perform the action for each policy
  foreach ($script in $policyScripts) {
    try {
      # Object with policy metadata
      $PolicyInfo = [PSCustomObject]@{
        Name   = $script.BaseName
        Status = 'Pending'
      }

      $GroupInfo.Policies += $PolicyInfo
      $PolicyInfo.Status = 'Loading'
      Save-GlobalInfo

      # Load the script using dot sourcing, this includes the $PolicyMeta object
      . $script.FullName
        
      # Skip if the policy is not enabled in the configuration or if the backup does not contain the policy
      if ($Global:Info.Action -eq "Test" -and $Global:Config.TestOnlyEnabled -and $Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$PolicyInfo.Name] -ne $true) {
        $PolicyInfo.Status = 'Skipped'
        Show-Info -Message "[$($PolicyInfo.Name)] Política no habilitada en la configuración." -NoConsole
        Save-GlobalInfo
        continue
      }
      elseif ($Global:Info.Action -eq "Set" -and $Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$PolicyInfo.Name] -ne $true) {
        $PolicyInfo.Status = 'Skipped'
        Show-Info -Message "[$($PolicyInfo.Name)] Política no habilitada en la configuración."
        Save-GlobalInfo
        continue
      }
      elseif ($Global:Info.Action -eq "Restore" -and -not $backup.ContainsKey($PolicyInfo.Name)) {
        $PolicyInfo.Status = 'Skipped'
        Show-Info -Message "[$($PolicyInfo.Name)] Política no encontrada en el archivo de respaldo. Saltando restauración."
        Save-GlobalInfo
        continue
      }

      # Validate the policy metadata
      Show-Info -Message "[$($PolicyInfo.Name)] Validando la estructura del objeto de metadatos de la política..." -NoConsole
      if (-not $PolicyMeta) {
        Exit-WithError "[$($PolicyInfo.Name)] El objeto de metadatos de la política no está definido."
      }
      elseif (-not ($PolicyInfo.Name -eq $PolicyMeta.Name)) {
        Exit-WithError "[$($PolicyInfo.Name)] El nombre de la política en el objeto de metadatos no coincide con el nombre del archivo."
      }
      elseif (-not $PolicyMeta.Type) {
        Exit-WithError "[$($PolicyInfo.Name)] El objeto de metadatos no tiene una clave 'Type' definida."
      }
      else {
        # Dynamically construct the template variable name based on $PolicyMeta.Type
        $dynamicTemplateName = "$($PolicyMeta.Type)PolicyMetaTemplate"

        # Retrieve the template variable
        if (-not (Get-Variable -Name $dynamicTemplateName -ErrorAction SilentlyContinue)) {
          Exit-WithError "[$($PolicyInfo.Name)] No se encontró la plantilla de metadatos para el tipo de política '$($PolicyMeta.Type)'."
        }

        $TypePolicyMetaTemplate = (Get-Variable -Name $dynamicTemplateName -ErrorAction Stop).Value
        
        if (-not (Test-ObjectStructure -Template $TypePolicyMetaTemplate -Target $PolicyMeta -AllowAdditionalProperties)) {
          Exit-WithError "[$($PolicyInfo.Name)] La estructura del objeto de metadatos de la política no es válida, para más información, consulta los registros."
        }
      }
    }
    catch {
      $PolicyInfo.Status = 'Aborted'
      Save-GlobalInfo
      Exit-WithError "[$($GroupName)] Ha ocurrido un problema cargando la política '$($PolicyInfo.Name)': $_"
    }
    try {
      $PolicyInfo.Status = 'Running'
      Save-GlobalInfo
      Show-Info -Message "[$($PolicyInfo.Name)] Ejecutando política..." -NoConsole


      # Look for policy-specific invoke function
      $invokeFunction = "Invoke-$($PolicyMeta.Type)Policy"
      if (Get-Command -Name $invokeFunction -ErrorAction SilentlyContinue) {
        & $invokeFunction -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $backup
      }
      else {
        Exit-WithError "[$($PolicyInfo.Name)] Tipo de política '$($PolicyMeta.Type)' no soportado."
      }

      # Remove the PolicyMeta variable
      Remove-Variable -Name PolicyMeta -Scope Script -ErrorAction SilentlyContinue

      $PolicyInfo.Status = 'Completed'
      Save-GlobalInfo
      Show-Success "[$($PolicyInfo.Name)] Política ejecutada." -NoConsole
    }
    catch {
      $PolicyInfo.Status = 'Aborted'
      Save-GlobalInfo
      Exit-WithError "[$($GroupName)] Ha ocurrido un problema ejecutando la política '$($PolicyInfo.Name)': $_"
    }
  }

  # Close backup file handles
  if ($backupFileWriter) {
    $backupFileWriter.Dispose()
  }
  if ($backupFile) {
    $backupFile.Close()
  }
  # If $backup it's empty, remove the file
  if ($backup.Count -eq 0 -and $backupFilePath) {
    Remove-Item -Path $backupFilePath -ErrorAction SilentlyContinue
  }

  # Save the group state
  $GroupInfo.Status = 'Completed'
  Save-GlobalInfo
  Show-Success "[$($GroupName)] Grupo ejecutado." -NoConsole
}