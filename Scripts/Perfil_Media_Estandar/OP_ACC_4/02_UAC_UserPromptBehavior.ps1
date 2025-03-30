###############################################################################
# 02_UAC_UserPromptBehavior.ps1
# Control de cuentas de usuario: ConsentPromptBehaviorUser = 1
###############################################################################

# Objeto con metadatos de la política
$02_UAC_UserPromptBehavior_Info = [PSCustomObject]@{
    Name        = '02_UAC_UserPromptBehavior'
    Description = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los usuarios estándar'
    Status      = 'Pending'
    Error       = ''
}

$OP_ACC_4_Info.Policies += $02_UAC_UserPromptBehavior_Info
Save-GlobalInfo

function Test-02_UAC_UserPromptBehavior {
    $02_UAC_UserPromptBehavior_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($02_UAC_UserPromptBehavior_Info.Name)] Comprobando política..." $true

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'ConsentPromptBehaviorUser'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName

    if ($null -eq $currentValue) {
        $errMsg = "[$($02_UAC_UserPromptBehavior_Info.Name)] No se encontró '$propertyName' en el registro."
        $02_UAC_UserPromptBehavior_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info "[$($02_UAC_UserPromptBehavior_Info.Name)] Política comprobada." $true
        Show-TableRow "$($02_UAC_UserPromptBehavior_Info.Description)" "1" $currentValue
    }
    $02_UAC_UserPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Set-02_UAC_UserPromptBehavior {
    $02_UAC_UserPromptBehavior_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($02_UAC_UserPromptBehavior_Info.Name)] Creando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($02_UAC_UserPromptBehavior_Info.Name).reg"
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" $backupFile /y > $null 2>&1

    Show-Info "[$($02_UAC_UserPromptBehavior_Info.Name)] Ajustando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'ConsentPromptBehaviorUser'
    $desiredValue = 1

    New-ItemProperty -Path $regPath -Name $propertyName -Value $desiredValue -PropertyType DWord -Force | Out-Null

    Show-Success "[$($02_UAC_UserPromptBehavior_Info.Name)] Política aplicada."
    $02_UAC_UserPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-02_UAC_UserPromptBehavior {
    Show-Info "[$($02_UAC_UserPromptBehavior_Info.Name)] Restaurando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($02_UAC_UserPromptBehavior_Info.Name).reg"

    if (Test-Path $backupFile) {
        reg import $backupFile > $null 2>&1
        Show-Success "[$($02_UAC_UserPromptBehavior_Info.Name)] Copia de respaldo restaurada."
    }
    else {
        $errMsg = "[$($02_UAC_UserPromptBehavior_Info.Name)] No se encontró copia de respaldo: $backupFile"
        $02_UAC_UserPromptBehavior_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    $02_UAC_UserPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}
