###############################################################################
# Config.ps1
# Functions for script configuration
###############################################################################

# Global object for configuration
$Global:Config = [PSCustomObject]@{}

# Function to initialize the configuration either from an existing file or by creating a new one
function Initialize-Configuration {
  param(
    [Parameter()]
    [string] $ConfigFile = "config.json"
  )

  # Build the path to the configuration file relative to the project root
  $configFilePath = Join-Path $PSScriptRoot "../$ConfigFile"
  $configIsNew = $false

  # A local version is created to save or compare with the loaded one
  $localConfig = Get-LocalConfig -PrintAndLog

  if (Test-Path $configFilePath) {
    Show-Info "Cargando archivo de configuración..." -LogOnly
    try {
      $loadedFile = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
      $loadedFile = ConvertTo-HashtableRecursive -Object $loadedFile -Ordered
      $Global:Config = Get-LocalConfig
      # Change all keys in the global config to match the loaded file
      foreach ($key in $loadedFile.Keys) {
        if ($Global:Config.Keys -contains $key) {
          $Global:Config[$key] = $loadedFile[$key]
        }
        else {
          Show-Warning "La clave '$key' del archivo de configuración es desconocida, se eliminará."
        }
      }
      Show-Info "Comprobando estructura del archivo de configuración..." -LogOnly
      if (-not (Test-ObjectStructure -Template $ConfigTemplate -Target $Global:Config -SkipProperties @("ScriptsEnabled"))) {
        Exit-WithError "El archivo de configuración '$ConfigFile' no tiene la estructura correcta, para más información, consulta los registros."
      }
      $newKeys = @($Global:Config.Keys) | Where-Object { -not (@($loadedFile.Keys) -contains $_) }
      if ($newKeys.Count -gt 0) {
        Show-Info "Añadiendo nuevas claves al archivo de configuración: $($newKeys -join ', ')"
      }
      # Save the configuration to ensure keys are ordered and consistent
      Save-Config
    }
    catch {
      Exit-WithError "No se ha podido cargar el archivo de configuración. $_"
    }
  }
  else {
    Show-Info "No se ha encontrado el archivo de configuración $ConfigFile. Generando uno nuevo..."
    $configIsNew = $true
  }

  if ($configIsNew) {
    # We create and save the new configuration
    try {
      $jsonString = $localConfig | ConvertTo-Json -Depth 10
      $jsonString | Out-File -FilePath $configFilePath -Encoding UTF8
      Show-Success "Archivo de configuración $ConfigFile creado."
      $Global:Config = $localConfig
    }
    catch {
      Exit-WithError "No se ha podido crear el archivo de configuración $ConfigFile. $_"
    }
  }
  else {
    # Compare the global configuration with the local one
    if (-not (Compare-ScriptsEnabled $localConfig)) {
      Show-Warning "El archivo de configuración tiene diferencias en los perfiles, grupos o políticas actuales, comprueba la configuración para ver las diferencias."
    }
    Show-Success "Archivo de configuración $ConfigFile cargado."
  }
}

