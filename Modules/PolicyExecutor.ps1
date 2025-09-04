###############################################################################
# PolicyExecutor.ps1
# Functions to execute common policy types
###############################################################################

# Handles the execution of custom policies
function Invoke-CustomPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Initialize', 'Test', 'Backup', 'Set', 'Restore', 'Assert')]
    [string]$Action
  )

  # Check if the required functions are defined
  $requiredFunctions = @(
    "Initialize-Policy",
    "Test-Policy",
    "Backup-Policy",
    "Set-Policy",
    "Restore-Policy",
    "Assert-Policy"
  )

  foreach ($function in $requiredFunctions) {
    if (-not (Get-Command -Name $function -ErrorAction SilentlyContinue)) {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] La función '$function' no está definida en la política."
      return
    }
  }

  if (-not $PolicyMeta.Initialized -and $Action -ne "Initialize") {
    Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no ha sido inicializada, por lo que no se ejecutará la acción." -NoConsole
    return
  }

  # Perform the action
  switch ($Action) {
    "Initialize" {
      # Initialize the policy
      try {
        Initialize-Policy
      }
      catch {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al inicializar la política: $_"
        return
      }

      $PolicyMeta.Initialized = $true
    }
    "Test" {
      try {
        Test-Policy
      }
      catch {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al comprobar la política: $_"
        return
      }
    }
    "Backup" {
      Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
      try {
        Backup-Policy
      }
      catch {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al crear la copia de respaldo: $_"
        return
      }
    }
    "Set" {
      if ($PolicyMeta.IsValid) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          Set-Policy
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al ajustar la política: $_"
          return
        }
        Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ajustada correctamente."
      }
    }
    "Restore" {
      if (Assert-Policy) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya tenía el valor original. No se realizará ninguna acción."
      }
      else {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
        try {
          Restore-Policy
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al restaurar la política: $_"
          return
        }
        Show-Success "[$GroupName] [$($PolicyInfo.Name)] Copia de respaldo restaurada correctamente."
      }
    }
    "Assert" {
      if (-not (Assert-Policy)) {
        $Global:AnyPolicyNotValidated = $true
        switch ($Global:Info.Action) {
          "Set" {
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política se encuentra desajustada. Reintentando..."
            Set-Policy
          }
          "Restore" {
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no tiene el valor original. Reintentando..."
            Restore-Policy
          }
        }
      }
    }
    Default {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Acción '$($Action)' no soportada."
      return
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
    [string]$GroupName,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Initialize', 'Test', 'Backup', 'Set', 'Restore', 'Assert')]
    [string]$Action
  )

  if (-not $PolicyMeta.Initialized -and $Action -ne "Initialize") {
    Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no ha sido inicializada, por lo que no se ejecutará la acción." -NoConsole
    return
  }

  switch ($Action) {
    "Initialize" {
      # Get current registry value
      try {
        $PolicyMeta.CurrentValue = (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop) | Select-Object -ExpandProperty $PolicyMeta.Property
        if ($null -eq $PolicyMeta.CurrentValue) {
          if ($PolicyMeta.ValueKind -eq "MultiString") {
            $PolicyMeta.CurrentValue = @()
          }
          elseif ($PolicyMeta.ValueKind -eq "String") {
            $PolicyMeta.CurrentValue = ""
          }
        }
      }
      catch {
        $PolicyMeta.CurrentValue = $null
      }

      # Validate current value against policy
      $PolicyMeta.IsValid = $false

      switch ($PolicyMeta.ComparisonMethod) {
        "AllowedValues" {
          if ($null -eq $PolicyMeta.AllowedValues) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se han definido valores permitidos para esta política."
            return
          }
          elseif ($PolicyMeta.AllowedValues -contains $PolicyMeta.CurrentValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
            }
          }
        }
        "GreaterOrEqual" {
          if ($null -ne $PolicyMeta.CurrentValue -and $PolicyMeta.CurrentValue -ge $PolicyMeta.ExpectedValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
            }
          }
        }
        "LessOrEqual" {
          if ($null -ne $PolicyMeta.CurrentValue -and $PolicyMeta.CurrentValue -le $PolicyMeta.ExpectedValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
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
          $currentSet = ConvertTo-NormalizedSet -Source $PolicyMeta.CurrentValue
          $expectedSet = ConvertTo-NormalizedSet -Source $PolicyMeta.ExpectedValue

          $PolicyMeta.IsValid = ($null -eq $PolicyMeta.CurrentValue -and $null -eq $PolicyMeta.ExpectedValue)
          # Compare as sets
          if ($null -ne $PolicyMeta.CurrentValue -and $null -ne $PolicyMeta.ExpectedValue) {
            $PolicyMeta.IsValid = -not (Compare-Object -ReferenceObject $currentSet -DifferenceObject $expectedSet)
          }
        }
        Default {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Método de comparación '$($PolicyMeta.ComparisonMethod)' no soportado."
          return
        }
      }

      $PolicyMeta.Initialized = $true
    }
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $PolicyMeta.CurrentValue -ValidValue:$PolicyMeta.IsValid
    }
    "Backup" {
      # Take a backup
      Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
      $Backup[$PolicyInfo.Name] = $PolicyMeta.CurrentValue
      Save-Backup
    }
    "Set" {
      if ($PolicyMeta.IsValid) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Apply the policy
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          # Verify if the registry path exists
          if (-not (Test-Path -Path $PolicyMeta.Path)) {
            Show-Info -Message "La ruta de registro '$($PolicyMeta.Path)' no existe. Creándola..." -NoConsole
            New-RegistryPath -Path $PolicyMeta.Path
          }

          if ($null -eq $PolicyMeta.ExpectedValue) {
            if (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction SilentlyContinue) {
              Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Se eliminará la propiedad del registro." -NoConsole
              Remove-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop
            }
            else {
              Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La propiedad '$($PolicyMeta.Property)' ya estaba eliminada, por lo que no se ha realizado ninguna acción." -NoConsole
            }
          }
          else {
            New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $PolicyMeta.ExpectedValue -Type $PolicyMeta.ValueKind -ErrorAction Stop -Force | Out-Null
          }
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido ajustar la política: $_"
          return
        }
      }
    }
    "Restore" {
      if ($PolicyMeta.CurrentValue -eq $Backup[$PolicyInfo.Name]) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya tenía el valor original. No se realizará ninguna acción."
      }
      else {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
        try {
          if ($null -eq $Backup[$PolicyInfo.Name]) {
            if (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction SilentlyContinue) {
              Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Se eliminará la propiedad del registro." -NoConsole
              Remove-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop
            }
            else {
              Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La propiedad '$($PolicyMeta.Property)' ya estaba eliminada, por lo que no se ha realizado ninguna acción." -NoConsole
            }
          }
          else {
            New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $Backup[$PolicyInfo.Name] -Type $PolicyMeta.ValueKind -ErrorAction Stop -Force | Out-Null
          }
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Copia de respaldo restaurada."
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo: $_"
          return
        }
      }
    }
    "Assert" {
      Invoke-RegistryPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Initialize"
      switch ($Global:Info.Action) {
        "Set" {
          if (-not $PolicyMeta.IsValid) {
            $Global:AnyPolicyNotValidated = $true
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política se encuentra desajustada. Reintentando..."
            Invoke-RegistryPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Set"
          }
        }
        "Restore" {
          $isValid =
          if ($PolicyMeta.ComparisonMethod -eq "ExactSet") {
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
            $currentSet = ConvertTo-NormalizedSet -Source $PolicyMeta.CurrentValue
            $expectedSet = ConvertTo-NormalizedSet -Source $Backup[$PolicyInfo.Name]
            -not (Compare-Object -ReferenceObject $currentSet -DifferenceObject $expectedSet)
          }
          else {
            $PolicyMeta.CurrentValue -eq $GroupMeta.Backup[$PolicyInfo.Name]
          }
          if (-not $isValid) {
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no tiene el valor original. Reintentando..."
            Invoke-RegistryPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Restore"
          }
        }
      }
    }
    Default {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Acción '$($Action)' no soportada."
      return
    }
  }
}

