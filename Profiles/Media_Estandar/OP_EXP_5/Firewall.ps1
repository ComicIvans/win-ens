###############################################################################
# Firewall.ps1
# Firewall
###############################################################################

# Object with policy's metadata
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name        = 'Firewall'
  Description = 'Firewall'
  Type        = 'Custom'
  IsValid     = $null
  Windows     = $null
  OtherFw     = $null
}

function Initialize-Policy {
  # Read third-party registered firewall products
  $firewall = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName FirewallProduct

  $PolicyMeta.OtherFw = @(
    $firewall | ForEach-Object {
      [PSCustomObject]@{
        Name         = $_.displayName
        ProductState = $_.productState
      }
    }
  )

  $profiles = Get-NetFirewallProfile
  $PolicyMeta.Windows = [ordered]@{}
  foreach ($p in $profiles) { $PolicyMeta.Windows[$p.Name] = [bool]$p.Enabled }

  if ($null -eq $PolicyMeta.Windows) {
    Exit-WithError "[$($PolicyInfo.Name)] No se encontró el Firewall de Windows."
    return
  }

  # Valid if there is a third-party FW or all Windows profiles are enabled
  $windowsAllOn = $PolicyMeta.Windows.Domain -and $PolicyMeta.Windows.Private -and $PolicyMeta.Windows.Public
  $PolicyMeta.IsValid = $windowsAllOn -or ($PolicyMeta.OtherFw.Count -gt 0)
}

function Test-Policy {
  $expected = 'Windows Firewall (Domain=On, Private=On, Public=On)'
  $current = @()

  if ($PolicyMeta.OtherFw) {
    foreach ($fw in $PolicyMeta.OtherFw) {
      if ($null -ne $fw) { $current += "$($fw.Name) ($($fw.ProductState))" }
    }
  }

  $d = if ($PolicyMeta.Windows.Domain) { 'On' } else { 'Off' }
  $p = if ($PolicyMeta.Windows.Private) { 'On' } else { 'Off' }
  $u = if ($PolicyMeta.Windows.Public) { 'On' } else { 'Off' }
  $current += "Windows Firewall (Domain=$d, Private=$p, Public=$u)"

  $current = if ($current.Count -gt 0) { $current -join ', ' } else { $null }

  Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $expected -CurrentValue $current -ValidValue:$PolicyMeta.IsValid
}

function Backup-Policy {
  $Backup[$PolicyInfo.Name] = [PSCustomObject]@{
    Windows = $PolicyMeta.Windows
    OtherFw = $PolicyMeta.OtherFw
  }
  Save-Backup
}

function Set-Policy {
  if ($PolicyMeta.OtherFw.Count -gt 0) {
    Show-Warning "[$($PolicyInfo.Name)] Se ha detectado algún firewall de terceros, los cuales no están soportados. No se realizará ninguna acción."
    return
  }

  # Enable all profiles
  Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True -ErrorAction Stop
}

function Restore-Policy {
  $snap = $Backup[$PolicyInfo.Name]

  if ($snap.OtherFw.Count -gt 0) {
    Show-Warning "[$($PolicyInfo.Name)] Se ha detectado algún firewall de terceros, los cuales no están soportados. No se realizará ninguna acción."
    return
  }
  
  $targets = @(
    @{ Name = 'Domain'; Value = $snap.Windows.Domain },
    @{ Name = 'Private'; Value = $snap.Windows.Private },
    @{ Name = 'Public'; Value = $snap.Windows.Public }
  )
  foreach ($t in $targets) {
    Set-NetFirewallProfile -Profile $t.Name -Enabled $(if ($t.Value) { 'True' } else { 'False' }) -ErrorAction Stop
  }
}

function Assert-Policy {
  # Not supported
  return $true
}