# Function to create a config object with all default keys, including the current structure of profiles, groups, and policies and optionally print issues found
function Get-LocalConfig {
  param(
    [Parameter()]
    [switch] $PrintAndLog
  )

  $localConfig = [ordered]@{
    EnforceMinimumPolicyValues = $false
    ScriptsEnabled             = [ordered]@{}
  }
  
  $profDirs = Get-ChildItem -Path $PSScriptRoot -Directory -ErrorAction SilentlyContinue
  if ($PrintAndLog -and -not $profDirs) {
    Show-Warning "No se han encontrado carpetas de perfiles en el directorio '$PSScriptRoot', por lo que no será posible ejecutar ninguna acción."
  }
  
  foreach ($profDir in $profDirs) {
    $expectedProfileMain = "Main_{0}.ps1" -f $profDir.Name
    $profileMainPath = Join-Path $profDir.FullName $expectedProfileMain
    if ($PrintAndLog -and -not (Test-Path $profileMainPath)) {
      Show-Warning "La carpeta de perfil '$($profDir.Name)' no tiene el archivo '$expectedProfileMain', por lo que no será posible ejecutar dicho perfil."
    }

    # If the Scripts key for the profile does not exist, we create it
    if (-not $localConfig.ScriptsEnabled.Contains($profDir.Name)) {
      $localConfig.ScriptsEnabled[$profDir.Name] = [ordered]@{}
    }
  
    # Get the group folders
    $groupDirs = Get-ChildItem -Path $profDir.FullName -Directory -ErrorAction SilentlyContinue
    if ($PrintAndLog -and -not $groupDirs) {
      Show-Warning "No se han encontrado carpetas de grupos en el directorio '$($profDir.FullName)', por lo que no será posible ejecutar dicho perfil."
    }

    foreach ($groupDir in $groupDirs) {
      $expectedGroupMain = "Main_{0}.ps1" -f $groupDir.Name
      $groupMainPath = Join-Path $groupDir.FullName $expectedGroupMain
      if ($PrintAndLog -and -not (Test-Path $groupMainPath)) {
        Show-Warning "La carpeta de grupo '$($groupDir.Name)' dentro del perfil '$($profDir.Name)' no tiene el archivo '$expectedGroupMain', por lo que no será posible ejecutar dicho grupo."
      }

      # If the group key does not exist in the profile, we create it
      if (-not $localConfig.ScriptsEnabled[$profDir.Name].Contains($groupDir.Name)) {
        $localConfig.ScriptsEnabled[$profDir.Name][$groupDir.Name] = [ordered]@{}
      }

      # Policies: any file that is not the main one for that group
      $policyFiles = Get-ChildItem -Path $groupDir.FullName -File -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -ne $expectedGroupMain }

      foreach ($file in $policyFiles) {
        $policyName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        # We assign true to enable the policy by default
        $localConfig.ScriptsEnabled[$profDir.Name][$groupDir.Name][$policyName] = $true
      }
    }
  }
  return $localConfig
}

# Function to compare the ScriptsEnabled between the global and local configurations
function Compare-ScriptsEnabled {
  param(
    [Parameter(Mandatory = $true)]
    $localConfig
  )

  # Convert both to a subset with only the names
  $globalSubset = Get-ScriptsEnabledSubset $Global:Config
  $localSubset = Get-ScriptsEnabledSubset $localConfig

  $serializedGlobal = $globalSubset | ConvertTo-Json -Depth 10
  $serializedLocal = $localSubset  | ConvertTo-Json -Depth 10

  return $serializedGlobal -eq $serializedLocal
}

