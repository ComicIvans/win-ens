###############################################################################
# ProfileExecutor.ps1
# Functions to execute profiles, its groups and policies
###############################################################################

Import-Module "$PSScriptRoot/PolicyExecutor.ps1"

# Function to execute a profile
function Invoke-Profile {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  # Load the profile's info objet
  $profilePath = Join-Path $PSScriptRoot "$ProfileName"
  $profileScriptPath = Join-Path $profilePath "Main_$ProfileName.ps1"
  if (-Not (Test-Path $profileScriptPath)) {
    Exit-WithError "[$ProfileName] El punto de entrada para el perfil no se encontró."
  }

  . $profileScriptPath

  # Validate the ProfileInfo object
  Show-Info -Message "[$($ProfileInfo.Name)] Validando la estructura del objeto de información del perfil..." -LogOnly
  if (-not (Test-ObjectStructure -Template $ProfileInfoTemplate -Target $ProfileInfo -AllowAdditionalProperties)) {
    Exit-WithError "[$ProfileName] La estructura del objeto de información del perfil no es válida, para más información, consulta los registros."
  }

  $Global:Info.Profile = $ProfileInfo
  $ProfileInfo.Status = 'Running'
  Save-GlobalInfo

  # Header
  Show-Header3Lines "PERFIL $($ProfileInfo.Name.Replace('_', ' ').ToUpper())"
  Show-Info -Message "[$($ProfileInfo.Name)] Ejecutando la acción '$($Global:Info.Action)'." -LogOnly

  # Gather subfolders from the current directory
  $subfolders = Get-ChildItem -Path $ProfilePath -Directory

  foreach ($folder in $subfolders) {
    try {
      Invoke-Group -ProfilePath $profilePath -ProfileInfo $ProfileInfo -GroupName $folder.BaseName
    }
    catch {
      ($ProfileInfo.Groups | Where-Object { $_.Name -eq $folder.BaseName } | Select-Object -First 1).Status = 'Aborted'
      Exit-WithError "[$($ProfileInfo.Name)] Ha ocurrido un problema ejecutando el grupo '$($folder.BaseName)': $_"
    }
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
  $groupScriptPath = Join-Path $groupPath "Main_$GroupName.ps1"
  if (-Not (Test-Path $groupScriptPath)) {
    Exit-WithError "[$GroupName] Punto de entrada del grupo no encontrado."
  }

  . $groupScriptPath

  # Validate the GroupInfo object
  Show-Info -Message "[$($GroupInfo.Name)] Validando la estructura del objeto de información del grupo..." -LogOnly
  if (-not (Test-ObjectStructure -Template $GroupInfoTemplate -Target $GroupInfo -AllowAdditionalProperties)) {
    Exit-WithError "[$GroupName] La estructura del objeto de información del grupo no es válida, para más información, consulta los registros."
  }

  $ProfileInfo.Groups += $GroupInfo
  $GroupInfo.Status = 'Running'
  Save-GlobalInfo

  # Backup file and object for this group's policies
  $backupFilePath = if ($Global:BackupFolderPath) { Join-Path $Global:BackupFolderPath "$($GroupInfo.Name).json" } else { $null }
  $backup = @{}

  Show-Header1Line $GroupInfo.Name.Replace('_', '.').ToLower()
  Show-Info -Message "[$($GroupInfo.Name)] Ejecutando grupo..." -LogOnly

  switch ($Global:Info.Action) {
    # If action is Test, show table header
    "Test" {
      Show-TableHeader
    }
    "Set" {
      # Initialize backup file with empty JSON object
      Save-Backup
    }
    "Restore" {
      # Load the backup file if it exists
      if (Test-Path $backupFilePath) {
        $backup = ConvertTo-HashtableRecursive (Get-Content -Path $backupFilePath | ConvertFrom-Json)
      }
      else {
        Show-Info -Message "[$($GroupInfo.Name)] Omitiendo por no existir archivo de respaldo." -LogOnly
        $GroupInfo.Status = 'Skipped'
        Save-GlobalInfo
        return
      }
    }
  }

  # Get all .ps1 files in the folder except the main script
  $policyScripts = Get-ChildItem -Path $groupPath -Filter "*.ps1" |
  Where-Object { $_.Name -ne "Main_$GroupName.ps1" }

  # Load script and perform the action for each policy
  foreach ($script in $policyScripts) {
    try {
      # Load the script using dot sourcing, this includes the $PolicyInfo object
      . $script.FullName

      # Validate the PolicyInfo object
      Show-Info -Message "[$($PolicyInfo.Name)] Validando la estructura del objeto de información de la política..." -LogOnly
      if (-not (Test-ObjectStructure -Template $PolicyInfoTemplate -Target $PolicyInfo -AllowAdditionalProperties)) {
        Exit-WithError "[$($PolicyInfo.Name)] La estructura del objeto de información de la política no es válida, para más información, consulta los registros."
      }

      $GroupInfo.Policies += $PolicyInfo
        
      # Skip if the policy is not enabled in the configuration or if the backup does not contain the policy
      if ($Global:Info.Action -eq "Set" -and $Global:Config.ScriptsEnabled[$ProfileInfo.Name][$GroupInfo.Name][$PolicyInfo.Name] -ne $true) {
        $PolicyInfo.Status = 'Skipped'
        Show-Info -Message "[$($PolicyInfo.Name)] Política no habilitada en la configuración. Saltando ejecución."
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
      Show-Info -Message "[$($PolicyInfo.Name)] Validando la estructura del objeto de metadatos de la política..." -LogOnly
      if (-not (Test-ObjectStructure -Template $PolicyMetaTemplate -Target $PolicyMeta -AllowAdditionalProperties)) {
        Exit-WithError "[$($PolicyInfo.Name)] La estructura del objeto de metadatos de la política no es válida, para más información, consulta los registros."
      }

      $PolicyInfo.Status = 'Running'
      Save-GlobalInfo
      Show-Info -Message "[$($PolicyInfo.Name)] Ejecutando política..." -LogOnly

      switch ($PolicyMeta.Type) {
        "Registry" {
          Invoke-RegistryPolicy -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $backup
        }
        "Custom" {
          $functionsRequired = @(
            "Test-Policy",
            "Set-Policy",
            "Restore-Policy"
          )

          # Check if the required functions are defined
          foreach ($functionName in $functionsRequired) {
            if (-not (Get-Command -Name $functionName -ErrorAction SilentlyContinue)) {
              Exit-WithError "[$($PolicyInfo.Name)] La función '$functionName' no está definida en la política."
            }
          }

          & "$($Global:Info.Action)-Policy" -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $backup

          # Remove the functions after execution to avoid conflicts
          foreach ($functionName in $functionsRequired) {
            if (Test-Path Function:\$functionName) {
              Remove-Item Function:\$functionName
            }
          }
        }
        Default {
          Exit-WithError "[$($PolicyInfo.Name)] Tipo de política '$($PolicyMeta.Type)' no soportado."
        }
      }

      $PolicyInfo.Status = 'Completed'
      Save-GlobalInfo
      Show-Success "[$($PolicyInfo.Name)] Política ejecutada." -LogOnly
    }
    catch {
      $PolicyInfo.Status = 'Aborted'
      Exit-WithError "[$($GroupInfo.Name)] Ha ocurrido un problema cargando o ejecutando la política '$($PolicyInfo.Name)': $_"
    }
  }

  # Save the group state
  $GroupInfo.Status = 'Completed'
  Save-GlobalInfo
  Show-Success "[$($GroupInfo.Name)] Grupo ejecutado." -LogOnly
}