###############################################################################
# ProfileExecutor.ps1
# Functions to execute profiles, groups and its policies
###############################################################################

function Invoke-Profile {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  # Load the profile's info objet
  $profilePath = Join-Path $PSScriptRoot "$ProfileName"
  $profileScriptPath = Join-Path $profilePath "Main_$ProfileName.ps1"
  if (-Not (Test-Path $profileScriptPath)) {
    Exit-WithError "El punto de entrada para el perfil '$ProfileName' no se encontró."
  }

  . $profileScriptPath

  # Validate the ProfileInfo object
  Test-ProfileInfo -ProfileInfo $ProfileInfo -ProfileName $ProfileName

  # Add this profile's metadata object to $Global:Info.Profile as a reference
  $Global:Info.Profile = $ProfileInfo
  $ProfileInfo.Status = 'Running'
  Save-GlobalInfo

  # Header
  Show-Header3Lines "PERFIL $($ProfileInfo.Name.Replace('_', ' ').ToUpper())"
  Show-Info -Message "Ejecutando la acción '$($Global:Info.Action)' con el perfil '$($ProfileInfo.Name)'." -LogOnly

  # Gather subfolders from the current directory
  $subfolders = Get-ChildItem -Path $ProfilePath -Directory

  foreach ($folder in $subfolders) {
    try {
      Invoke-Group -ProfilePath $profilePath -GroupName $folder.BaseName
    }
    catch {
      $GroupInfo.Status = 'Aborted'
      Exit-WithError "Ha ocurrido un problema ejecutando '$mainFileName': $_"
    }
  }

  # Save the profile status as completed
  $ProfileInfo.Status = 'Completed'
  Save-GlobalInfo
}

function Invoke-Group {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ProfilePath,
    [Parameter(Mandatory = $true)]
    [string]$GroupName
  )

  # Load the group info object
  $groupPath = Join-Path $ProfilePath "$GroupName"
  $groupScriptPath = Join-Path $groupPath "Main_$GroupName.ps1"
  if (-Not (Test-Path $groupScriptPath)) {
    Exit-WithError "El punto de entrada para el grupo '$GroupName' no se encontró."
  }

  . $groupScriptPath

  # Validate the GroupInfo object
  Test-GroupInfo -GroupInfo $GroupInfo -GroupName $GroupName

  # Backup file and object for this group's policies
  $backupFilePath = if ($Global:BackupFolderPath) { Join-Path $Global:BackupFolderPath "$($GroupInfo.Name).json" } else { $null }
  $backup = @{}

  $ProfileInfo.Groups += $GroupInfo
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

  # Get all .ps1 files in the folder except this one
  $policyScripts = Get-ChildItem -Path $groupPath -Filter "*.ps1" |
  Where-Object { $_.Name -ne "Main_$GroupName.ps1" }

  # Load script and invoke the <Action>-Policy function
  foreach ($script in $policyScripts) {
    try {
      # Load the script using dot sourcing, this includes the $PolicyInfo object
      . $script.FullName

      # Validate the PolicyInfo object
      Test-PolicyInfo -PolicyInfo $PolicyInfo -PolicyName $script.BaseName
        
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
      $PolicyInfo.Status = 'Aborted'
      Exit-WithError "Ha ocurrido un problema cargando o ejecutando '$script': $_"
    }
  }

  # Save the group state
  $GroupInfo.Status = 'Completed'
  Save-GlobalInfo
}