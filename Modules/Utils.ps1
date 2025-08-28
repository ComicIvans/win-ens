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
    $ht = if ($Ordered) { [ordered]@{} } else { @{} }
    foreach ($prop in $Object.PSObject.Properties) {
      $ht[$prop.Name] = if ($null -eq $prop.Value) { $null } else { ConvertTo-HashtableRecursive -Object $prop.Value -Ordered:$Ordered }
    }
    return $ht
  }
  elseif ($Object -is [System.Collections.IDictionary]) {
    $ht = if ($Ordered) { [ordered]@{} } else { @{} }
    $keys = if ($Ordered) { $Object.Keys | Sort-Object } else { $Object.Keys }
    foreach ($key in $keys) {
      $val = $Object[$key]
      $ht[$key] = if ($null -eq $val) { $null } else { ConvertTo-HashtableRecursive -Object $val -Ordered:$Ordered }
    }
    return $ht
  }
  elseif ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
    $list = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Object) {
      $list.Add( $(if ($null -eq $item) { $null } else { ConvertTo-HashtableRecursive -Object $item -Ordered:$Ordered }) )
    }
    return , ($list.ToArray())
  }
  else {
    return $Object
  }
}

# Function to save the Global:Info object to a JSON file
function Save-GlobalInfo {
  try {
    $jsonData = $Global:Info | ConvertTo-Json -Depth 10
    # Remove previous content and write the new info
    $Global:InfoFile.SetLength(0)
    $Global:InfoWriter.WriteLine($jsonData)
  }
  catch {
    Exit-WithError -Message "Error al guardar la información de ejecución en '$($Global:InfoFile.Name)'. $_" -Code -1
  }
}

# Function to save a group's backup to disk
function Save-Backup {
  # Convert the backup to a JSON string and save it to the file
  try {
    $jsonString = $backup | ConvertTo-Json -Depth 10
    # Remove previous content and write the new backup
    $backupFile.SetLength(0)
    $backupFileWriter.WriteLine($jsonString)
    Show-Info -Message "[$($PolicyInfo.Name)] Archivo de respaldo $($GroupInfo.Name).json guardado." -NoConsole
  }
  catch {
    Exit-WithError "[$($PolicyInfo.Name)] No se ha podido guardar el archivo de respaldo $($GroupInfo.Name).json. $_"
  }
}

# Function to test the structure of an object against a template. This does not validate objects inside arrays
Function Test-ObjectStructure {
  param(
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Template,
    [Parameter(Mandatory = $true)]
    [object]$Target,
    [Parameter()]
    [string[]]$SkipProperties = @(),
    [Parameter()]
    [switch]$AllowAdditionalProperties
  )

  $anyFail = $false

  # Normalize hashtable-like targets to PSCustomObject
  if ($Target -is [System.Collections.Hashtable] -or $Target -is [System.Collections.Specialized.OrderedDictionary]) {
    $converted = [PSCustomObject]@{}
    foreach ($key in $Target.Keys) {
      $converted | Add-Member -MemberType NoteProperty -Name $key -Value $Target[$key]
    }
    $Target = $converted
  }

  $templateProps = ($Template | Get-Member -MemberType NoteProperty).Name
  $targetProps = ($Target | Get-Member -MemberType NoteProperty).Name

  # Check for properties in the template that are not found in the target
  $missing = $templateProps | Where-Object { $_ -notin $targetProps }
  if ($missing.Count -gt 0) {
    Show-Warning "Las siguientes propiedades no se encontraron: $($missing -join ', ')" -NoConsole
    return $false
  }

  # Check for properties in the target that are not found in the template
  if (-not $AllowAdditionalProperties) {
    $unknown = $targetProps | Where-Object { $_ -notin $templateProps }
    if ($unknown.Count -gt 0) {
      Show-Warning "Se encontraron las siguientes propiedades desconocidas: $($unknown -join ', ')" -NoConsole
      return $false
    }
  }

  # For all non-null properties shared between the objects, check if their values have the same type
  $sharedProps = $templateProps | Where-Object { ($_ -in $targetProps) -and ($_ -notin $SkipProperties) -and ($null -ne $Template.$_) }
  foreach ($sharedProp in $sharedProps) {
    if ($Template.$sharedProp.GetType() -ne $Target.$sharedProp.GetType()) {
      Show-Warning "La propiedad '$sharedProp' tiene un tipo '$($Target.$sharedProp.GetType())' en lugar de '$($Template.$sharedProp.GetType())'." -NoConsole
      $anyFail = $true
    }
  }

  if ($anyFail) {
    return $false
  }

  $sharedProps = $sharedProps.Where({ $_ -notin $SkipProperties })
  # For any properties that are PSObjects, do a recursive call to compare their properties
  foreach ($sharedProp in $sharedProps) {
    if ($Template.$sharedProp -is [PSCustomObject]) {
      Show-Info "Comparando la propiedad '$sharedProp'..." -NoConsole
      if (-not (Test-ObjectStructure -Template $Template.$sharedProp -Target $Target.$sharedProp -SkipProperties $SkipProperties -AllowAdditionalProperties:$AllowAdditionalProperties)) {
        $anyFail = $true
      }
    }
  }

  return -not $anyFail
}