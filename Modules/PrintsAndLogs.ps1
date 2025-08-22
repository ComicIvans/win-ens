###############################################################################
# PrintsAndLogs.ps1
# Print, log, and global info saving functions
###############################################################################

# Maximum length of lines to print in the console
try {
    $Global:MaxLineLength = [Math]::Max((Get-Host).UI.RawUI.WindowSize.Width - 1, 80)
}
catch {
    $Global:MaxLineLength = 119
}
$Global:ExpectedColWidth = [Math]::Ceiling($Global:MaxLineLength / 8)
$Global:CurrentColWidth = [Math]::Ceiling($Global:MaxLineLength / 8)

# Print a header of three lines with a centered text
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

# Print a header of one line with a centered text
function Show-Header1Line {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )
    $maxLine = $Global:MaxLineLength
    $textForm = " $Text "
    $textLength = $textForm.Length

    Write-Host ""
    if ($textLength -ge $maxLine) {
        Write-Host $textForm.Substring(0, $maxLine) -ForegroundColor Cyan
    }
    else {
        $remaining = $maxLine - $textLength
        $leftLen = [Math]::Floor($remaining / 2)
        $rightLen = $remaining - $leftLen
        $leftPad = "-" * $leftLen
        $rightPad = "-" * $rightLen
        $output = $leftPad + $textForm + $rightPad
        Write-Host $output -ForegroundColor Cyan
    }
    Write-Host ""
}

# Log and/or print an informational message
function Show-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [switch]$NoConsole,
        [Parameter()]
        [switch]$NoLog
    )
    if (-not $NoConsole) {
        Write-Host ("[INFO] {0}" -f $Message) -ForegroundColor DarkGray
    }
    if (-not $NoLog) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [INFO] $Message"
        $Global:LogWriter.WriteLine($logLine)
    }
}

# Log and/or print a warning message
function Show-Warning {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [switch]$NoConsole,
        [Parameter()]
        [switch]$NoLog
    )
    if (-not $NoConsole) {
        Write-Host ("[WARNING] {0}" -f $Message) -ForegroundColor Yellow
    }
    if (-not $NoLog) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [WARNING] $Message"
        $Global:LogWriter.WriteLine($logLine)
    }
}

# Log and/or print an error message
function Show-Error {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [switch]$NoConsole,
        [Parameter()]
        [switch]$NoLog
    )
    if (-not $NoConsole) {
        Write-Host ("[ERROR] {0}" -f $Message) -ForegroundColor Red
    }
    if (-not $NoLog) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [ERROR] $Message"
        $Global:LogWriter.WriteLine($logLine)
    }
}

# Log and/or print a success message
function Show-Success {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [switch]$NoConsole,
        [Parameter()]
        [switch]$NoLog
    )
    if (-not $NoConsole) {
        Write-Host ("[OK] {0}" -f $Message) -ForegroundColor Green
    }
    if (-not $NoLog) {
        $timestamp = (Get-Date).ToString("HH:mm:ss")
        $logLine = "[$timestamp] [OK] $Message"
        $Global:LogWriter.WriteLine($logLine)
    }
}

# Print a table header for displaying policy testing information
function Show-TableHeader {
    $separator = "-" * $Global:MaxLineLength
    Write-Host $separator

    $col2 = $Global:ExpectedColWidth
    $col3 = $Global:CurrentColWidth
    $col1 = $Global:MaxLineLength - 6 - $col2 - $col3

    $headerLine = ("{0, -$col1} | {1, -$col2} | {2, -$col3}" -f "Política", "Esperado", "Actual")
    Write-Host $headerLine -ForegroundColor Yellow
    Write-Host $separator
}

# Print a row in the policy testing information table
function Show-TableRow {
    param(
        [string]$PolicyName,
        [string]$ExpectedValue,
        [string]$CurrentValue,
        [switch]$ValidValue
    )
    $col2 = $Global:ExpectedColWidth
    $col3 = $Global:CurrentColWidth
    $col1 = $Global:MaxLineLength - 6 - $col2 - $col3

    $rowColor = if ($ValidValue -or $ExpectedValue -eq $CurrentValue) { "Green" } else { "Red" }

    if (-not $ExpectedValue) {
        $ExpectedValue = "N/A"
    }
    elseif ($ExpectedValue -is [System.Array]) {
        $ExpectedValue = $ExpectedValue -join ", "
    }
    if (-not $CurrentValue) {
        $CurrentValue = "N/A"
    }
    elseif ($CurrentValue -is [System.Array]) {
        $CurrentValue = $CurrentValue -join ", "
    }

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

    $spacer = ("{0, -$col1} | {1, -$col2} | {2, -$col3}" -f "", "", "")
    Write-Host $spacer -ForegroundColor $rowColor

    if ($Global:Config.SaveResultsAsCSV) {
        # Escape double quotes and wrap each field in quotes
        $csvP = '"' + ($PolicyName -replace '"', '""') + '"'
        $csvE = '"' + ($ExpectedValue -replace '"', '""') + '"'
        $csvC = '"' + ($CurrentValue -replace '"', '""') + '"'
        $csvV = if ($rowColor -eq "Green") { $true } else { $false }
        $Global:ResultsWriter.WriteLine("$($GroupInfo.Name),$($PolicyInfo.Name),$csvP,$csvE,$csvC,$csvV")
    }
}
