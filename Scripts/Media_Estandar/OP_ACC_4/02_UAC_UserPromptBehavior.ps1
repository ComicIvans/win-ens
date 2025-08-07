###############################################################################
# 02_UAC_UserPromptBehavior.ps1
# Control de cuentas de usuario: ConsentPromptBehaviorUser = 1
###############################################################################

# Object with policy metadata
$PolicyInfo = [PSCustomObject]@{
    Name        = '02_UAC_UserPromptBehavior'
    Description = 'Control de cuentas de usuario: comportamiento de la petición de elevación para los usuarios estándar'
    Status      = 'Pending'
}

$GroupInfo.Policies += $PolicyInfo
Save-GlobalInfo

function Test-Policy {
    $PolicyInfo.Status = 'Running'
    Save-GlobalInfo
    Show-Info -Message "[$($PolicyInfo.Name)] Comprobando política..." -LogOnly

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $propertyName = 'ConsentPromptBehaviorUser'
    $currentValue = (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName

    if ($null -eq $currentValue) {
        Exit-WithError "[$($PolicyInfo.Name)] No se encontró '$propertyName' en el registro."
    }
    else {
        Show-Info -Message "[$($PolicyInfo.Name)] Política comprobada." -LogOnly
        Show-TableRow "$($PolicyInfo.Description)" "1" $currentValue
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
    $backup[$PolicyInfo.Name] = (Get-ItemProperty -Path $regPath -Name 'ConsentPromptBehaviorUser' -ErrorAction SilentlyContinue).ConsentPromptBehaviorUser
    Save-Backup

    # Apply the policy
    Show-Info -Message "[$($PolicyInfo.Name)] Ajustando política..." -LogOnly
    $propertyName = 'ConsentPromptBehaviorUser'
    $desiredValue = 1
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
    New-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorUser" -Value $backup[$PolicyInfo.Name] -PropertyType DWord -Force | Out-Null
    Show-Success "[$($PolicyInfo.Name)] Copia de respaldo restaurada."

    $PolicyInfo.Status = 'Completed'
    Save-GlobalInfo
}
