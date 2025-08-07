###############################################################################
# 01_UAC_AdminPromptBehavior.ps1
# Control de cuentas de usuario: ConsentPromptBehaviorAdmin = 2
###############################################################################

# Object with policy metadata
$PolicyInfo = [PSCustomObject]@{
    Name        = '01_UAC_AdminPromptBehavior'
    Description = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los administradores en Modo de aprobación de administrador'
    Status      = 'Pending'
    Error       = ''
}

$GroupInfo.Policies += $PolicyInfo
Save-GlobalInfo
  
function Test-Policy {
    $PolicyInfo.Status = 'Running'
    Save-GlobalInfo
    Show-Info -Message "[$($PolicyInfo.Name)] Comprobando política..." -LogOnly
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $currentValue = (Get-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
    
    if ($null -eq $currentValue) {
        $errMsg = "[$($PolicyInfo.Name)] No se encontró 'ConsentPromptBehaviorAdmin' en el registro."
        $PolicyInfo.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info -Message "[$($PolicyInfo.Name)] Política comprobada." -LogOnly
        Show-TableRow "$($PolicyInfo.Description)" "2" $currentValue
    }
    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}

function Set-Policy {
    $PolicyInfo.Status = 'Running'
    Save-GlobalInfo

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

    # Take a backup
    Show-Info -Message "[$($PolicyInfo.Name)] Creando copia de respaldo..." -LogOnly
    $backup[$PolicyInfo.Name] = (Get-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
    if (-not (Save-Backup)) {
        $PolicyInfo.Status = 'Completed'
        Save-GlobalInfo
        return
    }

    # Apply the policy
    Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -LogOnly
    New-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value 2 -PropertyType DWord -Force | Out-Null
  
    Show-Success "[$($PolicyInfo.Name)] Política aplicada."
    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-Policy {
    $PolicyInfo.Status = 'Running'
    Save-GlobalInfo
    Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -LogOnly
    
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    New-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value $backup[$PolicyInfo.Name] -PropertyType DWord -Force | Out-Null
    Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."

    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}
