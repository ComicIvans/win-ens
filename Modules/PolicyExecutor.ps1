###############################################################################
# PolicyExecutor.ps1
# Functions to execute common policy types
###############################################################################

# Handles the execution of registry-based policies
function Invoke-RegistryPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Backup
  )

  try {
    $currentValue = (Get-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop) | Select-Object -ExpandProperty $PolicyMeta.Property
  }
  catch {
    $currentValue = $null
  }

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
        Show-Success -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Take a backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
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
          Remove-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -ErrorAction Stop
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

# Handles de the execution of secutiy policies using secedit
function Invoke-SecurityPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyInfo,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$PolicyMeta,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Backup
  )

  $tempFolder = Join-Path $PSScriptRoot "..\Temp"
  $tempFilePath = Join-Path $tempFolder "secpol.cfg"

  # Export security policy
  try {
    & secedit /export /cfg $tempFilePath /areas SECURITYPOLICY | Out-Null
    $tempFile = [System.IO.File]::Open($tempFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    $lines = Get-Content -Path $tempFilePath -Encoding ASCII
    $tempFileWriter = [System.IO.StreamWriter]::new($tempFile, [System.Text.Encoding]::ASCII)
    $tempFileWriter.AutoFlush = $true
  }
  catch {
    Exit-WithError "[$($PolicyInfo.Name)] Error al exportar la configuración de seguridad del sistema: $_"
  }

  # Get the current value of the property
  $currentValue = $null
  $propLine = $lines | Where-Object { $_ -match "^(?i)$($PolicyMeta.Property)\s*=" } | Select-Object -First 1
  if ($propLine -and $propLine -match "=\s*(\S+)") {
    $rawVal = $Matches[1]
    if ($rawVal -match '^\d+$') { $currentValue = [int]$rawVal } else { $currentValue = $rawVal }
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
      if ($null -ne $currentValue -and $currentValue -ge $PolicyMeta.ExpectedValue) { $isValid = $true }
    }
    "LessOrEqual" {
      if ($null -ne $currentValue -and $currentValue -le $PolicyMeta.ExpectedValue) { $isValid = $true }
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
        Show-Success -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        try {
          $pattern = "^(?i)$($PolicyMeta.Property)\s*=\s*\S+"
          if ($propLine) {
            $newContent = $lines -replace $pattern, ("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue)
          }
          else {
            # Add line if not exists
            $newContent = $lines + ("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue)
          }
          # Write the new content to the temp file and use it to import the new policy
          $tempFile.SetLength(0)
          $tempFileWriter.Write($newContent)
          & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath /areas SECURITYPOLICY | Out-Null
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
        if ($Backup.ContainsKey($PolicyInfo.Name)) {
          $backupValue = $Backup[$PolicyInfo.Name]
          if ($backupValue -ne $currentValue) {
            $lines = Get-Content -Path $tempFilePath
            $propLine = $lines | Where-Object { $_ -match "^(?i)$($PolicyMeta.Property)\s*=" } | Select-Object -First 1
            $pattern = "^(?i)$($PolicyMeta.Property)\s*=\s*\S+"
            if ($propLine) {
              $newContent = $lines -replace $pattern, ("{0} = {1}" -f $PolicyMeta.Property, $backupValue)
            }
            else {
              $newContent = $lines + ("{0} = {1}" -f $PolicyMeta.Property, $backupValue)
            }
            # Write the new content to the temp file and use it to import the new policy
            $tempFile.SetLength(0)
            $tempFileWriter.Write($newContent)
            & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath /areas SECURITYPOLICY | Out-Null
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

  $tempFileWriter.Dispose()
  $tempFile.Close()
  Remove-Item -Path $tempFilePath -ErrorAction SilentlyContinue
}