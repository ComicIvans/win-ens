###############################################################################
# PrintsAndLogs.ps1
# Funciones de impresión, log y guardado de info global
###############################################################################

# Longitud máxima de las líneas a imprimir en consola. Se recomienda que sea al menos 80 para mostrar las tablas correctamente.
$Global:MaxLineLength = 120

function Save-GlobalInfo {
    # Convierte $Global:GlobalInfo a JSON y lo escribe en $Global:ResultFilePath
    if ($Global:ResultFilePath -and $Global:GlobalInfo) {
        $jsonData = $Global:GlobalInfo | ConvertTo-Json -Depth 5
        Set-Content -Path $Global:ResultFilePath -Value $jsonData -Encoding UTF8
    }
}

function Show-Header3Lines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )
    $maxLine = $Global:MaxLineLength
    $border = "=" * $maxLine
    $leftWidth = [Math]::Ceiling(($maxLine + $Text.Length) / 2)
    $centeredText = $Text.PadLeft($leftWidth).PadRight($maxLine)

    Write-Host ""
    Write-Host $border -ForegroundColor Yellow
    Write-Host $centeredText -ForegroundColor Cyan
    Write-Host $border -ForegroundColor Yellow
    Write-Host ""
}

function Show-Header1Line {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )
    $maxLine = $Global:MaxLineLength
    $textForm = " $Text "
    $textLength = $textForm.Length

    if ($textLength -ge $maxLine) {
        Write-Host $textForm.Substring(0, $maxLine) -ForegroundColor DarkGray
    }
    else {
        $remaining = $maxLine - $textLength
        $leftLen = [Math]::Floor($remaining / 2)
        $rightLen = $remaining - $leftLen
        $leftPad = "-" * $leftLen
        $rightPad = "-" * $rightLen
        $output = $leftPad + $textForm + $rightPad
        Write-Host $output -ForegroundColor DarkGray
    }
    Write-Host ""
}

function Show-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [bool]$LogOnly = $false
    )
    if (-not $LogOnly) {
        Write-Host ("[INFO] {0}" -f $Message) -ForegroundColor DarkGray
    }
    if ($Global:LogFilePath) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [INFO] $Message"
        Add-Content -Path $Global:LogFilePath -Value $logLine -Encoding UTF8
    }
}

function Show-Error {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [bool]$LogOnly = $false
    )
    if (-not $LogOnly) {
        Write-Host ("[ERROR] {0}" -f $Message) -ForegroundColor Red
    }
    if ($Global:LogFilePath) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [ERROR] $Message"
        Add-Content -Path $Global:LogFilePath -Value $logLine -Encoding UTF8
    }
}

function Show-Success {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [bool]$LogOnly = $false
    )
    if (-not $LogOnly) {
        Write-Host ("[OK] {0}" -f $Message) -ForegroundColor Green
    }
    if ($Global:LogFilePath) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [OK] $Message"
        Add-Content -Path $Global:LogFilePath -Value $logLine -Encoding UTF8
    }
}

function Show-TableHeader {
    $maxLine = $Global:MaxLineLength
    $separator = "-" * $maxLine
    Write-Host $separator

    $col2 = 15
    $col3 = 15
    $col1 = $maxLine - 6 - $col2 - $col3

    $headerLine = ("{0, -$col1} | {1, -$col2} | {2, -$col3}" -f "Política", "Esperado", "Actual")
    Write-Host $headerLine -ForegroundColor Yellow
    Write-Host $separator
}

function Show-TableRow {
    param(
        [string]$PolicyName,
        [string]$ExpectedValue,
        [string]$CurrentValue
    )
    $maxLine = $Global:MaxLineLength
    $col2 = 15
    $col3 = 15
    $col1 = $maxLine - 6 - $col2 - $col3

    $rowColor = if ($ExpectedValue -eq $CurrentValue) { "Green" } else { "Red" }

    $policyChunks = $PolicyName -split "(?<=\G.{$col1})"
    $expectedChunks = $ExpectedValue -split "(?<=\G.{$col2})"
    $currentChunks = $CurrentValue -split "(?<=\G.{$col3})"

    $maxLines = [Math]::Max($policyChunks.Count, [Math]::Max($expectedChunks.Count, $currentChunks.Count))

    for ($i = 0; $i -lt $maxLines; $i++) {
        $p = if ($i -lt $policyChunks.Count) { $policyChunks[$i] }   else { "" }
        $e = if ($i -lt $expectedChunks.Count) { $expectedChunks[$i] } else { "" }
        $c = if ($i -lt $currentChunks.Count) { $currentChunks[$i] }  else { "" }
        $line = ("{0, -$col1} | {1, -$col2} | {2, -$col3}" -f $p, $e, $c)
        Write-Host $line -ForegroundColor $rowColor
    }
}
