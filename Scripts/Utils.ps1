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
    Exit-WithError -Message "Error al guardar la información de ejecución en $Global:InfoFilePath, se detendrá la ejecución para evitar realizar cambios que no puedan ser fácilmente restaurados. $_" -Code -1
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