###############################################################################
# Utils.ps1
# Utility functions for the other files
###############################################################################

# Function to convert a PSCustomObject or IEnumerable to a hashtable recursively
function ConvertTo-HashtableRecursive {
  param(
    [Parameter(Mandatory)]
    [object]$Object,
    
    [Parameter()]
    [switch]$Ordered
  )

  if ($Object -is [PSCustomObject]) {
    if ($Ordered) {
      $ht = [ordered]@{}
    }
    else {
      $ht = @{}
    }
    
    foreach ($prop in $Object.PSObject.Properties) {
      $ht[$prop.Name] = ConvertTo-HashtableRecursive $prop.Value -Ordered:$Ordered
    }
    return $ht
  }
  elseif ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
    $list = @()
    foreach ($item in $Object) {
      $list += ConvertTo-HashtableRecursive $item -Ordered:$Ordered
    }
    return $list
  }
  else {
    return $Object
  }
}

# Function to save the Global:Info object to a JSON file
function Save-GlobalInfo {
  try {
    if ($Global:InfoFilePath -and $Global:Info) {
      $jsonData = $Global:Info | ConvertTo-Json -Depth 10
      Set-Content -Path $Global:InfoFilePath -Value $jsonData -Encoding UTF8
    }
  }
  catch {
    Exit-WithError -Message "Error al guardar la información de ejecución en '$Global:InfoFilePath', se detendrá la ejecución para evitar realizar cambios que no puedan ser fácilmente restaurados. $_" -Code -1
  }
}

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

# Function to validate a $ProfileInfo object
function Test-ProfileInfo {
  param(
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$ProfileInfo,
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
  )

  if (-not $ProfileInfo) {
    Exit-WithError "No se encontró un objeto de información para '$ProfileName'."
  }
  elseif (-not $ProfileInfo.Name) {
    Exit-WithError "El objeto de información del perfil '$ProfileName' no contiene el campo 'Name'."
  }
  elseif (-not $ProfileInfo.Status) {
    Exit-WithError "El objeto de información del perfil '$ProfileName' no contiene el campo 'Status'."
  }
  elseif ($null -eq $ProfileInfo.Groups) {
    Exit-WithError "El objeto de información del perfil '$ProfileName' no contiene el campo 'Groups'."
  }
}

# Function to validate a $GroupInfo object
function Test-GroupInfo {
  param(
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$GroupInfo,
    [Parameter(Mandatory = $true)]
    [string]$GroupName
  )

  if (-not $GroupInfo) {
    Exit-WithError "No se encontró un objeto de información para el grupo '$GroupName'."
  }
  elseif (-not $GroupInfo.Name) {
    Exit-WithError "El objeto de información del grupo '$GroupName' no contiene el campo 'Name'."
  }
  elseif (-not $GroupInfo.Status) {
    Exit-WithError "El objeto de información del grupo '$GroupName' no contiene el campo 'Status'."
  }
  elseif ($null -eq $GroupInfo.Policies) {
    Exit-WithError "El objeto de información del grupo '$GroupName' no contiene el campo 'Policies'."
  }
}

# Function to validate a $PolicyInfo object
function Test-PolicyInfo {
  param(
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [string]$PolicyName
  )

  if (-not $PolicyInfo) {
    Exit-WithError "No se encontró un objeto de información para la política '$PolicyName'."
  }
  elseif (-not $PolicyInfo.Name) {
    Exit-WithError "El objeto de información de la política '$PolicyName' no contiene el campo 'Name'."
  }
  elseif (-not $PolicyInfo.Status) {
    Exit-WithError "El objeto de información de la política '$PolicyName' no contiene el campo 'Status'."
  }
}