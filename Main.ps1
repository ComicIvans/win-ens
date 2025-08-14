###############################################################################
# Main.ps1
# Main entry point for the script
###############################################################################

[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8

# Privilege check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Se requieren privilegios de administrador. Elevando..."
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process PowerShell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

# Set window size
# $windowWidth = 80
# $windowHeight = 40
# $bufferWidth = [Math]::Max($windowWidth, 120)
# $bufferHeight = 1000 # Scrollable lines
# $host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size($bufferWidth, $bufferHeight)
# $host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size($windowWidth, $windowHeight)

# Customize window
$Host.ui.rawui.backgroundcolor = "Black"
$Host.ui.rawui.foregroundcolor = "White"
$Host.UI.RawUI.WindowTitle = "PowerShell: SCRIPT PARA LA ADECUACIÓN AL ENS"
Clear-Host

# Import utility functions
Import-Module "$PSScriptRoot\Modules\Utils.ps1"
# Import PrintsAndLogs, where print functions are defined
Import-Module "$PSScriptRoot\Modules\PrintsAndLogs.ps1"
# Import configuration functions
Import-Module "$PSScriptRoot\Modules\Config.ps1"
# Import profile executor
Import-Module "$PSScriptRoot\Modules\ProfileExecutor.ps1"
# Import templates
Import-Module "$PSScriptRoot\Modules\Templates.ps1"

# Global object with general execution information
$Global:Info = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    MachineId = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid"
    Action    = ''
    Error     = ''
    Profile   = $null       # Here we will store the reference to the Info object of the profile
}

# Function to display message, pause and exit
function Exit-WithPause {
    param(
        [Parameter()]
        [int] $Code = 0
    )

    # Close all file handles
    if ($Global:LogWriter) {
        $Global:LogWriter.Dispose()
    }
    if ($Global:LogFile) {
        $Global:LogFile.Close()
    }
    if ($Global:InfoWriter) {
        $Global:InfoWriter.Dispose()
    }
    if ($Global:InfoFile) {
        $Global:InfoFile.Close()
    }

    # Remove temp folder and its content
    Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue

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
    # -1 means that Global:Info/logs couldn't/shouldn't be saved
    if ($Code -eq -1) {
        Show-Error $Message -NoLog
    }
    else {
        $Global:Info.Error = $Message
        Save-GlobalInfo
        Show-Error $Message
    }
    # If exited while executing a group, perform a cleanup
    if ($GroupInfo -and $GroupInfo.Status -ne 'Completed') {
        # Close backup file handles
        if ($backupFileWriter) {
            $backupFileWriter.Dispose()
        }
        if ($backupFile) {
            $backupFile.Close()
        }
        # If $backup it's empty, try to remove the file
        if ($backup -and $backup.Count -eq 0 -and $backupFilePath) {
            Remove-Item -Path $backupFilePath -ErrorAction SilentlyContinue
        }
    }
    # If exited while executing a profile, perform a cleanup
    if ($ProfileInfo -and $ProfileInfo.Status -ne 'Completed') {
        # If backup folder exists and it's empty, try to remove it
        if ($Global:BackupFolderPath -and -not (Get-ChildItem -Path $Global:BackupFolderPath)) {
            Remove-Item -Path $Global:BackupFolderPath -ErrorAction SilentlyContinue
        }
    }
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

# Check for profiles' directory
if (-not (Test-Path "$PSScriptRoot\Profiles")) {
    Exit-WithError "No se ha encontrado el directorio de perfiles: $PSScriptRoot\Profiles" -Code -1
}

# Log directories
$logsRoot = Join-Path $PSScriptRoot ".\Logs"
$logsFolder = Join-Path $logsRoot $Global:Info.MachineId

try {
    if (-not (Test-Path $logsRoot)) { New-Item -Path $logsRoot   -ItemType Directory | Out-Null }
    if (-not (Test-Path $logsFolder)) { New-Item -Path $logsFolder -ItemType Directory | Out-Null }
}
catch {
    Exit-WithError -Message "No se ha podido crear el directorio de logs: $logsRoot. $_" -Code -1
}

# Create log file and store it's file stream and writer in global variables
try {
    $logFilePath = Join-Path $logsFolder "$($Global:Info.Timestamp).log"
    $Global:LogFile = [System.IO.File]::Open($logFilePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    $Global:LogWriter = [System.IO.StreamWriter]::new($Global:LogFile, [System.Text.Encoding]::UTF8)
    $Global:LogWriter.AutoFlush = $true
}
catch {
    Exit-WithError -Message "No se ha podido crear el archivo de log: $logFilePath. $_" -Code -1
}

# Create info file and store it's file stream and writer in global variables
try {
    $infoFilePath = Join-Path $logsFolder "$($Global:Info.Timestamp).json"
    $Global:InfoFile = [System.IO.File]::Open($infoFilePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
    $Global:InfoWriter = [System.IO.StreamWriter]::new($Global:InfoFile, [System.Text.Encoding]::UTF8)
    $Global:InfoWriter.AutoFlush = $true
}
catch {
    Exit-WithError -Message "No se ha podido crear el archivo de información: $infoFilePath. $_" -Code -1
}

# Backup directories
$backupsRoot = Join-Path $PSScriptRoot ".\Backups"
$backupsFolder = Join-Path $backupsRoot $Global:Info.MachineId

try {
    if (-not (Test-Path $backupsRoot)) { New-Item -Path $backupsRoot   -ItemType Directory | Out-Null }
    if (-not (Test-Path $backupsFolder)) { New-Item -Path $backupsFolder -ItemType Directory | Out-Null }
}
catch {
    Exit-WithError -Message "No se ha podido crear el directorio de copias de seguridad: $backupsRoot. $_"
}

# Create a Temp folder
try {
    $tempFolder = Join-Path $PSScriptRoot ".\Temp"
    if (-not (Test-Path $tempFolder)) { New-Item -Path $tempFolder -ItemType Directory | Out-Null }
}
catch {
    Exit-WithError -Message "No se ha podido crear el directorio temporal: $tempFolder. $_"
}

Show-Header3Lines "SCRIPT PARA LA ADECUACIÓN AL ENS"

# Initialize configuration
Initialize-Configuration

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
        "Set" { Exit-WithSuccess "[$profileName] Adecuación completada." }
        "Test" { Exit-WithSuccess "[$profileName] Comprobación completada." }
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
        Show-Info -Message "Restaurando copia de seguridad: $($Global:BackupFolderPath)" -NoConsole

        Invoke-Profile -ProfileName $profileName

        Write-Host ""
        Exit-WithSuccess "[$profileName] Restauración completada."
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