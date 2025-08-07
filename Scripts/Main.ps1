###############################################################################
# Main.ps1
# Main entry point for the script
###############################################################################

[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8

# Import utility functions
Import-Module "$PSScriptRoot/Utils.ps1"
# Import PrintsAndLogs, where print functions are defined
Import-Module "$PSScriptRoot/PrintsAndLogs.ps1"
# Import configuration functions
Import-Module "$PSScriptRoot/Config.ps1"
# Import profile executor
Import-Module "$PSScriptRoot/ProfileExecutor.ps1"

# Privilege check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Se requieren privilegios de administrador. Elevando..."
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process PowerShell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

# Global object with general execution metadata
$Global:Info = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    MachineId = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid"
    Action    = ''
    Error     = ''
    Profile   = $null       # Here we will store the reference to the Info object of the profile
}

Clear-Host

# Function to display message, pause and exit
function Exit-WithPause {
    param(
        [Parameter()]
        [int] $Code = 0
    )

    Write-Host "`nPresiona Enter para salir..."
    Read-Host | Out-Null
    exit $Code
}

# Function to display an error message and exit
function Exit-WithError {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [int]$Code = 1
    )
    $Global:Info.Error = $Message
    # -1 means that Global:Info can't be saved
    if (-not $Code -eq -1) {
        Save-GlobalInfo
    }
    Show-Error $Message
    Exit-WithPause $Code
}

# Function to display a success message and exit
function Exit-WithSuccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SuccessMessage
    )
    Show-Success $SuccessMessage
    Exit-WithPause 0
}

# Log directories
$logsRoot = Join-Path $PSScriptRoot "..\Logs"
$logsFolder = Join-Path $logsRoot $Global:Info.MachineId

try {
    if (-not (Test-Path $logsRoot)) { New-Item -Path $logsRoot   -ItemType Directory | Out-Null }
    if (-not (Test-Path $logsFolder)) { New-Item -Path $logsFolder -ItemType Directory | Out-Null }
}
catch {
    Exit-WithError -Message "No se ha podido crear el directorio de logs: $logsRoot. $_" -Code -1
}

# Create log file name and store its path in a global variable
$logFileName = "$($Global:Info.Timestamp).log"
$Global:LogFilePath = Join-Path $logsFolder $logFileName

try {
    New-Item -Path $Global:LogFilePath -ItemType File -Force | Out-Null
}
catch {
    Exit-WithError -Message "No se ha podido crear el archivo de log: $Global:LogFilePath. $_" -Code -1
}

# Create info file name and store its path in a global variable
$infoFileName = "$($Global:Info.Timestamp).json"
$Global:InfoFilePath = Join-Path $logsFolder $infoFileName

try {
    New-Item -Path $Global:InfoFilePath -ItemType File -Force | Out-Null
}
catch {
    Exit-WithError -Message "No se ha podido crear el archivo de información: $Global:InfoFilePath. $_" -Code -1
}

# Backup directories
$backupsRoot = Join-Path $PSScriptRoot "..\Backups"
$backupsFolder = Join-Path $backupsRoot $Global:Info.MachineId

try {
    if (-not (Test-Path $backupsRoot)) { New-Item -Path $backupsRoot   -ItemType Directory | Out-Null }
    if (-not (Test-Path $backupsFolder)) { New-Item -Path $backupsFolder -ItemType Directory | Out-Null }
}
catch {
    Exit-WithError -Message "No se ha podido crear el directorio de copias de seguridad: $backupsRoot. $_"
}

Write-Host ""
Show-Header3Lines "SCRIPT PARA LA ADECUACIÓN AL ENS"
Write-Host ""

# Initialize configuration
Initialize-Configuration
Write-Host ""

# Functions to show the menu
function Show-ActionMenu {
    Write-Host ""
    Write-Host "Acciones disponibles:" -ForegroundColor Yellow
    Write-Host "1) Comprobar el estado" -ForegroundColor DarkCyan
    Write-Host "2) Aplicar un perfil" -ForegroundColor DarkCyan
    Write-Host "3) Restaurar copia" -ForegroundColor DarkCyan
    Write-Host "4) Ver configuración" -ForegroundColor DarkCyan
    Write-Host "5) Salir" -ForegroundColor DarkCyan
    Write-Host ""
    return Read-Host -Prompt "Introduce la opción"
}

