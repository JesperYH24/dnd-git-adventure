function Get-ReadableTextWidth {
    $defaultWidth = 88

    try {
        $windowWidth = $Host.UI.RawUI.WindowSize.Width

        if ($windowWidth -gt 0) {
            return [Math]::Max(40, [Math]::Min(88, $windowWidth - 8))
        }
    }
    catch {
    }

    return $defaultWidth
}

function Split-DisplayText {
    param(
        [string]$Text,
        [int]$Width = 0
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @("")
    }

    if ($Width -le 0) {
        $Width = Get-ReadableTextWidth
    }

    $words = $Text -split '\s+'
    $lines = @()
    $currentLine = ""

    foreach ($word in $words) {
        if ([string]::IsNullOrEmpty($currentLine)) {
            $currentLine = $word
            continue
        }

        $candidate = "$currentLine $word"

        if ($candidate.Length -le $Width) {
            $currentLine = $candidate
        }
        else {
            $lines += $currentLine
            $currentLine = $word
        }
    }

    if (-not [string]::IsNullOrEmpty($currentLine)) {
        $lines += $currentLine
    }

    return $lines
}

function Write-TypeLine {
    param(
        [string]$Text,
        [int]$Delay = 20,
        [string]$Color = "White"
    )

    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline $char -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }

    Write-Host ""
}

function Write-SectionTitle {
    param(
        [string]$Text,
        [string]$Color = "Cyan"
    )

    $title = "  $($Text.ToUpper())  "
    $borderWidth = [Math]::Max($title.Length, 26)
    $border = "".PadLeft($borderWidth, "=")

    Write-ColorLine "" $Color
    Write-ColorLine $border $Color
    Write-ColorLine $title $Color
    Write-ColorLine $border $Color
}

function Write-EmphasisLine {
    param(
        [string]$Text,
        [string]$Color = "Yellow"
    )

    foreach ($line in Split-DisplayText -Text $Text) {
        Write-Host ("  " + $line) -ForegroundColor $Color
    }
}

function Write-Scene {
    param(
        [string]$Text
    )

    foreach ($line in Split-DisplayText -Text $Text) {
        Write-TypeLine -Text ("  " + $line) -Delay 35 -Color "DarkMagenta"
    }
}

function Write-Action {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    foreach ($line in Split-DisplayText -Text $Text) {
        Write-TypeLine -Text ("  " + $line) -Delay 16 -Color $Color
    }
}

function Write-ColorLine {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    Write-Host $Text -ForegroundColor $Color
}

function Write-BlinkingLine {
    param(
        [string]$Text,
        [string]$Color1 = "Red",
        [string]$Color2 = "DarkRed",
        [int]$Times = 3
    )

    for ($i = 0; $i -lt $Times; $i++) {
        Write-Host "`r$Text" -ForegroundColor $Color1 -NoNewline
        Start-Sleep -Milliseconds 150

        Write-Host "`r$Text" -ForegroundColor $Color2 -NoNewline
        Start-Sleep -Milliseconds 150
    }

    Write-Host "`r$Text" -ForegroundColor $Color1
}
