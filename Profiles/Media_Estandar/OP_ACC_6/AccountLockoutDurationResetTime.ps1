###############################################################################
# AccountLockoutDurationResetTime.ps1
# Duración del bloqueo de cuenta y restablecimiento del contador
###############################################################################

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name                     = 'AccountLockoutDurationResetTime'
  Description              = 'Duración de bloqueo de cuenta y restablecimiento del contador'
  Type                     = 'Custom'
  Area                     = 'System Access'
  DurationComparisonMethod = 'AllowedValues'
  # Debe utilizarse un valor de -1 o uno mayor o igual al de la siguiente
  DurationAllowedValues    = @(-1)
  DurationExpectedValue    = -1
  ResetComparisonMethod    = 'GreaterOrEqual'
  ResetExpectedValue       = 15
  CurrentDuration          = $null
  CurrentReset             = $null
  IsValid                  = $false
  TempFilePath             = $null
  Lines                    = $null
}

function Initialize-Policy {
  $tempFolder = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\Temp"))
  $PolicyMeta.TempFilePath = Join-Path $tempFolder "secpol.cfg"

  try {
    & secedit /export /cfg $PolicyMeta.TempFilePath | Out-Null
    $PolicyMeta.Lines = Get-Content -Path $PolicyMeta.TempFilePath -ErrorAction Stop
  }
  catch {
    Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al exportar la configuración de seguridad del sistema: $_"
    return
  }
  finally {
    Remove-Item -Path $PolicyMeta.TempFilePath -ErrorAction SilentlyContinue
  }

  $PolicyMeta.CurrentDuration = $null
  $PolicyMeta.CurrentReset = $null

  foreach ($pair in @(
      @{ Key = 'LockoutDuration'; Target = 'CurrentDuration' },
      @{ Key = 'ResetLockoutCount'; Target = 'CurrentReset' }
    )) {
    $escaped = [regex]::Escape($pair.Key)
    $line = $PolicyMeta.Lines | Where-Object { $_ -match "^(?i)$escaped\s*=" } | Select-Object -First 1
    if ($line -and $line -match "=\s*(.*)$") {
      $raw = $Matches[1].Trim()
      if ($raw -match '^(-?\d+)$') { $PolicyMeta.($pair.Target) = [int]$raw } else { $PolicyMeta.($pair.Target) = $raw }
    }
  }

  $isDurationValid = $false
  switch ($PolicyMeta.DurationComparisonMethod) {
    'AllowedValues' {
      if ($PolicyMeta.DurationAllowedValues -contains $PolicyMeta.CurrentDuration) {
        $isDurationValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentDuration -eq $PolicyMeta.DurationExpectedValue)
      }
    }
    'GreaterOrEqual' {
      if ($null -ne $PolicyMeta.CurrentDuration -and $PolicyMeta.CurrentDuration -ge $PolicyMeta.DurationExpectedValue) {
        $isDurationValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentDuration -eq $PolicyMeta.DurationExpectedValue)
      }
    }
    'LessOrEqual' {
      if ($null -ne $PolicyMeta.CurrentDuration -and $PolicyMeta.CurrentDuration -le $PolicyMeta.DurationExpectedValue) {
        $isDurationValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentDuration -eq $PolicyMeta.DurationExpectedValue)
      }
    }
    Default { $isDurationValid = $false }
  }

  $isResetValid = $false
  switch ($PolicyMeta.ResetComparisonMethod) {
    'AllowedValues' {
      if ($PolicyMeta.AllowedValues -contains $PolicyMeta.CurrentReset) {
        $isResetValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentReset -eq $PolicyMeta.ResetExpectedValue)
      }
    }
    'GreaterOrEqual' {
      if ($null -ne $PolicyMeta.CurrentReset -and $PolicyMeta.CurrentReset -ge $PolicyMeta.ResetExpectedValue) {
        $isResetValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentReset -eq $PolicyMeta.ResetExpectedValue)
      }
    }
    'LessOrEqual' {
      if ($null -ne $PolicyMeta.CurrentReset -and $PolicyMeta.CurrentReset -le $PolicyMeta.ResetExpectedValue) {
        $isResetValid = (-not $Global:Config.EnforceMinimumPolicyValues -or $PolicyMeta.CurrentReset -eq $PolicyMeta.ResetExpectedValue)
      }
    }
    Default { $isResetValid = $false }
  }

  $PolicyMeta.IsValid = ($isDurationValid -and $isResetValid)
}

