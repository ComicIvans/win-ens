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
      Set-Content -Path $Global:InfoFilePath -Value $jsonData -Encoding UTF8 -Force
    }
  }
  catch {
    Exit-WithError -Message "Error al guardar la información de ejecución en '$Global:InfoFilePath'. $_" -Code -1
  }
}

# Function to save a group's backup to disk
function Save-Backup {
  # Convert the backup to a JSON string and save it to the file
  try {
    $jsonString = $backup | ConvertTo-Json -Depth 10
    $jsonString | Out-File -FilePath $backupFilePath -Encoding UTF8 -Force
    Show-Info -Message "[$($PolicyInfo.Name)] Archivo de respaldo $($GroupInfo.Name).json guardado." -LogOnly
  }
  catch {
    Exit-WithError "[$($PolicyInfo.Name)] No se ha podido guardar el archivo de respaldo $($GroupInfo.Name).json. $_"
  }
}

# Function to test the structure of an object against a template
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

  # Convert $Target to PSCustomObject if it's a Hashtable or OrderedDictionary
  if ($Target -is [System.Collections.Hashtable] -or $Target -is [System.Collections.Specialized.OrderedDictionary]) {
    $ConvertedTarget = [PSCustomObject]@{ }
    foreach ($key in $Target.Keys) {
      $ConvertedTarget | Add-Member -MemberType NoteProperty -Name $key -Value $Target[$key]
    }
    $Target = $ConvertedTarget
  }

  $TemplateProps = $Template | Get-Member -MemberType NoteProperty
  $TargetProps = $Target | Get-Member -MemberType NoteProperty

  # Check for properties in the template that are not found in the target
  if (@($TemplateProps.Name).Where({ $_ -notin $TargetProps.Name }).Count -gt 0) {
    Show-Warning "Las siguientes propiedades no se encontraron: $(@($TemplateProps.Name).Where({ $_ -notin $TargetProps.Name }) -join ', ')" -LogOnly
    return $false
  }

  # Check for properties in the target that are not found in the template
  if (-not $AllowAdditionalProperties -and @($TargetProps.Name).Where({ $_ -notin $TemplateProps.Name }).count -gt 0) {
    Show-Warning "Se encontraron las siguientes propiedades desconocidas: $(@($TargetProps.Name).Where({ $_ -notin $TemplateProps.Name }) -join ', ')" -LogOnly
    return $false
  }

  # For all properties shared between the objects, check if their values have the same type
  $sharedProps = @($TemplateProps.Name).Where({ $_ -in $TargetProps.Name -and $_ -notin $SkipProperties })
  foreach ($sharedProp in $sharedProps) {
    if ($Template.$sharedProp.GetType() -ne $Target.$sharedProp.GetType()) {
      Show-Warning "La propiedad '$sharedProp' tiene un tipo '$($Target.$sharedProp.GetType())' en lugar de '$($Template.$sharedProp.GetType())'." -LogOnly
      $anyFail = $true
    }
  }

  if ($anyFail) {
    return $false
  }

  # For any properties that are PSObjects, do a recursive call to compare their properties
  foreach ($sharedProp in $sharedProps) {
    if ($Template.$sharedProp.GetType() -eq [System.Management.Automation.PSCustomObject]) {
      Show-Info "Comparando la propiedad '$sharedProp'..." -LogOnly
      if (-not (Test-PSObjectStructure -template $Template.$sharedProp -target $Target.$sharedProp)) {
        $anyFail = $true
      }
    }
  }

  return -not $anyFail
}