###############################################################################
# 04_UAC_EnableLUA.ps1
# Control de cuentas de usuario: ejecutar todos los administradores en
# Modo de aprobación de administrador (habilitada).
###############################################################################

# Objeto con metadatos de la política
$04_UAC_EnableLUA_Info = [PSCustomObject]@{
    Name        = '04_UAC_EnableLUA'
    Description = 'Control de cuentas de usuario: ejecutar todos los administradores en Modo de aprobación de administrador'
    Status      = 'Pending'
    Error       = ''
}

$OP_ACC_4_Info.Policies += $04_UAC_EnableLUA_Info
Save-GlobalInfo

function Test-04_UAC_EnableLUA {
    $04_UAC_EnableLUA_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($04_UAC_EnableLUA_Info.Name)] Comprobando política..." $true

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableLUA'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName

    if ($null -eq $currentValue) {
        $errMsg = "[$($04_UAC_EnableLUA_Info.Name)] No se encontró '$propertyName' en el registro."
        $04_UAC_EnableLUA_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info "[$($04_UAC_EnableLUA_Info.Name)] Política comprobada." $true
        Show-TableRow "$($04_UAC_EnableLUA_Info.Description)" "1" $currentValue
    }
    $04_UAC_EnableLUA_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Set-04_UAC_EnableLUA {
    $04_UAC_EnableLUA_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($04_UAC_EnableLUA_Info.Name)] Creando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($04_UAC_EnableLUA_Info.Name).reg"
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" $backupFile /y > $null 2>&1

    Show-Info "[$($04_UAC_EnableLUA_Info.Name)] Ajustando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableLUA'
    $desiredValue = 1

    New-ItemProperty -Path $regPath -Name $propertyName -Value $desiredValue -PropertyType DWord -Force | Out-Null

    Show-Success "[$($04_UAC_EnableLUA_Info.Name)] Política aplicada."
    $04_UAC_EnableLUA_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-04_UAC_EnableLUA {
    $04_UAC_EnableLUA_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($04_UAC_EnableLUA_Info.Name)] Restaurando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($04_UAC_EnableLUA_Info.Name).reg"
  
    if (Test-Path $backupFile) {
        reg import $backupFile > $null 2>&1
        Show-Success "[$($04_UAC_EnableLUA_Info.Name)] Copia de respaldo restaurada."
    }
    else {
        $errMsg = "[$($04_UAC_EnableLUA_Info.Name)] No se encontró copia de respaldo: $backupFile"
        $04_UAC_EnableLUA_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    $04_UAC_EnableLUA_Info.Status = 'Completed'
    Save-GlobalInfo
}