function Test-Policy {
  $expected = "Duración=$($PolicyMeta.DurationExpectedValue); Reset=$($PolicyMeta.ResetExpectedValue)"
  $current = "Duración=$($PolicyMeta.CurrentDuration); Reset=$($PolicyMeta.CurrentReset)"
  Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $expected -CurrentValue $current -ValidValue:($PolicyMeta.IsValid)
}

function Backup-Policy {
  $Backup[$PolicyInfo.Name] = @{ LockoutDuration = $PolicyMeta.CurrentDuration; ResetLockoutCount = $PolicyMeta.CurrentReset }
  Save-Backup
}

function Set-Policy {
  Initialize-Policy
  # Helper to apply a single property change to $PolicyMeta.Lines and import via secedit
  $apply = {
    param([string]$prop, [object]$value)
    $escapedProp = [regex]::Escape($prop)
    $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
    if ($PolicyMeta.Lines -match $propPattern) {
      # Replace existing value
      $PolicyMeta.Lines = $PolicyMeta.Lines -replace $propPattern, ("{0} = {1}" -f $prop, $value)
    }
    else {
      # Insert after the area header
      $escapedArea = [regex]::Escape($PolicyMeta.Area)
      $areaPattern = "^(?i)\[$escapedArea\]\s*$"
      $areaMatch = $PolicyMeta.Lines | Select-String -Pattern $areaPattern | Select-Object -First 1
      if ($areaMatch) {
        $insertAt = $areaMatch.LineNumber
        $tmp = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $PolicyMeta.Lines.Count; $i++) {
          [void]$tmp.Add($PolicyMeta.Lines[$i])
          if ($i -eq ($insertAt - 1)) {
            [void]$tmp.Add(("{0} = {1}" -f $prop, $value))
          }
        }
        $PolicyMeta.Lines = $tmp
      }
      else {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha encontrado el área '$PolicyMeta.Area' en el archivo de configuración de seguridad del sistema. No se puede aplicar la política."
        return
      }
    }

    # Write content and import
    $PolicyMeta.Lines | Set-Content -Path $PolicyMeta.TempFilePath -Encoding Unicode -ErrorAction Stop
    & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $PolicyMeta.TempFilePath | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al aplicar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
      return
    }
  }

  if ($PolicyMeta.ResetExpectedValue -gt $PolicyMeta.DurationExpectedValue -and $PolicyMeta.DurationExpectedValue -ne -1) {
    Show-Warning "[$GroupName] [$($PolicyInfo.Name)] No se puede aplicar la política porque el valor esperado de 'Restablecer el contador de bloqueo de cuenta' ($($PolicyMeta.ResetExpectedValue)) es mayor que el valor esperado de 'Duración del bloqueo de cuenta' ($($PolicyMeta.DurationExpectedValue))."
  }
  else {
    if ($PolicyMeta.DurationExpectedValue -eq -1 -or $PolicyMeta.DurationExpectedValue -ge $PolicyMeta.CurrentReset) {
      # Apply LockoutDuration first
      & $apply 'LockoutDuration' $PolicyMeta.DurationExpectedValue

      # Apply ResetLockoutCount next
      & $apply 'ResetLockoutCount' $PolicyMeta.ResetExpectedValue
    }
    else {
      # Apply ResetLockoutCount first
      & $apply 'ResetLockoutCount' $PolicyMeta.ResetExpectedValue

      # Apply LockoutDuration next
      & $apply 'LockoutDuration' $PolicyMeta.DurationExpectedValue
    }
  }

  Remove-Item -Path $PolicyMeta.TempFilePath -ErrorAction SilentlyContinue
}