# Function to show the current configuration, allowing to visualize discrepancies between the saved file and the current state
function Show-Config {
  param(
    [Parameter()]
    [string] $ConfigFile = "config.json"
  )

  Show-Header3Lines "CONFIGURACIÓN ACTUAL"
  
  Show-Header1Line "Configuración general"

  # Dictionary with descriptions for each general config key
  $configDescriptions = @{
    "EnforceMinimumPolicyValues" = "Si está activado, se fuerza el valor mínimo requerido por cada política, sobrescribiendo valores más seguros"
  }

  # Print all general config keys except ScriptsEnabled
  foreach ($key in $Global:Config.Keys) {
    if ($key -ne "ScriptsEnabled") {
      $desc = $configDescriptions[$key]
      $rawValue = $Global:Config[$key]
      if ($rawValue -is [bool]) {
        $value = if ($rawValue) { "Habilitado" } else { "Deshabilitado" }
      }
      else {
        $value = $rawValue
      }
      Write-Host ("{0}: " -f $key) -NoNewline -ForegroundColor Magenta
      Write-Host ("{0} " -f $desc) -ForegroundColor Gray
      Write-Host (" -> Valor actual: ") -NoNewline -ForegroundColor Gray
      Write-Host ("{0}" -f $value) -ForegroundColor Blue
    }
  }

  Show-Header1Line "Configuración relativa a políticas"

  # Get the local configuration
  $localConfig = Get-LocalConfig

  # Create a list of all profiles from the local and global configuration, without duplicates
  $profiles = ($localConfig.ScriptsEnabled.Keys + $Global:Config.ScriptsEnabled.Keys | Select-Object -Unique)
  Write-Host "¿Qué configuración quieres visualizar?:" -ForegroundColor White
  Write-Host "0) Todos los perfiles" -ForegroundColor DarkCyan
  $index = 1
  foreach ($prof in $profiles) {
    Write-Host ("{0}) Perfil {1}" -f $index, $prof) -ForegroundColor DarkCyan
    $index++
  }
  Write-Host ("{0}) Ninguno" -f $index) -ForegroundColor DarkCyan
  $choiceNumber = Read-Host -Prompt "Introduce el número correspondiente"
      
  if ($choiceNumber -eq 0) {
    $profilesToShow = $profiles
  }
  elseif (($choiceNumber -ge 1) -and ($choiceNumber -le $profiles.Count)) {
    $profilesArray = @($profiles)
    $selectedProfile = $profilesArray[$choiceNumber - 1]
    $profilesToShow = @($selectedProfile)
  }
  elseif ($choiceNumber -eq $index) {
    Write-Host "Volviendo al menú principal..." -ForegroundColor Gray
    return
  }
  else {
    Write-Host "Selección no válida." -ForegroundColor Red
    return
  }

  $diffLocalNotInGlobal = @{}    # Scripts present in the local config but not in the global
  $diffGlobalNotInLocal = @{}    # Scripts present in the global config but not in the local

  foreach ($prof in $profilesToShow) {
    $diffLocalNotInGlobal[$prof] = @{}
    $diffGlobalNotInLocal[$prof] = @{}
      
    # Get the groups for the profile in the local and global configurations
    $localGroups = @()
    if ($localConfig.ScriptsEnabled.Contains($prof)) { 
      $localGroups = $localConfig.ScriptsEnabled[$prof].Keys 
    }
    $globalGroups = @()
    if ($Global:Config.ScriptsEnabled.Contains($prof)) { 
      $globalGroups = $Global:Config.ScriptsEnabled[$prof].Keys 
    }
    $allGroups = ($localGroups + $globalGroups | Select-Object -Unique)
      
    foreach ($group in $allGroups) {
      $diffLocalNotInGlobal[$prof][$group] = @()
      $diffGlobalNotInLocal[$prof][$group] = @()
          
      $localScripts = @()
      if (($localConfig.ScriptsEnabled[$prof]) -and ($localConfig.ScriptsEnabled[$prof].Contains($group))) {
        $localScripts = $localConfig.ScriptsEnabled[$prof][$group].Keys
      }
      $globalScripts = @()
      if (($Global:Config.ScriptsEnabled[$prof]) -and ($Global:Config.ScriptsEnabled[$prof].Contains($group))) {
        $globalScripts = $Global:Config.ScriptsEnabled[$prof][$group].Keys
      }
      $allScripts = ($localScripts + $globalScripts | Select-Object -Unique)
          
      foreach ($script in $allScripts) {
        if ($globalScripts -notcontains $script) {
          # Exists in local but not in global
          $diffLocalNotInGlobal[$prof][$group] += $script
        }
        if ($localScripts -notcontains $script) {
          # Exists in global but not detected in local
          $diffGlobalNotInLocal[$prof][$group] += $script
        }
      }
    }
  }

  # Check if there are discrepancies between the configurations
  $foundDiscrepancies = $false
  foreach ($prof in $profilesToShow) {
    foreach ($group in ($diffLocalNotInGlobal[$prof].Keys)) {
      if ($diffLocalNotInGlobal[$prof][$group].Count -gt 0) {
        $foundDiscrepancies = $true
        break
      }
    }
    if (-not $foundDiscrepancies) {
      foreach ($group in ($diffGlobalNotInLocal[$prof].Keys)) {
        if ($diffGlobalNotInLocal[$prof][$group].Count -gt 0) {
          $foundDiscrepancies = $true
          break
        }
      }
    }
    if ($foundDiscrepancies) { break }
  }
  
  # If discrepancies were found, we show a message and the details
  if ($foundDiscrepancies) {
    Show-Header1Line "Discrepancias detectadas en la configuración"
    foreach ($prof in $profilesToShow) {
      Write-Host "Perfil: $prof" -ForegroundColor Magenta
      # Join the keys of both dictionaries to get all groups with differences
      $groupsWithDiff = ($diffLocalNotInGlobal[$prof].Keys + $diffGlobalNotInLocal[$prof].Keys | Select-Object -Unique)
      foreach ($group in $groupsWithDiff) {
        Write-Host " Grupo: $group" -ForegroundColor Cyan
        if ($diffLocalNotInGlobal[$prof].Contains($group) -and $diffLocalNotInGlobal[$prof][$group].Count -gt 0) {
          foreach ($script in $diffLocalNotInGlobal[$prof][$group]) {
            Write-Host "  -> La polítia '$script' no se contemplaba en la configuración. No se aplicará salvo que se agregue a la configuración." -ForegroundColor Blue
          }
        }
        if ($diffGlobalNotInLocal[$prof].Contains($group) -and $diffGlobalNotInLocal[$prof][$group].Count -gt 0) {
          foreach ($script in $diffGlobalNotInLocal[$prof][$group]) {
            Write-Host "  -> La polítia '$script' se contempla en la configuración pero no se ha encontrado su archivo correspondiente. No se aplicará." -ForegroundColor Yellow
          }
        }
        if ($diffLocalNotInGlobal[$prof][$group].Count -gt 0) {
          Write-Host ""
          $userResp = Read-Host "¿Deseas añadir las políticas no contempladas a la configuración global y habilitarlas? (S/N)"
          Write-Host ""
          if ($userResp -match '^[SsYy]') {
            # Merge the local group with the global one
            $globalGroup = $Global:Config.ScriptsEnabled[$prof][$group]
            $localGroup = $localConfig.ScriptsEnabled[$prof][$group]
            $mergedGroup = Merge-PolicyGroup -GlobalGroup $globalGroup -LocalGroup $localGroup
            $Global:Config.ScriptsEnabled[$prof][$group] = $mergedGroup
            Save-Config $ConfigFile
          }
        }
      }
    }
    Write-Host ""
  }
  
  # Show the current global configuration
  Show-Header1Line "Estado de las políticas actuales"

  Write-Host "En verde se muestran los scripts habilitados, en rojo los deshabilitados, en azul los nuevos que no estaban contemplados en la configuración, y en amarillo los que se encontraban en la configuración pero no están presentes." -ForegroundColor DarkGray
  Write-Host ""

  foreach ($prof in $profilesToShow) {
    Write-Host "Perfil: $prof" -ForegroundColor Magenta
    foreach ($group in $Global:Config.ScriptsEnabled[$prof].Keys) {
      Write-Host " Grupo: $group" -ForegroundColor Cyan
          
      $globalScripts = $Global:Config.ScriptsEnabled[$prof][$group].Keys
      $localScripts = @()
      if (($localConfig.ScriptsEnabled[$prof]) -and ($localConfig.ScriptsEnabled[$prof].Contains($group))) {
        $localScripts = $localConfig.ScriptsEnabled[$prof][$group].Keys
      }
      $allScripts = ($globalScripts + $localScripts | Select-Object -Unique)
      foreach ($script in $allScripts) {
        $color = "Black"
        if ($Global:Config.ScriptsEnabled[$prof][$group].Contains($script)) {
          $status = $Global:Config.ScriptsEnabled[$prof][$group][$script]
          if ($status -eq $true) {
            $color = "Green"      # Enabled
          }
          else {
            $color = "Red"        # Disabled
          }
        }
        # If the script is in the global config but not in the local one, it is shown in yellow
        if (($localScripts -notcontains $script) -and ($globalScripts -contains $script)) {
          $color = "Yellow"
        }
        # If the script is only in the local config, it is shown in blue
        if ($diffLocalNotInGlobal[$prof].Contains($group) -and ($diffLocalNotInGlobal[$prof][$group] -contains $script)) {
          $color = "Blue"
        }
        Write-Host "    Script: $script" -ForegroundColor $color
      }
    }
    Write-Host ""
  }
  
  Write-Host "Presiona Enter para volver al menú."
  Read-Host
}

