###############################################################################
# 17_Pwd_ExpireEnabled.ps1
# Cuentas cuyas contraseñas nunca expiran
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name        = '17_Pwd_ExpireEnabled'
  Description = 'Cuentas cuyas contraseñas nunca expiran'
  Type        = 'Custom'
}

# Custom policy execution function
function Invoke-CustomPolicy {
  param(
    [Parameter(Mandatory = $false)][pscustomobject]$PolicyInfo,
    [Parameter(Mandatory = $false)][pscustomobject]$Backup
  )

  $guestName = (Get-LocalUser | Where-Object { $_.SID.Value -like 'S-1-5-21-*-501' }).Name
  $users = Get-LocalUser | Where-Object { $_.Enabled -and $_.Name -ne $guestName }
  $usersWithNeverExpire = $users | Where-Object { -not $_.PasswordExpires } | Select-Object -ExpandProperty Name

  switch ($Global:Info.Action) {
    "Test" {
      Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $null -CurrentValue $usersWithNeverExpire
    }
    "Set" {
      if ($null -eq $usersWithNeverExpire) {
        Show-Success -Message "[$($PolicyInfo.Name)] La política ya cumplía con el perfil."
      }
      else {
        # Take a backup
        Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -NoConsole
        $Backup[$PolicyInfo.Name] = $usersWithNeverExpire
        Save-Backup

        # Apply the policy
        Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -NoConsole
        foreach ($user in $usersWithNeverExpire) {
          Set-LocalUser -Name $user -PasswordNeverExpires $false
        }
    
        Show-Success "[$($PolicyInfo.Name)] Política ajustada correctamente."
      }
    }
    "Restore" {
      Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -NoConsole
      foreach ($user in $Backup[$PolicyInfo.Name]) {
        Set-LocalUser -Name $user -PasswordNeverExpires $true
      }
      Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada correctamente."
    }
    Default {
      Exit-WithError "[$($PolicyInfo.Name)] Acción '$($Global:Info.Action)' no soportada."
    }
  }
}