# Function to select category and information rating, then execute the profile
function Select-ExecuteProfile {
    Write-Host "`nSelecciona categoría del sistema:"
    Write-Host "1) Media"
    Write-Host "2) Alta"
    $catChoice = Read-Host
    switch ($catChoice) {
        "1" { $category = "Media" }
        "2" { $category = "Alta" }
        default { Exit-WithError "Categoría del sistema no válida." }
    }
    
    if ($category -eq "Media") {
        Write-Host "`nSelecciona la calificación de la información:"
        Write-Host "1) Estándar"
        Write-Host "2) Uso Oficial"
        $infoChoice = Read-Host
        switch ($infoChoice) {
            "1" { $info = "Estandar" }
            "2" { $info = "UsoOficial" }
            default { Exit-WithError "Calificación de la información no válida." }
        }
    }
    elseif ($category -eq "Alta") {
        Write-Host "`nSelecciona la calificación de la información:"
        Write-Host "1) Uso Oficial"
        $infoChoice = Read-Host
        switch ($infoChoice) {
            "1" { $info = "UsoOficial" }
            default { Exit-WithError "Calificación de la información no válida." }
        }
    }
    else {
        Exit-WithError "Categoría del sistema no soportada."
    }
    
    $profileName = "$category`_$info"
    
    if (($Global:Info.Action -eq "Set")) {
        $backupFolderName = "$($Global:Info.Timestamp)`_$profileName"
        $Global:BackupFolderPath = Join-Path $backupsFolder $backupFolderName
        New-Item -Path $Global:BackupFolderPath -ItemType Directory | Out-Null
    }
    
    Invoke-Profile -ProfileName $profileName

    Write-Host ""
    switch ($Global:Info.Action) {
        "Set" { Exit-WithSuccess "Adecuación del perfil completada." }
        "Test" { Exit-WithSuccess "Comprobación del perfil completada." }
    }
}

# Function to restore a backup
function Restore-Backup {
    $backupFolders = Get-ChildItem $backupsFolder -Directory | Sort-Object LastWriteTime -Descending
    if (-not $backupFolders) {
        Exit-WithError "No hay copias de seguridad disponibles para este equipo."
    }
    
    Write-Host "`nCopias disponibles para este equipo:"
    Write-Host ""
    for ($i = 0; $i -lt $backupFolders.Count; $i++) {
        Write-Host ("{0}) {1}" -f ($i + 1), $backupFolders[$i].Name) -ForegroundColor DarkCyan
    }
    Write-Host ""
    $sel = Read-Host -Prompt "Selecciona la copia a restaurar (número)"
    [int]$selIndex = $sel - 1
    
    if ($selIndex -lt 0 -or $selIndex -ge $backupFolders.Count) {
        Exit-WithError "Copia a restaurar no válida."
    }
    
    $selectedBackup = $backupFolders[$selIndex]
    $parts = $selectedBackup.Name -split "_"
    if ($parts.Count -ge 4) {
        $category = $parts[2]
        $info = $parts[3]
        $profileName = "$category`_$info"

        $Global:BackupFolderPath = $selectedBackup.FullName
        Show-Info -Message "Restaurando copia de seguridad: $($Global:BackupFolderPath)" -LogOnly

        Invoke-Profile -ProfileName $profileName

        Write-Host ""
        Exit-WithSuccess "Restauración completada."
    }
    else {
        Exit-WithError "No se pudo interpretar la copia de seguridad. Verifica el nombre de la carpeta."
    }
}

# Main loop to show the action menu and execute actions
do {
    $invalid = $false
    $choice = Show-ActionMenu
    switch ($choice) {
        "1" {
            $Global:Info.Action = "Test"
            Save-GlobalInfo
            Select-ExecuteProfile 
        }
        "2" {
            $Global:Info.Action = "Set"
            Save-GlobalInfo
            Select-ExecuteProfile 
        }
        "3" {
            $Global:Info.Action = "Restore"
            Save-GlobalInfo
            Restore-Backup 
        }
        "4" {
            $Global:Info.Action = "Config"
            Save-GlobalInfo
            Show-Config 
        }
        "5" { Exit-WithPause }
        default {
            Write-Host "Acción no válida. Intenta de nuevo."
            $invalid = $true
        }
    }
} while ($Global:Info.Action -eq "Config" -or $invalid)