###############################################################################
# PolicyExecutor.ps1
# Functions to execute common policy types
###############################################################################

# Handles the execution of custom policies
function Invoke-CustomPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup
  )

  # Check if the required functions are defined: Initialize-Policy, Test-Policy, Backup-Policy, Set-Policy and Restore-Policy
  $requiredFunctions = @(
    "Initialize-Policy",
    "Test-Policy",
    "Backup-Policy",
    "Set-Policy",
    "Restore-Policy"
  )

  foreach ($function in $requiredFunctions) {
    if (-not (Get-Command -Name $function -ErrorAction SilentlyContinue)) {
      Exit-WithError "[$($PolicyInfo.Name)] La función '$function' no está definida en la política."
    }
  }

  # Initialize the policy
  try {
    Initialize-Policy
  }
  catch {
    Exit-WithError "[$($PolicyInfo.Name)] Error al inicializar la política: $_"
  }

  # Perform the action
  switch ($Global:Info.Action) {
    "Test" {
      try {
        Test-Policy
      }
      catch {
        Exit-WithError "[$($PolicyInfo.Name)] Error al comprobar la política: $_"
      }
    }
    "Set" {
      if ($PolicyMeta.IsValid) {
        Show-Info -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        try {
          Backup-Policy
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] Error al crear la copia de respaldo: $_"
        }
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          Set-Policy
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] Error al ajustar la política: $_"
        }
        Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
      try {
        Restore-Policy
      }
      catch {
        Exit-WithError "[$($PolicyInfo.Name)] Error al restaurar la política: $_"
      }
      Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada correctamente."
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Acción '$($Global:Info.Action)' no soportada."
    }
  }

  # Clean all required functions
  foreach ($function in $requiredFunctions) {
    Remove-Item Function:\$function -ErrorAction SilentlyContinue
  }
}