# Handles the execution of security policies using secedit
function Invoke-SecurityPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Initialize', 'Test', 'Backup', 'Set', 'Restore', 'Assert')]
    [string]$Action
  )

  function Read-Secpol {
    # Export security policy and read current configuration
    if ($Action -ne "Initialize" -or -not $Global:SecpolLines) {
      try {
        & secedit /export /cfg $PolicyMeta.TempFilePath | Out-Null
        $Global:SecpolLines = Get-Content -Path $PolicyMeta.TempFilePath -ErrorAction Stop
      }
      catch {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al exportar la configuración de seguridad del sistema: $_"
        return
      }
    }
  }

  if (-not $PolicyMeta.Initialized -and $Action -ne "Initialize") {
    Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no ha sido inicializada, por lo que no se ejecutará la acción." -NoConsole
    return
  }

  switch ($Action) {
    "Initialize" {
      # Initialize properties if they don't exist
      if ($null -eq $PolicyMeta.TempFilePath) {
        $PolicyMeta | Add-Member -NotePropertyName TempFilePath -NotePropertyValue $null -Force
      }

      $tempFolder = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\Temp"))
      $PolicyMeta.TempFilePath = Join-Path $tempFolder "secpol.cfg"
      Read-Secpol

      # Get the current value of the property
      $PolicyMeta.CurrentValue = $null
      $escapedPropForRead = [regex]::Escape($PolicyMeta.Property)
      $propLine = $Global:SecpolLines | Where-Object { $_ -match "^(?i)$escapedPropForRead\s*=" } | Select-Object -First 1
      if ($propLine -and $propLine -match "=\s*(.*)$") {
        $rawVal = $Matches[1].Trim()
        if ($rawVal -match '^\d+$') { 
          $PolicyMeta.CurrentValue = [int]$rawVal 
        } 
        else { 
          $PolicyMeta.CurrentValue = $rawVal 
        }
      }

      $PolicyMeta.IsValid = $false
      switch ($PolicyMeta.ComparisonMethod) {
        "AllowedValues" {
          if ($PolicyMeta.AllowedValues -contains $PolicyMeta.CurrentValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
            }
          }
        }
        "GreaterOrEqual" {
          if ($null -ne $PolicyMeta.CurrentValue -and $PolicyMeta.CurrentValue -ge $PolicyMeta.ExpectedValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
            }
          }
        }
        "LessOrEqual" {
          if ($null -ne $PolicyMeta.CurrentValue -and $PolicyMeta.CurrentValue -le $PolicyMeta.ExpectedValue) {
            if (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue) {
              $PolicyMeta.IsValid = $true
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
              Exit-WithError -Message "[$GroupName] [$($PolicyInfo.Name)] No se pudo convertir '$Identity', $context, a su SID: $($_.Exception.Message)"
              return
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

          $currentSet = ConvertTo-NormalizedPrivilegeSet -Source $PolicyMeta.CurrentValue -contextForErrors "presente en '$PolicyMeta.TempFilePath'"
          $expectedSet = ConvertTo-NormalizedPrivilegeSet -Source $PolicyMeta.ExpectedValue -contextForErrors "presente en el archivo de configuración de seguridad del sistema"
      
          $PolicyMeta.IsValid = -not (Compare-Object -ReferenceObject $currentSet -DifferenceObject $expectedSet)

          if ($null -ne $PolicyMeta.CurrentValue) {
            $PolicyMeta.CurrentValue = $currentSet -join ","
          }
          $PolicyMeta.ExpectedValue = ($expectedSet -join ",")
        }
        Default {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Método de comparación '$($PolicyMeta.ComparisonMethod)' no soportado."
          return
        }
      }

      $PolicyMeta.Initialized = $true
    }
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $PolicyMeta.CurrentValue -ValidValue:($PolicyMeta.IsValid)
    }
    "Backup" {
      # Backup
      Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
      $Backup[$PolicyInfo.Name] = $PolicyMeta.CurrentValue
      Save-Backup
    }
    "Set" {
      if ($PolicyMeta.IsValid) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        Read-Secpol
        # Apply the policy
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          $escapedProp = [regex]::Escape($PolicyMeta.Property)
          $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
          if ($Global:SecpolLines -match $propPattern) {
            # The property exists: replace its value
            $Global:SecpolLines = $Global:SecpolLines -replace $propPattern, ("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue)
          }
          else {
            # It does not exist: insert it after the header of the area ($PolicyMeta.Area), e.g. [Privilege Rights]
            $escapedArea = [regex]::Escape($PolicyMeta.Area)
            $areaPattern = "^(?i)\[$escapedArea\]\s*$"
            $areaMatch = $Global:SecpolLines | Select-String -Pattern $areaPattern | Select-Object -First 1
            if ($areaMatch) {
              $insertAt = $areaMatch.LineNumber
              $tmp = New-Object System.Collections.Generic.List[string]
              for ($i = 0; $i -lt $Global:SecpolLines.Count; $i++) {
                [void]$tmp.Add($Global:SecpolLines[$i])
                if ($i -eq ($insertAt - 1)) {
                  [void]$tmp.Add(("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue))
                }
              }
              $Global:SecpolLines = $tmp
            }
            else {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha encontrado el área '$($PolicyMeta.Area)' en el archivo de configuración de seguridad del sistema. No se puede aplicar la política."
              return
            }
          }
          # Write the new content to the temp file and use it to import the new policy
          $Global:SecpolLines | Set-Content -Path $PolicyMeta.TempFilePath -Encoding Unicode -ErrorAction Stop
          & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $PolicyMeta.TempFilePath | Out-Null
          if ($LASTEXITCODE -ne 0) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al aplicar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
            return
          }
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido ajustar la política: $_"
          return
        }
      }
    }
    "Restore" {
      if ($PolicyMeta.CurrentValue -eq $Backup[$PolicyInfo.Name]) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya tenía el valor original. No se realizará ninguna acción."
      }
      else {
        Read-Secpol
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
        try {
          $escapedProp = [regex]::Escape($PolicyMeta.Property)
          $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
          if ($Global:SecpolLines -match $propPattern) {
            # The property exists: replace its value
            $Global:SecpolLines = $Global:SecpolLines -replace $propPattern, ("{0} = {1}" -f $PolicyMeta.Property, $Backup[$PolicyInfo.Name])
          }
          else {
            # It does not exist: insert it after the header of the area ($PolicyMeta.Area), e.g. [Privilege Rights]
            $escapedArea = [regex]::Escape($PolicyMeta.Area)
            $areaPattern = "^(?i)\[$escapedArea\]\s*$"
            $areaMatch = $Global:SecpolLines | Select-String -Pattern $areaPattern | Select-Object -First 1
            if ($areaMatch) {
              $insertAt = $areaMatch.LineNumber
              $tmp = New-Object System.Collections.Generic.List[string]
              for ($i = 0; $i -lt $Global:SecpolLines.Count; $i++) {
                [void]$tmp.Add($Global:SecpolLines[$i])
                if ($i -eq ($insertAt - 1)) {
                  [void]$tmp.Add(("{0} = {1}" -f $PolicyMeta.Property, $Backup[$PolicyInfo.Name]))
                }
              }
              $Global:SecpolLines = $tmp
            }
            else {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha encontrado el área '$($PolicyMeta.Area)' en el archivo de configuración de seguridad del sistema. No se puede aplicar la política."
              return
            }
          }
          # Write the new content to the temp file and use it to import the new policy
          $Global:SecpolLines | Set-Content -Path $PolicyMeta.TempFilePath -Encoding Unicode -ErrorAction Stop
          & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $PolicyMeta.TempFilePath | Out-Null
          if ($LASTEXITCODE -ne 0) {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al restaurar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
            return
          }
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Copia de respaldo restaurada."
        }
        catch {
          Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo: $_"
          return
        }
      }
    }
    "Assert" {
      Invoke-SecurityPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Initialize"
      switch ($Global:Info.Action) {
        "Set" {
          if (-not $PolicyMeta.IsValid) {
            $Global:AnyPolicyNotValidated = $true
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política se encuentra desajustada. Reintentando..."
            Invoke-SecurityPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Set"
          }
        }
        "Restore" {
          if (-not ($PolicyMeta.CurrentValue -eq $GroupMeta.Backup[$PolicyInfo.Name])) {
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no tiene el valor original. Reintentando..."
            Invoke-SecurityPolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Restore"
          }
        }
      }
    }
    Default {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Acción '$($Action)' no soportada."
      return
    }
  }
}

