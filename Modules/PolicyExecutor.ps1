###############################################################################
# PolicyExecutor.ps1
# Functions to execute common policy types
###############################################################################

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
      if ($PolicyMeta.AllowedValues -contains $currentValue) {
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
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -LogOnly
        $Backup[$PolicyInfo.Name] = $currentValue
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -LogOnly
        try {
          New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $PolicyMeta.ExpectedValue -Type $PolicyMeta.ValueKind -ErrorAction Stop
          Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
        }
        catch {
          Exit-WithError "[$($PolicyInfo.Name)] No se ha podido ajustar la política: $_"
        }
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -LogOnly
      try {
        New-ItemProperty -Path $PolicyMeta.Path -Name $PolicyMeta.Property -Value $Backup[$PolicyInfo.Name] -Type $PolicyMeta.ValueKind -ErrorAction Stop
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