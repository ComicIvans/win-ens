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

  $configFilePath = Join-Path $PSScriptRoot $ConfigFile
  $configIsNew = $false

  if (Test-Path $configFilePath) {
    Show-Info "Cargando archivo de configuración..."
    try {
      $Global:Config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
      $Global:Config = ConvertTo-HashtableRecursive -Object $Global:Config -Ordered
    }
    catch {
      Show-Error "No se ha podido cargar el archivo de configuración. $_"
      return $false
    }
  }
  else {
    Show-Info "No se ha encontrado el archivo de configuración $ConfigFile. Generando uno nuevo..."
    $configIsNew = $true
  }

  # A local version is created to save or compare with the loaded one
  $localConfig = Get-LocalConfig $true

  if ($configIsNew) {
    # We create and save the new configuration
    try {
      $jsonString = $localConfig | ConvertTo-Json -Depth 10
      $jsonString | Out-File -FilePath $configFilePath -Encoding UTF8
      Show-Success "Archivo de configuración $ConfigFile creado."
      $Global:Config = $localConfig
    }
    catch {
      Show-Error "No se ha podido crear el archivo de configuración $ConfigFile. $_"
      return $false
    }
  }
  else {
    # Compare the global configuration with the local one
    if (-not (Compare-Config $localConfig)) {
      Show-Warning "El archivo de configuración cargado tiene diferencias en los perfiles, grupos o políticas actuales, comprueba la configuración para ver las diferencias."
    }
    Show-Success "Archivo de configuración $ConfigFile cargado."
  }
  return $true
}

# Function to create a config object with the current structure of profiles, groups, and policies and optionally print issues found
function Get-LocalConfig {
  param(
    [Parameter()]
    $printAndLog = $false
  )

  $localConfig = [ordered]@{
    Scripts = [ordered]@{}
  }
  
  $profDirs = Get-ChildItem -Path $PSScriptRoot -Directory -ErrorAction SilentlyContinue
  
  foreach ($profDir in $profDirs) {
    $expectedProfileMain = "Main_{0}.ps1" -f $profDir.Name
    $profileMainPath = Join-Path $profDir.FullName $expectedProfileMain
    if (-not (Test-Path $profileMainPath) -and $printAndLog) {
      Show-Error "La carpeta de perfil '$($profDir.Name)' no tiene el archivo '$expectedProfileMain', por lo que no será posible ejecutar dicho perfil."
    }

    # If the Scripts key for the profile does not exist, we create it
    if (-not $localConfig.Scripts.Contains($profDir.Name)) {
      $localConfig.Scripts[$profDir.Name] = [ordered]@{}
    }
  
    # Get the group folders
    $groupDirs = Get-ChildItem -Path $profDir.FullName -Directory -ErrorAction SilentlyContinue

    foreach ($groupDir in $groupDirs) {
      $expectedGroupMain = "Main_{0}.ps1" -f $groupDir.Name
      $groupMainPath = Join-Path $groupDir.FullName $expectedGroupMain
      if (-not (Test-Path $groupMainPath) -and $printAndLog) {
        Show-Error "La carpeta de grupo '$($groupDir.Name)' no tiene el archivo '$expectedGroupMain', por lo que no será posible ejecutar dicho grupo dentro del perfil '$($profDir.Name)'."
      }

      # If the group key does not exist in the profile, we create it
      if (-not $localConfig.Scripts[$profDir.Name].Contains($groupDir.Name)) {
        $localConfig.Scripts[$profDir.Name][$groupDir.Name] = [ordered]@{}
      }

      # Policies: any file that is not the main one for that group
      $policyFiles = Get-ChildItem -Path $groupDir.FullName -File -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -ne $expectedGroupMain }

      foreach ($file in $policyFiles) {
        $policyName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        # We assign true to enable the policy by default
        $localConfig.Scripts[$profDir.Name][$groupDir.Name][$policyName] = $true
      }
    }
  }
  return $localConfig
}