# Handles the execution of service policies
function Invoke-ServicePolicy {
  param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary]$Backup,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Initialize', 'Test', 'Backup', 'Set', 'Restore', 'Assert')]
    [string]$Action
  )

  if (-not $PolicyMeta.Initialized -and $Action -ne "Initialize") {
    Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no ha sido inicializada, por lo que no se ejecutará la acción." -NoConsole
    return
  }

  switch ($Action) {
    "Initialize" {
      # Detect service presence
      $svc = Get-Service -Name $PolicyMeta.ServiceName -ErrorAction SilentlyContinue
      if (-not $svc) {
        $PolicyMeta.IsValid = $true
        return
      }
      $PolicyMeta.CurrentValue = $svc.StartType
      $PolicyMeta.IsValid = $PolicyMeta.CurrentValue -eq $PolicyMeta.ExpectedValue

      $PolicyMeta.Initialized = $true
    }
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $PolicyMeta.ExpectedValue -CurrentValue $PolicyMeta.CurrentValue -ValidValue:$PolicyMeta.IsValid
    }
    "Backup" {
      # Take a backup
      Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
      $Backup[$PolicyInfo.Name] = $PolicyMeta.CurrentValue
      Save-Backup
    }
    "Set" {
      if ($PolicyMeta.IsValid) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Apply the policy
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          Set-Service -Name $PolicyMeta.ServiceName -StartupType $PolicyMeta.ExpectedValue -ErrorAction Stop
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          # Fallback: try to set StartupType via registry 'Start' value
          try {
            $targetStart = switch ($PolicyMeta.ExpectedValue) {
              'Automatic' { 2 }
              'Manual' { 3 }
              'Disabled' { 4 }
              default {
                Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Tipo de inicio esperado '$($PolicyMeta.ExpectedValue)' no soportado para ajuste por registro."
                return
              }
            }

            $svcRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($PolicyMeta.ServiceName)"
            if (-not (Test-Path -Path $svcRegPath)) {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No existe la clave de servicio en el registro: $svcRegPath"
              return
            }

            New-ItemProperty -Path $svcRegPath -Name 'Start' -Value $targetStart -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            Show-Success "[$GroupName] [$($PolicyInfo.Name)] Política ajustada correctamente."
          }
          catch {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido ajustar la política a través del registro: $_"
            return
          }
        }
      }
    }
    "Restore" {
      if ($PolicyMeta.CurrentValue -eq $Backup[$PolicyInfo.Name]) {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] La política ya tenía el valor original. No se realizará ninguna acción."
      }
      else {
        Show-Info -Message "[$GroupName] [$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
        try {
          Set-Service -Name $PolicyMeta.ServiceName -StartupType $Backup[$PolicyInfo.Name] -ErrorAction Stop
          Show-Success "[$GroupName] [$($PolicyInfo.Name)] Copia de respaldo restaurada."
        }
        catch {
          # Fallback: try to set StartupType via registry 'Start' value
          try {
            $svcRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($PolicyMeta.ServiceName)"
            if (-not (Test-Path -Path $svcRegPath)) {
              Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No existe la clave de servicio en el registro: $svcRegPath"
              return
            }

            New-ItemProperty -Path $svcRegPath -Name 'Start' -Value $Backup[$PolicyInfo.Name] -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            Show-Success "[$GroupName] [$($PolicyInfo.Name)] Copia de respaldo restaurada."
          }
          catch {
            Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha podido restaurar la copia de respaldo a través del registro: $_"
            return
          }
        }
      }
    }
    "Assert" {
      Invoke-ServicePolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Initialize"
      switch ($Global:Info.Action) {
        "Set" {
          if (-not $PolicyMeta.IsValid) {
            $Global:AnyPolicyNotValidated = $true
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política se encuentra desajustada. Reintentando..."
            Invoke-ServicePolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Set"
          }
        }
        "Restore" {
          if (-not ($PolicyMeta.CurrentValue -eq $GroupMeta.Backup[$PolicyInfo.Name])) {
            Show-Warning -Message "[$GroupName] [$($PolicyInfo.Name)] La política no tiene el valor original. Reintentando..."
            Invoke-ServicePolicy -GroupName $GroupName -PolicyInfo $PolicyInfo -PolicyMeta $PolicyMeta -Backup $Backup -Action "Restore"
          }
        }
      }
    }
    Default {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Acción '$($Action)' no soportada."
      return
    }
  }
}