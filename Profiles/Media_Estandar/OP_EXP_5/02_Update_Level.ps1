###############################################################################
# 02_Update_Level.ps1
# Nivel de actualización
###############################################################################

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$PolicyMeta = [PSCustomObject]@{
  Name                = '02_Update_Level'
  Description         = 'Nivel de actualización'
  Type                = 'Custom'
  IsValid             = $null
  DaysSinceLastUpdate = $null
  PendingUpdatesCount = $null
}

function Initialize-Policy {
  $last = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
  $PolicyMeta.DaysSinceLastUpdate = (New-TimeSpan -Start $last.InstalledOn -End (Get-Date)).Days

  $session = New-Object -ComObject Microsoft.Update.Session
  $searcher = $session.CreateUpdateSearcher()
  $search = $searcher.Search("IsInstalled=0 and IsHidden=0")
  $PolicyMeta.PendingUpdatesCount = [int]$search.Updates.Count

  $PolicyMeta.IsValid = $PolicyMeta.PendingUpdatesCount -eq 0 -and $PolicyMeta.DaysSinceLastUpdate -lt 60
}

function Test-Policy {
  $expected = "Última hace menos de 60 días. Pendientes: 0."
  $current = "Última hace {0} días. Pendientes: {1}." -f $PolicyMeta.DaysSinceLastUpdate, $PolicyMeta.PendingUpdatesCount

  Show-TableRow -PolicyName "$($PolicyMeta.Description)" -ExpectedValue $expected -CurrentValue $current -ValidValue:$PolicyMeta.IsValid
}

function Backup-Policy {
  $Backup[$PolicyInfo.Name] = [PSCustomObject]@{
    DaysSinceLastUpdate = $PolicyMeta.DaysSinceLastUpdate
    PendingUpdatesCount = $PolicyMeta.PendingUpdatesCount
  }
  Save-Backup
}

function Set-Policy {
  if ($PolicyMeta.PendingUpdatesCount -gt 0) {
    # Generate a temp script to download and install updates in the background
    $tempScript = Join-Path $env:TEMP ("win-ens-update-{0}.ps1" -f ([guid]::NewGuid().ToString()))
    $bgScript = @'
try {
  $session = New-Object -ComObject Microsoft.Update.Session
  $searcher = $session.CreateUpdateSearcher()
  $result = $searcher.Search("IsInstalled=0 and IsHidden=0")
  if ($result.Updates.Count -gt 0) {
    $all = New-Object -ComObject Microsoft.Update.UpdateColl
    for ($i = 0; $i -lt $result.Updates.Count; $i++) { [void]$all.Add($result.Updates.Item($i)) }
    $downloader = $session.CreateUpdateDownloader(); $downloader.Updates = $all; $null = $downloader.Download()
    $toInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    for ($j = 0; $j -lt $all.Count; $j++) { if ($all.Item($j).IsDownloaded) { [void]$toInstall.Add($all.Item($j)) } }
    if ($toInstall.Count -gt 0) { $installer = $session.CreateUpdateInstaller(); $installer.ForceQuiet=$true; $installer.Updates=$toInstall; $null=$installer.Install() }
  }
} catch { }
try { Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force } catch { }
'@
    $bgScript | Set-Content -Path $tempScript -Encoding UTF8
    # Launch detached PowerShell to execute the update script silently
    Show-Info "[$($PolicyInfo.Name)] Se ha iniciado la instalación de actualizaciones en segundo plano."
    Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$tempScript`"") -WindowStyle Hidden | Out-Null
  }
}

function Restore-Policy {
  Show-Warning "[$($PolicyInfo.Name)] Esta política no se puede restaurar. No se realizará ninguna acción."
}