function Restore-Policy {
  Initialize-Policy
  $bk = $Backup[$PolicyInfo.Name]

  # Helper to apply a single property change to $PolicyMeta.Lines and import via secedit
  $apply = {
    param([string]$prop, [object]$value)
    if ($null -eq $value) { return }
    $escapedProp = [regex]::Escape($prop)
    $propPattern = "^(?i)$escapedProp\s*=\s*.*$"
    if ($PolicyMeta.Lines -match $propPattern) {
      # Replace existing value
      $PolicyMeta.Lines = $PolicyMeta.Lines -replace $propPattern, ("{0} = {1}" -f $prop, $value)
    }
    else {
      # Insert after the area header
      $escapedArea = [regex]::Escape($PolicyMeta.Area)
      $areaPattern = "^(?i)\[$escapedArea\]\s*$"
      $areaMatch = $PolicyMeta.Lines | Select-String -Pattern $areaPattern | Select-Object -First 1
      if ($areaMatch) {
        $insertAt = $areaMatch.LineNumber
        $tmp = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $PolicyMeta.Lines.Count; $i++) {
          [void]$tmp.Add($PolicyMeta.Lines[$i])
          if ($i -eq ($insertAt - 1)) {
            [void]$tmp.Add(("{0} = {1}" -f $prop, $value))
          }
        }
        $PolicyMeta.Lines = $tmp
      }
      else {
        Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] No se ha encontrado el área '$($PolicyMeta.Area)' en el archivo de configuración de seguridad del sistema. No se puede restaurar la política."
        return
      }
    }

    # Write content and import
    $PolicyMeta.Lines | Set-Content -Path $PolicyMeta.TempFilePath -Encoding Unicode -ErrorAction Stop
    & secedit /configure /db "$env:SystemRoot\security\local.sdb" /cfg $PolicyMeta.TempFilePath | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Exit-WithError "[$GroupName] [$($PolicyInfo.Name)] Error al restaurar la política. Consultar el registro '%windir%\security\logs\scesrv.log' para obtener información detallada."
      return
    }
  }

  if ($bk['ResetLockoutCount'] -gt $bk['LockoutDuration'] -and $bk['LockoutDuration'] -ne -1) {
    Show-Warning "[$GroupName] [$($PolicyInfo.Name)] No se puede restaurar la política porque el valor original de 'Restablecer el contador de bloqueo de cuenta' ($($bk['ResetLockoutCount'])) es mayor que el valor original de 'Duración del bloqueo de cuenta' ($($bk['LockoutDuration']))."
  }
  else {
    if ($bk['LockoutDuration'] -eq -1 -or $bk['LockoutDuration'] -ge $PolicyMeta.CurrentReset) {
      # Restore LockoutDuration first, then ResetLockoutCount
      & $apply 'LockoutDuration' $bk['LockoutDuration']
      & $apply 'ResetLockoutCount' $bk['ResetLockoutCount']
    }
    else {
      # Restore ResetLockoutCount first, then LockoutDuration
      & $apply 'ResetLockoutCount' $bk['ResetLockoutCount']
      & $apply 'LockoutDuration' $bk['LockoutDuration']
    }
  }
  
  Remove-Item -Path $PolicyMeta.TempFilePath -ErrorAction SilentlyContinue
}

function Assert-Policy {
  Initialize-Policy
  switch ($Global:Info.Action) {
    "Set" {
      return $PolicyMeta.IsValid
    }
    "Restore" {
      return ($Backup[$PolicyInfo.Name]['LockoutDuration'] -eq $PolicyMeta.CurrentDuration) -and ($Backup[$PolicyInfo.Name]['ResetLockoutCount'] -eq $PolicyMeta.CurrentReset)
    }
  }
}