# Function to compare the global configuration with the local one
function Compare-Config {
  param(
    [Parameter(Mandatory = $true)]
    $localConfig
  )

  # Convert both to a subset with only the names
  $globalSubset = Get-ConfigSubset $Global:Config
  $localSubset = Get-ConfigSubset $localConfig

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

  Show-Header3Lines "Configuración de políticas"
  
  # Get the local configuration
  $localConfig = Get-LocalConfig

  # Create a list of all profiles from the local configuration
  $profiles = $localConfig.Scripts.Keys
  Write-Host "¿Qué configuración quieres visualizar?:" -ForegroundColor White
  Write-Host "0) Todos los perfiles" -ForegroundColor DarkCyan
  $index = 1
  foreach ($prof in $profiles) {
    Write-Host ("{0}) Perfil {1}" -f $index, $prof) -ForegroundColor DarkCyan
    $index++
  }
  $choiceNumber = Read-Host -Prompt "Introduce el número correspondiente"
  
  if ($choiceNumber -eq 0) {
    $profilesToShow = $profiles
  }
  elseif (($choiceNumber -ge 1) -and ($choiceNumber -le $profiles.Count)) {
    $profilesArray = @($profiles)
    $selectedProfile = $profilesArray[$choiceNumber - 1]
    $profilesToShow = @($selectedProfile)
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
    if ($localConfig.Scripts.Contains($prof)) { 
      $localGroups = $localConfig.Scripts[$prof].Keys 
    }
    $globalGroups = @()
    if ($Global:Config.Scripts.Contains($prof)) { 
      $globalGroups = $Global:Config.Scripts[$prof].Keys 
    }
    $allGroups = ($localGroups + $globalGroups | Select-Object -Unique)
      
    foreach ($group in $allGroups) {
      $diffLocalNotInGlobal[$prof][$group] = @()
      $diffGlobalNotInLocal[$prof][$group] = @()
          
      $localScripts = @()
      if (($localConfig.Scripts[$prof]) -and ($localConfig.Scripts[$prof].Contains($group))) {
        $localScripts = $localConfig.Scripts[$prof][$group].Keys
      }
      $globalScripts = @()
      if (($Global:Config.Scripts[$prof]) -and ($Global:Config.Scripts[$prof].Contains($group))) {
        $globalScripts = $Global:Config.Scripts[$prof][$group].Keys
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
            $globalGroup = $Global:Config.Scripts[$prof][$group]
            $localGroup = $localConfig.Scripts[$prof][$group]
            $mergedGroup = Merge-PolicyGroup -GlobalGroup $globalGroup -LocalGroup $localGroup
            $Global:Config.Scripts[$prof][$group] = $mergedGroup
            Save-Config $ConfigFile
          }
        }
      }
    }
  }
  
  # Show the current global configuration
  Show-Header1Line "Configuración global actual"

  Write-Host "En verde se muestran los scripts habilitados, en rojo los deshabilitados, en azul los nuevos que no estaban contemplados en la configuración, y en amarillo los que se encontraban en la configuración pero no están presentes." -ForegroundColor DarkGray
  Write-Host ""

  foreach ($prof in $profilesToShow) {
    Write-Host "Perfil: $prof" -ForegroundColor Magenta
    foreach ($group in $Global:Config.Scripts[$prof].Keys) {
      Write-Host " Grupo: $group" -ForegroundColor Cyan
          
      $globalScripts = $Global:Config.Scripts[$prof][$group].Keys
      $localScripts = @()
      if (($localConfig.Scripts[$prof]) -and ($localConfig.Scripts[$prof].Contains($group))) {
        $localScripts = $localConfig.Scripts[$prof][$group].Keys
      }
      $allScripts = ($globalScripts + $localScripts | Select-Object -Unique)
      foreach ($script in $allScripts) {
        $color = "Black"
        if ($Global:Config.Scripts[$prof][$group].Contains($script)) {
          $status = $Global:Config.Scripts[$prof][$group][$script]
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

# Function to extract a subset of the configuration with only the names of profiles, groups, and policies
function Get-ConfigSubset {
  param(
    [Parameter(Mandatory = $true)]
    $Config
  )
  
  if (-not $Config.Scripts) {
    return @{ Scripts = @{} }
  }

  $subset = @{}

  foreach ($profileName in $Config.Scripts.Keys) {
    $subset[$profileName] = @{}

    foreach ($grupoName in $Config.Scripts[$profileName].Keys) {
      $subset[$profileName][$grupoName] = @()

      $polDict = $Config.Scripts[$profileName][$grupoName]
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
    [Parameter(Mandatory)]
    [hashtable]$GlobalGroup,
    [Parameter(Mandatory)]
    [hashtable]$LocalGroup
  )
  
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

  $configFilePath = Join-Path $PSScriptRoot $ConfigFile

  # Convert the global configuration to a JSON string and save it to the file
  try {
    $jsonString = $Global:Config | ConvertTo-Json -Depth 10
    $jsonString | Out-File -FilePath $configFilePath -Encoding UTF8
    Show-Info -Message "Archivo de configuración $ConfigFile guardado." -LogOnly
  }
  catch {
    $errMsg = "No se ha podido guardar el archivo de configuración. $_"
    $Global:Info.Error = $errMsg
    Save-GlobalInfo
    Show-Error $errMsg
    Write-Host ""
  }
}