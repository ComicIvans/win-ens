###############################################################################
# 03_UAC_EnableInstallerDetection.ps1
# Control de cuentas de usuario: detectar instalaciones de aplicaciones y
# pedir confirmación de elevación (habilitada).
###############################################################################

# Objeto con metadatos de la política
$03_UAC_EnableInstallerDetection_Info = [PSCustomObject]@{
    Name        = '03_UAC_EnableInstallerDetection'
    Description = 'Control de cuentas de usuario: detectar instalaciones de aplicaciones y pedir confirmación de elevación'
    Status      = 'Pending'
    Error       = ''
}

$OP_ACC_4_Info.Policies += $03_UAC_EnableInstallerDetection_Info
Save-GlobalInfo

function Test-03_UAC_EnableInstallerDetection {
    $03_UAC_EnableInstallerDetection_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($03_UAC_EnableInstallerDetection_Info.Name)] Comprobando política..." $true

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableInstallerDetection'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName

    if ($null -eq $currentValue) {
        $errMsg = "[$($03_UAC_EnableInstallerDetection_Info.Name)] No se encontró '$propertyName' en el registro."
        $03_UAC_EnableInstallerDetection_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info "[$($03_UAC_EnableInstallerDetection_Info.Name)] Política comprobada." $true
        Show-TableRow "$($03_UAC_EnableInstallerDetection_Info.Description)" "1" $currentValue
    }
    $03_UAC_EnableInstallerDetection_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Set-03_UAC_EnableInstallerDetection {
    $03_UAC_EnableInstallerDetection_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($03_UAC_EnableInstallerDetection_Info.Name)] Creando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($03_UAC_EnableInstallerDetection_Info.Name).reg"
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" $backupFile /y > $null 2>&1

    Show-Info "[$($03_UAC_EnableInstallerDetection_Info.Name)] Ajustando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableInstallerDetection'
    $desiredValue = 1

    New-ItemProperty -Path $regPath -Name $propertyName -Value $desiredValue -PropertyType DWord -Force | Out-Null

    Show-Success "[$($03_UAC_EnableInstallerDetection_Info.Name)] Política aplicada."
    $03_UAC_EnableInstallerDetection_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-03_UAC_EnableInstallerDetection {
    $03_UAC_EnableInstallerDetection_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($03_UAC_EnableInstallerDetection_Info.Name)] Restaurando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($03_UAC_EnableInstallerDetection_Info.Name).reg"
  
    if (Test-Path $backupFile) {
        reg import $backupFile > $null 2>&1
        Show-Success "[$($03_UAC_EnableInstallerDetection_Info.Name)] Copia de respaldo restaurada."
    }
    else {
        $errMsg = "[$($03_UAC_EnableInstallerDetection_Info.Name)] No se encontró copia de respaldo: $backupFile"
        $03_UAC_EnableInstallerDetection_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    $03_UAC_EnableInstallerDetection_Info.Status = 'Completed'
    Save-GlobalInfo
}