# Handles the execution of registry-based policies
function Invoke-RegistryPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup
  )

  # Get current registry value
  try {
    $currentValue = (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop) | Select-Object -ExpandProperty $PolicyMeta.Property
    if ($null -eq $currentValue) {
      if ($PolicyMeta.ValueKind -eq "MultiString") {
        $currentValue = @()
      }
      elseif ($PolicyMeta.ValueKind -eq "String") {
        $currentValue = ""
      }
    }
  }
  catch {
    $currentValue = $null
  }

  # Validate current value against policy
  $isValid = $false

  switch ($PolicyMeta.ComparisonMethod) {
    "AllowedValues" {
      if ($null -eq $PolicyMeta.AllowedValues) {
        Exit-WithError "[$($PolicyInfo.Name)] No se han definido valores permitidos para esta política."
      }
      elseif ($PolicyMeta.AllowedValues -contains $currentValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "GreaterOrEqual" {
      if ($null -ne $currentValue -and $currentValue -ge $PolicyMeta.ExpectedValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "LessOrEqual" {
      if ($null -ne $currentValue -and $currentValue -le $PolicyMeta.ExpectedValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "ExactSet" {
      function ConvertTo-NormalizedSet {
        param (
          [Parameter()]
          [object]$Source
        )

        if ($null -eq $Source) { return , @() }

        $items =
        if ($Source -is [string]) { $Source.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries) }
        elseif ($Source -is [System.Array]) { $Source }
        else { @($Source) }

        $tokens = foreach ($v in $items) {
          $t = $v.ToString().Trim()
          if (-not $t) { continue }
          $t
        }

        return , (@(@($tokens) | Sort-Object -Unique))
      }

      # Normalize current and expected values to sets
      $currentSet = ConvertTo-NormalizedSet -Source $currentValue
      $expectedSet = ConvertTo-NormalizedSet -Source $PolicyMeta.ExpectedValue

      $isValid = ($null -eq $currentValue -and $null -eq $PolicyMeta.ExpectedValue)
      # Compare as sets
      if ($null -ne $currentValue -and $null -ne $PolicyMeta.ExpectedValue) {
        $isValid = -not (Compare-Object -ReferenceObject $currentSet -DifferenceObject $expectedSet)
      }
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Método de comparación '$($PolicyMeta.ComparisonMethod)' no soportado."
    }
  }

  switch ($Global:Info.Action) {
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $currentValue -ValidValue:$isValid
    }
    "Set" {
      if ($isValid) {
        Show-Info -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Take a backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          # Verify if the registry path exists
          if (-not (Test-Path -Path $PolicyMeta.Path)) {
            Show-Info -Message "La ruta de registro '$($PolicyMeta.Path)' no existe. Creándola..." -NoConsole
            New-RegistryPath -Path $PolicyMeta.Path
          }

          New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $PolicyMeta.ExpectedValue -Type $PolicyMeta.ValueKind -ErrorAction Stop -Force | Out-Null
          Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] No se ha podido ajustar la política: $_"
        }
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
      try {
        if ($null -eq $Backup[$PolicyInfo.Name]) {
          if (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop
          }
          else {
            Show-Info -Message "[$($PolicyInfo.Name)] La propiedad '$($PolicyMeta.Property)' ya estaba eliminada, por lo que no se ha realizado ninguna acción." -NoConsole
          }
        }
        else {
          New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $Backup[$PolicyInfo.Name] -Type $PolicyMeta.ValueKind -ErrorAction Stop -Force | Out-Null
        }
        Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."
      }
      catch {
        Exit-WithError "[$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo: $_"
      }
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Acción '$($Global:Info.Action)' no soportada."
    }
  }
}

# Handles the execution of security policies using secedit
function Invoke-SecurityPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup
  )

  $tempFolder = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\Temp"))
  $tempFilePath = Join-Path $tempFolder "secpol.cfg"

  # Export security policy and read current configuration
  try {
    & secedit /export /cfg $tempFilePath | Out-Null
    $lines = Get-Content -Path $tempFilePath -ErrorAction Stop
  }
  catch {
    Exit-WithError "[$($PolicyInfo.Name)] Error al exportar la configuración de seguridad del sistema: $_"
  }

  # Get the current value of the property
  $currentValue = $null
  $escapedPropForRead = [regex]::Escape($PolicyMeta.Property)
  $propLine = $lines | Where-Object { $_ -match "^(?i)$escapedPropForRead\s*=" } | Select-Object -First 1
  if ($propLine -and $propLine -match "=\s*(.*)$") {
    $rawVal = $Matches[1].Trim()
    if ($rawVal -match '^\d+$') { 
      $currentValue = [int]$rawVal 
    } 
    else { 
      $currentValue = $rawVal 
    }
  }

  $isValid = $false
  switch ($PolicyMeta.ComparisonMethod) {
    "AllowedValues" {
      if ($PolicyMeta.AllowedValues -contains $currentValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "GreaterOrEqual" {
      if ($null -ne $currentValue -and $currentValue -ge $PolicyMeta.ExpectedValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "LessOrEqual" {
      if ($null -ne $currentValue -and $currentValue -le $PolicyMeta.ExpectedValue) {
        if (-not $Global:Config.EnforceMinimumPolicyValues -or $currentValue -eq $PolicyMeta.ExpectedValue) {
          $isValid = $true
        }
      }
    }
    "PrivilegeSet" {
      function ConvertTo-SidToken {
        param(
          [string]$Identity,
          [string]$context
        )

        try {
          $sid = (New-Object System.Security.Principal.NTAccount($Identity)).Translate([System.Security.Principal.SecurityIdentifier]).Value
          return "*$sid"
        }
        catch {
          Exit-WithError -Message "[$($PolicyInfo.Name)] No se pudo convertir '$Identity', $context, a su SID: $($_.Exception.Message)"
        }
      }

      function ConvertTo-NormalizedPrivilegeSet {
        param(
          [object]$Source,
          [string]$contextForErrors
        )
        
        if ($null -eq $Source) { return , @() }

        $items =
        if ($Source -is [string]) { $Source.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries) }
        elseif ($Source -is [System.Array]) { $Source }
        else { @($Source) }

        $tokens = foreach ($raw in $items) {
          $t = $raw.ToString().Trim()
          if (-not $t) { continue }
          if ($t[0] -eq '*') { $t } else { ConvertTo-SidToken -Identity $t -context $contextForErrors }
        }

        return , (@(@($tokens) | Sort-Object -Unique))
      }

      $currentSet = ConvertTo-NormalizedPrivilegeSet -Source $currentValue -contextForErrors "presente en '$tempFilePath'"
      $expectedSet = ConvertTo-NormalizedPrivilegeSet -Source $PolicyMeta.ExpectedValue -contextForErrors "presente en el archivo de configuración de seguridad del sistema"
      
      $isValid = -not (Compare-Object -ReferenceObject $currentSet -DifferenceObject $expectedSet)

      if ($null -ne $currentValue) {
        $currentValue = $currentSet -join ","
      }
      $PolicyMeta.ExpectedValue = ($expectedSet -join ",")
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Método de comparación '$($PolicyMeta.ComparisonMethod)' no soportado."
    }
  }

  switch ($Global:Info.Action) {
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $currentValue -ValidValue:($isValid)
    }
    "Set" {
      if ($isValid) {
        Show-Info -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          $escapedProp = [regex]::Escape($PolicyMeta.Property)
          $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
          if ($lines -match $propPattern) {
            # The property exists: replace its value
            $newContent = $lines -replace $propPattern, ("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue)
          }
          else {
            # It does not exist: insert it after the header of the area ($PolicyMeta.Area), e.g. [Privilege Rights]
            $escapedArea = [regex]::Escape($PolicyMeta.Area)
            $areaPattern = "^(?i)\[$escapedArea\]\s*$"
            $areaMatch = $lines | Select-String -Pattern $areaPattern | Select-Object -First 1
            if ($areaMatch) {
              $insertAt = $areaMatch.LineNumber
              $tmp = New-Object System.Collections.Generic.List[string]
              for ($i = 0; $i -lt $lines.Count; $i++) {
                [void]$tmp.Add($lines[$i])
                if ($i -eq ($insertAt - 1)) {
                  [void]$tmp.Add(("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue))
                }
              }
              $newContent = $tmp
            }
            else {
              Exit-WithError "[$($PolicyInfo.Name)] No se ha encontrado el área '$($PolicyMeta.Area)' en el archivo de configuración de seguridad del sistema. No se puede aplicar la política."
            }
          }
          # Write the new content to the temp file and use it to import the new policy
          $newContent | Set-Content -Path $tempFilePath -Encoding Unicode -ErrorAction Stop
          & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath | Out-Null
          if ($LASTEXITCODE -ne 0) {
            Exit-WithError "[$($PolicyInfo.Name)] Error al aplicar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
          }
          Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] No se ha podido ajustar la política: $_"
        }
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
      try {
        if ($Backup.Contains($PolicyInfo.Name)) {
          $backupValue = $Backup[$PolicyInfo.Name]
          if ($backupValue -ne $currentValue) {
            $escapedProp = [regex]::Escape($PolicyMeta.Property)
            $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
            if ($lines -match $propPattern) {
              # The property exists: replace its value
              $newContent = $lines -replace $propPattern, ("{0} = {1}" -f $PolicyMeta.Property, $backupValue)
            }
            else {
              # It does not exist: insert it after the header of the area ($PolicyMeta.Area), e.g. [Privilege Rights]
              $escapedArea = [regex]::Escape($PolicyMeta.Area)
              $areaPattern = "^(?i)\[$escapedArea\]\s*$"
              $areaMatch = $lines | Select-String -Pattern $areaPattern | Select-Object -First 1
              if ($areaMatch) {
                $insertAt = $areaMatch.LineNumber
                $tmp = New-Object System.Collections.Generic.List[string]
                for ($i = 0; $i -lt $lines.Count; $i++) {
                  [void]$tmp.Add($lines[$i])
                  if ($i -eq ($insertAt - 1)) {
                    [void]$tmp.Add(("{0} = {1}" -f $PolicyMeta.Property, $backupValue))
                  }
                }
                $newContent = $tmp
              }
              else {
                Exit-WithError "[$($PolicyInfo.Name)] No se ha encontrado el área '$($PolicyMeta.Area)' en el archivo de configuración de seguridad del sistema. No se puede aplicar la política."
              }
            }
            # Write the new content to the temp file and use it to import the new policy
            $newContent | Set-Content -Path $tempFilePath -Encoding Unicode -ErrorAction Stop
            & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath | Out-Null
            if ($LASTEXITCODE -ne 0) {
              Exit-WithError "[$($PolicyInfo.Name)] Error al restaurar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
            }
          }
          Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."
        }
        else {
          Show-Warning -Message "[$($PolicyInfo.Name)] No hay copia de respaldo para restaurar."
        }
      }
      catch {
        Exit-WithError "[$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo: $_"
      }
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Acción '$($Global:Info.Action)' no soportada."
    }
  }

  Remove-Item -Path $tempFilePath -ErrorAction SilentlyContinue
}

# Handles the execution of service policies
function Invoke-ServicePolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup
  )

  # Detect service presence
  $svc = Get-Service -Name $PolicyMeta.ServiceName -ErrorAction SilentlyContinue
  if (-not $svc) {
    Show-Info -Message "[$($PolicyInfo.Name)] Se omite: el servicio '$($PolicyMeta.ServiceName)' no existe en este sistema." -NoConsole:($Global:Action -ne "Test")
    return
  }
  $currentValue = $svc.StartType

  $isValid = $currentValue -eq $PolicyMeta.ExpectedValue

  switch ($Global:Info.Action) {
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $currentValue -ValidValue:$isValid
    }
    "Set" {
      if ($isValid) {
        Show-Info -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Take a backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          Set-Service -Name $PolicyMeta.ServiceName -StartupType $PolicyMeta.ExpectedValue -ErrorAction Stop
          Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          # Fallback: try to set StartupType via registry 'Start' value
          try {
            $targetStart = switch ($PolicyMeta.ExpectedValue) {
              'Automatic' { 2 }
              'Manual' { 3 }
              'Disabled' { 4 }
              default { Exit-WithError "[$($PolicyInfo.Name)] Tipo de inicio esperado '$($PolicyMeta.ExpectedValue)' no soportado para ajuste por registro." }
            }

            $svcRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($PolicyMeta.ServiceName)"
            if (-not (Test-Path -Path $svcRegPath)) {
              Exit-WithError "[$($PolicyInfo.Name)] No existe la clave de servicio en el registro: $svcRegPath"
            }

            New-ItemProperty -Path $svcRegPath -Name 'Start' -Value $targetStart -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
          }
          catch {
            Exit-WithError "[$($PolicyInfo.Name)] No se ha podido ajustar la política a través del registro: $_"
          }
        }
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
      try {
        Set-Service -Name $PolicyMeta.ServiceName -StartupType $Backup[$PolicyInfo.Name] -ErrorAction Stop
        Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."
      }
      catch {
        # Fallback: try to set StartupType via registry 'Start' value
        try {
          $svcRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($PolicyMeta.ServiceName)"
          if (-not (Test-Path -Path $svcRegPath)) {
            Exit-WithError "[$($PolicyInfo.Name)] No existe la clave de servicio en el registro: $svcRegPath"
          }

          New-ItemProperty -Path $svcRegPath -Name 'Start' -Value $Backup[$PolicyInfo.Name] -PropertyType DWord -Force -ErrorAction Stop | Out-Null
          Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo a través del registro: $_"
        }
      }
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Acción '$($Global:Info.Action)' no soportada."
    }
  }
}