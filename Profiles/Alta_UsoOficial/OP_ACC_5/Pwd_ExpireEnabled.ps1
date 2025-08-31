###############################################################################
# Pwd_ExpireEnabled.ps1
# Cuentas cuyas contraseñas nunca expiran
###############################################################################

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name                 = 'Pwd_ExpireEnabled'
  Description          = 'Cuentas cuyas contraseñas nunca expiran'
  Type                 = 'Custom'
  IsValid              = $null
  UsersWithNeverExpire = $null
}

function Initialize-Policy {
  $guestName = (Get-LocalUser | Where-Object { $_.SID.Value -like 'S-1-5-21-*-501' }).Name
  $users = Get-LocalUser | Where-Object { $_.Enabled -and $_.Name -ne $guestName }
  $PolicyMeta.UsersWithNeverExpire = $users | Where-Object { -not $_.PasswordExpires } | Select-Object -ExpandProperty Name
  $PolicyMeta.IsValid = ($null -eq $PolicyMeta.UsersWithNeverExpire)
}

function Test-Policy {
  Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $null -CurrentValue $PolicyMeta.UsersWithNeverExpire -ValidValue:$PolicyMeta.IsValid
}

function Backup-Policy {
  $Backup[$PolicyInfo.Name] = $PolicyMeta.UsersWithNeverExpire
  Save-Backup
}

function Set-Policy {
  foreach ($user in $PolicyMeta.UsersWithNeverExpire) {
    Set-LocalUser -Name $user -PasswordNeverExpires $false
  }
}

function Restore-Policy {
  foreach ($user in $Backup[$PolicyInfo.Name]) {
    Set-LocalUser -Name $user -PasswordNeverExpires $true
  }
}
