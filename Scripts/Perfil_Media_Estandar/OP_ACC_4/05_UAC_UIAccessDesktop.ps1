###############################################################################
# 05_UAC_UIAccessDesktop.ps1
# Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan
# confirmación de elevación sin usar el escritorio seguro (valor esperado: 0).
###############################################################################

# Objeto con metadatos de la política
$05_UAC_UIAccessDesktop_Info = [PSCustomObject]@{
    Name        = '05_UAC_UIAccessDesktop'
    Description = 'Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan confirmación de elevación sin usar el escritorio seguro'
    Status      = 'Pending'
    Error       = ''
}

$OP_ACC_4_Info.Policies += $05_UAC_UIAccessDesktop_Info
Save-GlobalInfo

function Test-05_UAC_UIAccessDesktop {
    $05_UAC_UIAccessDesktop_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($05_UAC_UIAccessDesktop_Info.Name)] Comprobando política..." $true

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableUIADesktopToggle'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName
    
    if ($null -eq $currentValue) {
        $errMsg = "[$($05_UAC_UIAccessDesktop_Info.Name)] No se encontró '$propertyName' en el registro."
        $05_UAC_UIAccessDesktop_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info "[$($05_UAC_UIAccessDesktop_Info.Name)] Política comprobada." $true
        Show-TableRow "$($05_UAC_UIAccessDesktop_Info.Description)" "0" $currentValue
    }
    $05_UAC_UIAccessDesktop_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Set-05_UAC_UIAccessDesktop {
    $05_UAC_UIAccessDesktop_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($05_UAC_UIAccessDesktop_Info.Name)] Creando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($05_UAC_UIAccessDesktop_Info.Name).reg"
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" $backupFile /y > $null 2>&1

    Show-Info "[$($05_UAC_UIAccessDesktop_Info.Name)] Ajustando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'EnableUIADesktopToggle'
    $desiredValue = 0

    New-ItemProperty -Path $regPath -Name $propertyName -Value $desiredValue -PropertyType DWord -Force | Out-Null

    Show-Success "[$($05_UAC_UIAccessDesktop_Info.Name)] Política aplicada."
    $05_UAC_UIAccessDesktop_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-05_UAC_UIAccessDesktop {
    $05_UAC_UIAccessDesktop_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($05_UAC_UIAccessDesktop_Info.Name)] Restaurando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($05_UAC_UIAccessDesktop_Info.Name).reg"
    
    if (Test-Path $backupFile) {
        reg import $backupFile > $null 2>&1
        Show-Success "[$($05_UAC_UIAccessDesktop_Info.Name)] Copia de respaldo restaurada."
    }
    else {
        $errMsg = "[$($05_UAC_UIAccessDesktop_Info.Name)] No se encontró copia de respaldo: $backupFile"
        $05_UAC_UIAccessDesktop_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    $05_UAC_UIAccessDesktop_Info.Status = 'Completed'
    Save-GlobalInfo
}
