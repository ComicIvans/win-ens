###############################################################################
# 01_UAC_AdminPromptBehavior.ps1
# Control de cuentas de usuario: ConsentPromptBehaviorAdmin = 2
###############################################################################

# Objeto con metadatos de la política
$01_UAC_AdminPromptBehavior_Info = [PSCustomObject]@{
    Name        = '01_UAC_AdminPromptBehavior'
    Description = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los administradores en Modo de aprobación de administrador'
    Status      = 'Pending'
    Error       = ''
}

$OP_ACC_4_Info.Policies += $01_UAC_AdminPromptBehavior_Info
Save-GlobalInfo
  
function Test-01_UAC_AdminPromptBehavior {
    $01_UAC_AdminPromptBehavior_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($01_UAC_AdminPromptBehavior_Info.Name)] Comprobando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $currentValue = (Get-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
    
    if ($null -eq $currentValue) {
        $errMsg = "[$($01_UAC_AdminPromptBehavior_Info.Name)] No se encontró 'ConsentPromptBehaviorAdmin' en el registro."
        $01_UAC_AdminPromptBehavior_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info "[$($01_UAC_AdminPromptBehavior_Info.Name)] Política comprobada." $true
        Show-TableRow "$($01_UAC_AdminPromptBehavior_Info.Description)" "2" $currentValue
    }
    $01_UAC_AdminPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}
  
function Set-01_UAC_AdminPromptBehavior {
    $01_UAC_AdminPromptBehavior_Info.Status = 'Running'
    Save-GlobalInfo
    # Backup
    Show-Info "[$($01_UAC_AdminPromptBehavior_Info.Name)] Creando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($01_UAC_AdminPromptBehavior_Info.Name).reg"
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" $backupFile /y > $null 2>&1
  
    # Ajuste de la política
    Show-Info "[$($01_UAC_AdminPromptBehavior_Info.Name)] Ajustando política..." $true
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    New-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value 2 -PropertyType DWord -Force | Out-Null
  
    Show-Success "[$($01_UAC_AdminPromptBehavior_Info.Name)] Política aplicada."
    $01_UAC_AdminPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}
  
function Restore-01_UAC_AdminPromptBehavior {
    $01_UAC_AdminPromptBehavior_Info.Status = 'Running'
    Save-GlobalInfo
    Show-Info "[$($01_UAC_AdminPromptBehavior_Info.Name)] Restaurando copia de respaldo..." $true
    $backupFile = Join-Path $backupSubfolderPath "$($01_UAC_AdminPromptBehavior_Info.Name).reg"
    
    if (Test-Path $backupFile) {
        reg import $backupFile > $null 2>&1
        Show-Success "[$($01_UAC_AdminPromptBehavior_Info.Name)] Copia de respaldo restaurada."
    }
    else {
        $errMsg = "[$($01_UAC_AdminPromptBehavior_Info.Name)] No se encontró copia de respaldo: $backupFile"
        $01_UAC_AdminPromptBehavior_Info.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    $01_UAC_AdminPromptBehavior_Info.Status = 'Completed'
    Save-GlobalInfo
}
  