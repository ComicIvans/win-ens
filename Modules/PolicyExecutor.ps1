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
          # Verify if the registry key exists
          if (-not (Test-Path -Path $PolicyMeta.Path)) {
            Show-Info -Message "La clave de registro '$($PolicyMeta.Path)' no existe. Creándola..." -NoConsole
            New-Item -Path $PolicyMeta.Path | Out-Null
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
    & secedit /export /cfg $tempFilePath | Out-Null
    $lines = Get-Content -Path $tempFilePath -ErrorAction Stop
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
  else {
    Exit-WithError "[$($PolicyInfo.Name)] No se ha encontrado la propiedad '$($PolicyMeta.Property)' en el archivo exportado de configuración de seguridad del sistema."
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
    "ExactSet" {
      $currentValue = $currentValue.Split(',')
      $isValid = -not (Compare-Object -ReferenceObject $currentValue -DifferenceObject $PolicyMeta.ExpectedValue)
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Método de comparación '$($PolicyMeta.ComparisonMethod)' no soportado."
    }
  }

  switch ($Global:Info.Action) {
    "Test" {
      if ($PolicyMeta.ComparisonMethod -eq "ExactSet") {
        $currentValue = $currentValue -join ", "
        $PolicyMeta.ExpectedValue = $PolicyMeta.ExpectedValue -join ", "
      }
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
          $pattern = "^(?i)$($PolicyMeta.Property)\s*=\s*\S+"
          $newContent = $lines -replace $pattern, ("{0} = {1}" -f $PolicyMeta.Property, $PolicyMeta.ExpectedValue)
          # Write the new content to the temp file and use it to import the new policy
          $newContent | Set-Content -Path $tempFilePath -ErrorAction Stop
          & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath | Out-Null
          if ($LASTEXITCODE -ne 0) {
            Exit-WithError "[$($PolicyInfo.Name)] Error al aplicar la política. Consultar el registro %windir%\security\logs\scesrv.log para obtener información detallada."
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
        if ($Backup.ContainsKey($PolicyInfo.Name)) {
          $backupValue = $Backup[$PolicyInfo.Name]
          if ($backupValue -ne $currentValue) {
            $pattern = "^(?i)$($PolicyMeta.Property)\s*=\s*\S+"
            $newContent = $lines -replace $pattern, ("{0} = {1}" -f $PolicyMeta.Property, $backupValue)
            # Write the new content to the temp file and use it to import the new policy
            $newContent | Set-Content -Path $tempFilePath -ErrorAction Stop
            & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $tempFilePath | Out-Null
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