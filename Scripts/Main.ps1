###############################################################################
# Main.ps1
# SCRIPT PARA LA ADECUACIÓN AL ENS
###############################################################################

[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8

# Importamos PrintsAndLogs, donde se definen las funciones de impresión y la función para guardar el GlobalInfo
Import-Module "$PSScriptRoot/PrintsAndLogs.ps1"

# Objeto global con metadatos generales de la ejecución
$Global:GlobalInfo = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    MachineId = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid"
    Action    = ''
    Error     = ''
    Profile   = $null       # Aquí almacenaremos la referencia al objeto Info del perfil
}

# Comprobación de privilegios
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Se requieren privilegios de administrador. Elevando..."
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process PowerShell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

Clear-Host

# Función para mostrar el mensaje, pausar y salir
function Exit-WithPause {
    Write-Host "`nPresiona Enter para salir..."
    Read-Host | Out-Null
    exit
}

# Función para mostrar un mensaje de error y salir
function Exit-WithError {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage
    )
    $Global:GlobalInfo.Error = $ErrorMessage
    Save-GlobalInfo
    Show-Error $ErrorMessage
    Exit-WithPause
}

# Función para mostrar un mensaje de éxito y salir
function Exit-WithSuccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SuccessMessage
    )
    Show-Success $SuccessMessage
    Exit-WithPause
}

# Directorios de logs
$logsRoot = Join-Path $PSScriptRoot "..\Logs"
$logsFolder = Join-Path $logsRoot $Global:GlobalInfo.MachineId

if (-not (Test-Path $logsRoot)) { New-Item -Path $logsRoot   -ItemType Directory | Out-Null }
if (-not (Test-Path $logsFolder)) { New-Item -Path $logsFolder -ItemType Directory | Out-Null }

$logFileName = "$($Global:GlobalInfo.Timestamp).log"
$Global:LogFilePath = Join-Path $logsFolder $logFileName

$resultFileName = "$($Global:GlobalInfo.Timestamp).json"
$Global:ResultFilePath = Join-Path $logsFolder $resultFileName

# Directorios de backups
$backupsRoot = Join-Path $PSScriptRoot "..\Backups"
$backupsFolder = Join-Path $backupsRoot $Global:GlobalInfo.MachineId

if (-not (Test-Path $backupsRoot)) { New-Item -Path $backupsRoot   -ItemType Directory | Out-Null }
if (-not (Test-Path $backupsFolder)) { New-Item -Path $backupsFolder -ItemType Directory | Out-Null }

Write-Host ""
Show-Header3Lines "SCRIPT PARA LA ADECUACIÓN AL ENS"
Write-Host ""

Write-Host "1) Comprobar el estado (Test)" -ForegroundColor DarkCyan
Write-Host "2) Aplicar un perfil (Set)" -ForegroundColor DarkCyan
Write-Host "3) Restaurar copia (Restore)" -ForegroundColor DarkCyan
Write-Host ""
$actionChoice = Read-Host -Prompt "Introduce la opción"

switch ($actionChoice) {
    "1" { $Global:GlobalInfo.Action = "Test" }
    "2" { $Global:GlobalInfo.Action = "Set" }
    "3" { $Global:GlobalInfo.Action = "Restore" }
    default {
        Exit-WithError "Acción no válida."
    }
}
Save-GlobalInfo

if ($Global:GlobalInfo.Action -eq "Restore") {
    # Listado de subcarpetas de backup
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
    # Asumiendo que las carpetas se nombran con algo como: "2025-03-30_12-45-00_Media_Estandar"
    $parts = $selectedBackup.Name -split "_"

    if ($parts.Count -ge 4) {
        # 2025-03-30 , 12-45-00, Media, Estandar
        $category = $parts[2]
        $info = $parts[3]

        $profileSuffix = "$category`_$info"
        $profileScript = Join-Path $PSScriptRoot "Perfil_$profileSuffix\Main_$profileSuffix.ps1"
        
        if (-not (Test-Path $profileScript)) {
            Exit-WithError "No se pudo determinar el perfil correspondiente a dicha copia de seguridad. Verifica el nombre de la carpeta."
        }
        $Global:BackupFolderPath = $selectedBackup.FullName

        & $profileScript

        Write-Host ""
        Exit-WithSuccess "Restauración completada."
    }
    else {
        Exit-WithError "No se pudo interpretar la copia de seguridad. Verifica el nombre de la carpeta."
    }
}

# Si no es restaurar, preguntamos categoría/calificación
Write-Host "`nSelecciona categoría del sistema:"
Write-Host "1) Media"
Write-Host "2) Alta"
$catChoice = Read-Host
switch ($catChoice) {
    "1" { $category = "Media" }
    "2" { $category = "Alta" }
    default {
        Exit-WithError "Categoría del sistema no válida."
    }
}

if ($category -eq "Media") {
    Write-Host "`nSelecciona la calificación de la información:"
    Write-Host "1) Estándar"
    Write-Host "2) Uso Oficial"
    $infoChoice = Read-Host
    switch ($infoChoice) {
        "1" { $info = "Estandar" }
        "2" { $info = "UsoOficial" }
        default {
            Exit-WithError "Calificación de la información no válida."
        }
    }
}
elseif ($category -eq "Alta") {
    Write-Host "`nSelecciona la calificación de la información:"
    Write-Host "1) Uso Oficial"
    $infoChoice = Read-Host
    switch ($infoChoice) {
        "1" { $info = "UsoOficial" }
        default {
            Exit-WithError "Calificación de la información no válida."
        }
    }
}
else {
    Exit-WithError "Categoría del sistema no soportada."
}

$profileSuffix = "$category`_$info"
$profileScript = Join-Path $PSScriptRoot "Perfil_$category`_$info\Main_$profileSuffix.ps1"
# Verificamos que el script existe
if (-not (Test-Path $profileScript)) {
    Exit-WithError "No se pudo determinar el perfil correspondiente a la categoría y calificación seleccionadas."
}

$backupFolderName = "$($Global:GlobalInfo.Timestamp)`_$profileSuffix"
$Global:BackupFolderPath = Join-Path $backupsFolder $backupFolderName
if (-not $Global:GlobalInfo.Action -eq "Test") {
    New-Item -Path $Global:BackupFolderPath -ItemType Directory | Out-Null
}

& $profileScript

# Fin del script
Write-Host ""
if ($Global:GlobalInfo.Action -eq "Set") {
    Exit-WithSuccess "Adecuación completada."
}
elseif ($Global:GlobalInfo.Action -eq "Test") {
    Exit-WithSuccess "Comprobación completada."
}