###############################################################################
# 05_UAC_UIAccessDesktop.ps1
# Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan
# confirmación de elevación sin usar el escritorio seguro (valor esperado: 0).
###############################################################################

# Object with policy metadata
$PolicyInfo = [PSCustomObject]@{
    Name        = '05_UAC_UIAccessDesktop'
    Description = 'Control de cuentas de usuario: permitir que las aplicaciones UIAccess pidan confirmación de elevación sin usar el escritorio seguro'
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
    $propertyName = 'EnableUIADesktopToggle'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName
    
    if ($null -eq $currentValue) {
        $errMsg = "[$($PolicyInfo.Name)] No se encontró '$propertyName' en el registro."
        $PolicyInfo.Error = $errMsg
        Save-GlobalInfo
        Show-Error $errMsg
    }
    else {
        Show-Info -Message "[$($PolicyInfo.Name)] Política comprobada." -LogOnly
        Show-TableRow "$($PolicyInfo.Description)" "0" $currentValue
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
    $backup[$PolicyInfo.Name] = (Get-ItemProperty -Path $regPath -Name 'EnableUIADesktopToggle' -ErrorAction SilentlyContinue).EnableUIADesktopToggle
    if (-not (Save-Backup)) {
        $PolicyInfo.Status = 'Completed'
        Save-GlobalInfo
        return
    }

    # Apply the policy
    Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -LogOnly
    $propertyName = 'EnableUIADesktopToggle'
    $desiredValue = 0
    New-ItemProperty -Path $regPath -Name $propertyName -Value $desiredValue -PropertyType DWord -Force | Out-Null

    Show-Success "[$($PolicyInfo.Name)] Política aplicada."
    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}

function Restore-Policy {
    $PolicyInfo.Status = 'Running'
    Save-GlobalInfo
    Show-Info -Message "[$($PolicyInfo.Name)] Restaurando copia de respaldo..." -LogOnly

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    New-ItemProperty -Path $regPath -Name 'EnableUIADesktopToggle' -Value $backup[$PolicyInfo.Name] -PropertyType DWord -Force | Out-Null
    Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."

    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}