# Function to extract a subset of the configuration with only ScriptsEnabled and the names of its profiles, groups, and policies
function Get-ScriptsEnabledSubset {
  param(
    [Parameter(Mandatory = $true)]
    $Config
  )
  
  if (-not $Config.ScriptsEnabled) {
    return @{ Scripts = @{} }
  }

  $subset = @{}

  foreach ($profileName in $Config.ScriptsEnabled.Keys) {
    $subset[$profileName] = @{}

    foreach ($grupoName in $Config.ScriptsEnabled[$profileName].Keys) {
      $subset[$profileName][$grupoName] = @()

      $polDict = $Config.ScriptsEnabled[$profileName][$grupoName]
      foreach ($policyName in $polDict.Keys) {
        # Only include the policy name, not its value
        $subset[$profileName][$grupoName] += $policyName
      }
    }
  }

  return $subset
}

# Function to merge a policy group from the local configuration into the global one, keeping the global group's values and adding local group's new policies
function Merge-PolicyGroup {
  param(
    [Parameter()]
    [hashtable]$GlobalGroup,
    [Parameter()]
    [hashtable]$LocalGroup
  )

  if ($null -eq $GlobalGroup) {
    $GlobalGroup = [ordered]@{}
  }
  if ($null -eq $LocalGroup) {
    $LocalGroup = [ordered]@{}
  }

  # Get all keys from both groups, ensuring uniqueness
  $allKeys = ($GlobalGroup.Keys + $LocalGroup.Keys | Select-Object -Unique)

  # Sort the keys; if they have numeric prefixes, sort them naturally
  $sortedKeys = $allKeys | Sort-Object { 
    if ($_ -match '^(\d+)_') { 
      [int]$matches[1] 
    }
    else { 
      $_ 
    }
  }
  
  $mergedGroup = [ordered]@{}
  foreach ($key in $sortedKeys) {
    # If the key exists in the global group, keep its value (true/false)
    if ($GlobalGroup.ContainsKey($key)) {
      $mergedGroup[$key] = $GlobalGroup[$key]
    }
    # If it doesn't exist in global but does in local, add it
    elseif ($LocalGroup.ContainsKey($key)) {
      $mergedGroup[$key] = $LocalGroup[$key]
    }
  }
  
  return $mergedGroup
}

# Function to save the current configuration to a file
function Save-Config {
  param(
    [Parameter()]
    [string] $ConfigFile = "config.json"
  )

  $configFilePath = Join-Path $PSScriptRoot "../$ConfigFile"

  # Convert the global configuration to a JSON string and save it to the file
  try {
    $jsonString = $Global:Config | ConvertTo-Json -Depth 10
    $jsonString | Out-File -FilePath $configFilePath -Encoding UTF8
    Show-Info -Message "Archivo de configuración $ConfigFile guardado." -LogOnly
  }
  catch {
    Exit-WithError "No se ha podido guardar el archivo de configuración. $_"
  }
}