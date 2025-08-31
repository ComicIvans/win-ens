###############################################################################
# Antivirus.ps1
# Antivirus
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name        = 'Antivirus'
  Description = 'Antivirus'
  Type        = 'Custom'
  IsValid     = $null
  Defender    = $null
  OtherAv     = $null
}

function Initialize-Policy {
  # Read third-party registered antivirus products
  $antivirus = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | Where-Object { $_.displayName -ne "Windows Defender" }

  # Project to simple objects with name and status
  $PolicyMeta.OtherAv = @(
    $antivirus | ForEach-Object {
      [PSCustomObject]@{
        Name         = $_.displayName
        ProductState = $_.productState
      }
    }
  )

  $defender = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | Where-Object { $_.displayName -eq "Windows Defender" } | ForEach-Object {
    [PSCustomObject]@{
      Name         = $_.displayName
      ProductState = $_.productState
    }
  }
  if ($defender) {
    $status = Get-MpComputerStatus | Select-Object AMServiceEnabled, AntivirusEnabled, AntispywareEnabled, RealTimeProtectionEnabled
    $defender | Add-Member -MemberType NoteProperty -Name Status -Value $status
    $PolicyMeta.Defender = $defender
  }

  # Valid if there is a third-party AV or Defender is fully enabled
  $defenderAllOn = $false
  if ($defender) {
    $defenderAllOn = ($status.AMServiceEnabled -and $status.AntivirusEnabled -and $status.AntispywareEnabled -and $status.RealTimeProtectionEnabled)
  }
  $PolicyMeta.IsValid = $defenderAllOn -or $PolicyMeta.OtherAv.Count -gt 0
}

function Test-Policy {
  $expected = "Windows Defender (AM=On, AV=On, AS=On, RP=On)"
  $current = @()

  if ($PolicyMeta.OtherAv) {
    foreach ($item in $PolicyMeta.OtherAv) {
      if ($null -ne $item) { $current += "$($item.Name) ($($item.ProductState))" }
    }
  }

  if ($PolicyMeta.Defender) {
    $st = $PolicyMeta.Defender.Status
    $amFlag = if ($st.AMServiceEnabled) { 'On' } else { 'Off' }
    $avFlag = if ($st.AntivirusEnabled) { 'On' } else { 'Off' }
    $asFlag = if ($st.AntispywareEnabled) { 'On' } else { 'Off' }
    $rpFlag = if ($st.RealTimeProtectionEnabled) { 'On' } else { 'Off' }
    $current += "Windows Defender (AM=$amFlag, AV=$avFlag, AS=$asFlag, RP=$rpFlag)"
  }

  $current = if ($current.Count -gt 0) { $current -join ', ' } else { $null }

  Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $expected -CurrentValue $current -ValidValue:$PolicyMeta.IsValid
}

function Backup-Policy {
  $Backup[$PolicyInfo.Name] = [PSCustomObject]@{
    Defender = $PolicyMeta.Defender
    OtherAv  = $PolicyMeta.OtherAv
  }
  Save-Backup
}

function Set-Policy {
  if ($PolicyMeta.OtherAv.Count -gt 0) {
    Show-Warning "[$($PolicyInfo.Name)] Se ha detectado algún antivirus de terceros, los cuales no están soportados. No se realizará ninguna acción."
    return
  }
  if ($null -eq $PolicyMeta.Defender) {
    # Reinstall Windows Defender
    Show-Info "[$($PolicyInfo.Name)] Tratando de reinstalar Windows Defender..."
    Get-AppxPackage Microsoft.SecHealthUI -AllUsers | Reset-AppxPackage
    Initialize-Policy
    if ($null -eq $PolicyMeta.Defender) {
      Exit-WithError "[$($PolicyInfo.Name)] No se pudo encontrar Windows Defender."
    }
  }
  $defenderAllOn = ($PolicyMeta.Defender.Status.AMServiceEnabled -and $PolicyMeta.Defender.Status.AntivirusEnabled -and $PolicyMeta.Defender.Status.AntispywareEnabled -and $PolicyMeta.Defender.Status.RealTimeProtectionEnabled)
  if (-not $defenderAllOn) {
    Show-Warning "[$($PolicyInfo.Name)] Windows Defender no está completamente habilitado. Debes habilitar todas las protecciones manualmente."
  }
}

function Restore-Policy {
  Show-Warning "[$($PolicyInfo.Name)] Esta política no se puede restaurar automáticamente. No se realizará ninguna acción."
}
