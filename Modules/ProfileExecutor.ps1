###############################################################################
# ProfileExecutor.ps1
# Functions to execute profiles, its groups and policies
###############################################################################

Import-Module "$PSScriptRoot\PolicyExecutor.ps1"
Import-Module "$PSScriptRoot\Manifest.ps1"

$Global:GroupMetaStore = [ordered]@{}
$Global:PolicyMetaStore = [ordered]@{}

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
    return
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
    Show-Info -Message "[$ProfileName] Perfil no presente en la configuración. Saltando ejecución."
    Save-GlobalInfo
    return
  }

  $Global:Info.Profile = $ProfileInfo
  $ProfileInfo.Status = 'Running'
  Save-GlobalInfo

  # Header
  Show-Header3Lines "PERFIL $($ProfileName.Replace('_', ' ').ToUpper())"
  Show-Info -Message "[$ProfileName] Ejecutando la acción '$($Global:Info.Action)'." -NoConsole

  # Load manifest and execute groups in its order
  $profileManifest = Get-ProfileManifest -ProfileName $ProfileName

  if (-not $profileManifest -or -not $profileManifest.Groups -or $profileManifest.Groups.Count -eq 0) {
    Show-Warning "[$ProfileName] No se encontraron grupos en el manifest del perfil. No se ejecutará ninguna acción."
  }
  else {
    # First iteration: Initialize all groups and policies
    foreach ($g in $profileManifest.Groups) {
      $groupName = $g.Name
      try {
        Show-Info -Message "[$GroupName] Inicializando grupo..."
        $Global:GroupMetaStore[$groupName] = [PSCustomObject]@{
          Name           = $groupName
          ShouldExecute  = $true
          Initialized    = $false
          BackupFilePath = $null
          Backup         = $null
          GroupInfo      = [PSCustomObject]@{
            Name     = $GroupName
            Status   = 'Pending'
            Policies = @()  # Here we will store references to the Info objects of each policy
          }
        }
        $ProfileInfo.Groups += $Global:GroupMetaStore[$groupName].GroupInfo
        Invoke-Group -ProfileName $ProfileName -ProfilePath $profilePath -GroupName $groupName -GroupMeta $Global:GroupMetaStore[$groupName] -Manifest $g -Action "Initialize"
      }
      catch {
        $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Aborted'
        Save-GlobalInfo
        Exit-WithError "[$ProfileName] Ha ocurrido un problema inicializando el grupo '$groupName': $_"
        continue
      }
      Show-Success -Message "[$GroupName] Grupo inicializado." -NoConsole
    }

    # Filter groups that should be executed and have been initialized
    $ExecutableGroups = $profileManifest.Groups | Where-Object {
      $groupName = $_.Name
      $Global:GroupMetaStore[$groupName].ShouldExecute -and $Global:GroupMetaStore[$groupName].Initialized
    }

    # Second iteration: Backup if action is "Set"
    if ($Global:Info.Action -eq "Set") {
      foreach ($g in $ExecutableGroups) {
        $groupName = $g.Name
        try {
          Show-Info -Message "[$GroupName] Realizando copia de respaldo..."
          Invoke-Group -ProfileName $ProfileName -ProfilePath $profilePath -GroupName $groupName -GroupMeta $Global:GroupMetaStore[$groupName] -Manifest $g -Action "Backup"
        }
        catch {
          $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Aborted'
          Save-GlobalInfo
          Exit-WithError "[$ProfileName] Ha ocurrido un problema realizando la copia de respaldo del grupo '$groupName': $_"
          continue
        }
        Show-Success -Message "[$GroupName] Copia de respaldo realizada." -NoConsole
      }
    }

    # Third iteration: Execute the action for each group
    foreach ($g in $ExecutableGroups) {
      $groupName = $g.Name
      try {
        Show-Info -Message "[$GroupName] Ejecutando la acción '$($Global:Info.Action)'." -NoConsole
        Invoke-Group -ProfileName $ProfileName -ProfilePath $profilePath -GroupName $groupName -GroupMeta $Global:GroupMetaStore[$groupName] -Manifest $g -Action $Global:Info.Action
      }
      catch {
        $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Aborted'
        Save-GlobalInfo
        Exit-WithError "[$ProfileName] Ha ocurrido un problema ejecutando el grupo '$groupName': $_"
        continue
      }
      Show-Success -Message "[$GroupName] Grupo ejecutado." -NoConsole
      $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Completed'
      Save-GlobalInfo
    }

    # Fourth to n iterations: Validate "Set" or "Restore" results
    if (($Global:Info.Action -eq "Set" -or $Global:Info.Action -eq "Restore") -and $Global:Config.MaxValidationIterations -gt 0) {
      Show-Header1Line "Validación de la acción"
      $loopCount = 0
      do {
        $loopCount++
        $Global:AnyPolicyNotValidated = $false
        $Global:SecpolLines = $null
        foreach ($g in $ExecutableGroups) {
          $groupName = $g.Name
          try {
            Show-Info -Message "[$GroupName] Validando el grupo (iteración nº $loopCount)..."
            Invoke-Group -ProfileName $ProfileName -ProfilePath $profilePath -GroupName $groupName -GroupMeta $Global:GroupMetaStore[$groupName] -Manifest $g -Action "Assert"
          }
          catch {
            $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Aborted'
            Save-GlobalInfo
            Exit-WithError "[$ProfileName] Ha ocurrido un problema validando el grupo '$groupName': $_"
            continue
          }
          Show-Success -Message "[$GroupName] Grupo validado." -NoConsole
          $Global:GroupMetaStore[$groupName].GroupInfo.Status = 'Completed'
          Save-GlobalInfo
        }
      } while ($Global:AnyPolicyNotValidated -and $loopCount -lt $Global:Config.MaxValidationIterations)
      if ($Global:AnyPolicyNotValidated) {
        switch ($Global:Info.Action) {
          "Set" {
            Exit-WithError -Message "[$ProfileName] Se ha alcanzado el número máximo de iteraciones para validar ejecución del grupo, por lo que puede que haya políticas que no se hayan ajustado."
          }
          "Restore" {
            Exit-WithError -Message "[$ProfileName] Se ha alcanzado el número máximo de iteraciones para validar ejecución del grupo, por lo que puede que haya políticas que no se hayan restaurado."
          }
        }
        return
      }
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
    [string]$ProfileName,
    [Parameter(Mandatory = $true)]
    [string]$ProfilePath,
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$GroupMeta,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Manifest,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Initialize', 'Test', 'Backup', 'Set', 'Restore', 'Assert')]
    [string]$Action
  )

  if (-not $GroupMeta.Initialized -and $Action -ne "Initialize") {
    Show-Warning -Message "[$GroupName] El grupo no ha sido inicializado, por lo que no se ejecutará la acción." -NoConsole
    $GroupMeta.GroupInfo.Status = 'Aborted'
    Save-GlobalInfo
    return
  }

  $GroupMeta.GroupInfo.Status = $Action
  Save-GlobalInfo

  switch ($Action) {
    "Initialize" {
      $groupPath = Join-Path $ProfilePath "$GroupName"
      if (-Not (Test-Path $groupPath)) {
        Exit-WithError "[$GroupName] Carpeta del grupo no encontrada."
        return
      }

      $GroupMeta.ShouldExecute = $true

      # Check if group is enabled
      if (-not $Global:Config.ScriptsEnabled[$ProfileName][$GroupName]) {
        $GroupMeta.GroupInfo.Status = 'Skipped'
        Write-Host ""
        Show-Info -Message "[$GroupName] Grupo no presente en la configuración. No se ejecutará." -NoConsole
        Save-GlobalInfo
        $GroupMeta.ShouldExecute = $false
        return
      }

      # Build the policy script list in the order defined by the manifest
      $policyScripts = New-Object System.Collections.Generic.List[object]
      $manifestPolicies = @()
      if ($Manifest -and $Manifest.Policies) { $manifestPolicies = @($Manifest.Policies) }
      foreach ($p in $manifestPolicies) {
        $policyPath = Join-Path $groupPath ($p + '.ps1')
        $policyScripts.Add([PSCustomObject]@{ BaseName = $p; FullName = $policyPath })
      }

      if ($Global:Info.Action -eq "Set" -or ($Global:Info.Action -eq "Test" -and $Global:Config.TestOnlyEnabled)) {
        # Check if all policies in the group are disabled
        $anyEnabled = $false
        foreach ($script in $policyScripts) {
          $policyName = $script.BaseName
          if ($Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$policyName]) {
            $anyEnabled = $true
            break
          }
        }
        if (-not $anyEnabled) {
          $GroupMeta.GroupInfo.Status = 'Skipped'
          Show-Info -Message "[$GroupName] No se encontraron políticas habilitadas en el grupo."
          Save-GlobalInfo
          $GroupMeta.ShouldExecute = $false
          return
        }
      }

      # Backup file and object for this group's policies
      $GroupMeta.BackupFilePath = if ($Global:BackupFolderPath) { Join-Path $Global:BackupFolderPath "$GroupName.json" } else { $null }
      $GroupMeta.Backup = [ordered]@{}

      if ($Global:Info.Action -eq "Restore") {
        # Load the backup file if it exists
        if (Test-Path $GroupMeta.BackupFilePath) {
          $GroupMeta.Backup = ConvertTo-HashtableRecursive (Get-Content -Path $GroupMeta.BackupFilePath -Encoding UTF8 | ConvertFrom-Json)
        }
        else {
          Show-Info -Message "[$GroupName] Omitiendo por no existir archivo de respaldo." -NoConsole
          $GroupMeta.GroupInfo.Status = 'Skipped'
          Save-GlobalInfo
          $GroupMeta.ShouldExecute = $false
          return
        }
      }

      # Load each script and store its $PolicyMeta object inside $Global:PolicyMetaStore
      $Global:PolicyMetaStore[$GroupName] = [ordered]@{}
      foreach ($script in $policyScripts) {
        try {
          # Object with policy's execution information
          $PolicyInfo = [PSCustomObject]@{
            Name   = $script.BaseName
            Status = 'Pending'
          }

          $GroupMeta.GroupInfo.Policies += $PolicyInfo
          $PolicyInfo.Status = 'Loading'
          Save-GlobalInfo
        
          # Skip if the policy is not enabled in the configuration or if the backup does not contain the policy
          if ($Global:Info.Action -eq "Test" -and $Global:Config.TestOnlyEnabled -and $Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$PolicyInfo.Name] -ne $true) {
            $PolicyInfo.Status = 'Skipped'
            Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Política no habilitada en la configuración."
            Save-GlobalInfo
            continue
          }
          elseif ($Global:Info.Action -eq "Set" -and $Global:Config.ScriptsEnabled[$ProfileName][$GroupName][$PolicyInfo.Name] -ne $true) {
            $PolicyInfo.Status = 'Skipped'
            Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Política no habilitada en la configuración."
            Save-GlobalInfo
            continue
          }
          elseif ($Global:Info.Action -eq "Restore" -and -not $GroupMeta.Backup.Contains($PolicyInfo.Name)) {
            $PolicyInfo.Status = 'Skipped'
            Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Política no encontrada en el archivo de respaldo. No se restaurará."
            Save-GlobalInfo
            continue
          }

          # Load the script using dot sourcing, this includes the $PolicyMeta object
          . $script.FullName

          # Validate the policy metadata
          Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Validando la estructura del objeto de metadatos de la política..." -NoConsole
          if (-not $PolicyMeta) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] El objeto de metadatos de la política no está definido."
            continue
          }
          elseif (-not ($PolicyInfo.Name -eq $PolicyMeta.Name)) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] El nombre de la política en el objeto de metadatos no coincide con el nombre del archivo."
            continue
          }
          elseif (-not $PolicyMeta.Type) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] El objeto de metadatos no tiene una clave 'Type' definida."
            continue
          }
          else {
            # Dynamically construct the template variable name based on $PolicyMeta.Type
            $dynamicTemplateName = "$($PolicyMeta.Type)PolicyMetaTemplate"

            # Retrieve the template variable
            if (-not (Get-Variable -Name $dynamicTemplateName -ErrorAction SilentlyContinue)) {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se encontró la plantilla de metadatos para el tipo de política '$($PolicyMeta.Type)'."
              continue
            }

            $TypePolicyMetaTemplate = (Get-Variable -Name $dynamicTemplateName -ErrorAction Stop).Value
        
            if (-not (Test-ObjectStructure -Template $TypePolicyMetaTemplate -Target $PolicyMeta -AllowAdditionalProperties)) {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] La estructura del objeto de metadatos de la política no es válida, para más información, consulta los registros."
              continue
            }
          }

          # Initialize properties if they don't exist
          if ($null -eq $PolicyMeta.Initialized) {
            $PolicyMeta | Add-Member -NotePropertyName Initialized -NotePropertyValue $false -Force
          }
          if ($null -eq $PolicyMeta.IsValid) {
            $PolicyMeta | Add-Member -NotePropertyName IsValid -NotePropertyValue $false -Force
          }
          if ($null -eq $PolicyMeta.CurrentValue) {
            $PolicyMeta | Add-Member -NotePropertyName CurrentValue -NotePropertyValue $null -Force
          }

          # Look for policy-specific invoke function
          $invokeFunction = "Invoke-$($PolicyMeta.Type)Policy"
          if (-not (Get-Command -Name $invokeFunction -ErrorAction SilentlyContinue)) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Tipo de política '$($PolicyMeta.Type)' no soportado."
            continue
          }

          $Global:PolicyMetaStore[$GroupName][$PolicyInfo.Name] = $PolicyMeta
          Remove-Variable -Name PolicyMeta -ErrorAction SilentlyContinue
        
          $PolicyInfo.Status = 'Loaded'
          Save-GlobalInfo
        }
        catch {
          $PolicyInfo.Status = 'Aborted'
          Save-GlobalInfo
          Exit-WithError "[$GroupName] Ha ocurrido un problema cargando la política '$($PolicyInfo.Name)': $_"
          continue
        }
      }
      $GroupMeta.Initialized = $true
    }
    "Test" {
      Show-Header1Line $GroupName.Replace('_', '.').ToLower()
      Show-TableHeader
    }
    "Backup" {
      # Initialize backup file with empty JSON object
      try {
        $backupFile = [System.IO.File]::Open($GroupMeta.BackupFilePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
        $backupFileWriter = [System.IO.StreamWriter]::new($backupFile, [System.Text.Encoding]::UTF8)
        $backupFileWriter.AutoFlush = $true
      }
      catch {
        Exit-WithError -Message "[$GroupName] No se ha podido crear el archivo de respaldo: $($GroupMeta.BackupFilePath). $_" -Code -2
      }
      Save-Backup
    }
    "Set" {
      Show-Header1Line $GroupName.Replace('_', '.').ToLower()
    }
    "Restore" {
      Show-Header1Line $GroupName.Replace('_', '.').ToLower()
    }
    "Assert" {}
  }

  # Reset all policies' status
  foreach ($p in $Global:PolicyMetaStore[$GroupName].Keys) {
    $PolicyInfo = $GroupMeta.GroupInfo.Policies | Where-Object { $_.Name -eq $p }
    $PolicyInfo.Status = 'Pending'
  }
  Save-GlobalInfo

  # Perform the action for each policy
  foreach ($p in $Global:PolicyMetaStore[$GroupName].Keys) {
    try {
      $PolicyInfo = $GroupMeta.GroupInfo.Policies | Where-Object { $_.Name -eq $p }

      if (($Action -eq "Set" -or $Action -eq "Assert") -and -not $GroupMeta.Backup.Contains($PolicyInfo.Name)) {
        $PolicyInfo.Status = 'Skipped'
        Save-GlobalInfo
        Show-Warning "[$GroupName] [$($PolicyInfo.Name)] No se ha encontrado una copia de respaldo para esta política, por lo que no se ajustará."
        continue
      }

      $PolicyInfo.Status = 'Running'
      Save-GlobalInfo
      Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Ejecutando acción '$Action'..." -NoConsole

      if ($Global:PolicyMetaStore[$GroupName][$PolicyInfo.Name].Type -eq "Custom") {
        # Load custom functions
        $scriptPath = Join-Path $ProfilePath "$GroupName\$($PolicyInfo.Name).ps1"
        . $scriptPath
      }
      $PolicyMeta = $Global:PolicyMetaStore[$GroupName][$PolicyInfo.Name]

      $invokeFunction = "Invoke-$($PolicyMeta.Type)Policy"
      & $invokeFunction -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $GroupMeta.Backup -Action $Action

      $PolicyInfo.Status = 'Completed'
      Save-GlobalInfo
      Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ejecutada." -NoConsole
    }
    catch {
      $PolicyInfo.Status = 'Aborted'
      Save-GlobalInfo
      Exit-WithError "[$GroupName] Ha ocurrido un problema ejecutando la política '$($PolicyInfo.Name)': $_"
      continue
    }
  }

  if ($Action -eq "Backup") {
    # Close backup file handles
    if ($backupFileWriter) {
      $backupFileWriter.Dispose()
    }
    if ($backupFile) {
      $backupFile.Close()
    }
    # If $GroupMeta.Backup it's empty, remove the file
    if ($GroupMeta.Backup.Count -eq 0 -and $GroupMeta.BackupFilePath) {
      Remove-Item -Path $GroupMeta.BackupFilePath -ErrorAction SilentlyContinue
    }
  }
}