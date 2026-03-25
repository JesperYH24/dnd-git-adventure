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

function Write-Scene {
    param(
        [string]$Text
    )

    Write-TypeLine -Text $Text -Delay 35 -Color "DarkMagenta"
}

function Write-Action {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    Write-TypeLine -Text $Text -Delay 10 -Color $Color
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