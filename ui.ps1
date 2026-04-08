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

function Get-FastTextEnabled {
    if ($null -eq $global:FastTextEnabled) {
        $global:FastTextEnabled = $false
    }

    return [bool]$global:FastTextEnabled
}

function Set-FastTextEnabled {
    param([bool]$Enabled)

    $global:FastTextEnabled = $Enabled
}

function Get-TextSpeedLabel {
    if (Get-FastTextEnabled) {
        return "Fast"
    }

    return "Normal"
}

function Toggle-TextSpeed {
    $newValue = -not (Get-FastTextEnabled)
    Set-FastTextEnabled -Enabled $newValue
    Write-ColorLine "Text speed: $(Get-TextSpeedLabel)" "DarkYellow"
    Write-ColorLine ""
    return $newValue
}

function Write-TextSpeedOption {
    Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
}

function Get-TypewriterInputAction {
    try {
        if (-not [Console]::KeyAvailable) {
            return ""
        }

        $key = [Console]::ReadKey($true)

        if ($key.Key -eq [ConsoleKey]::Enter) {
            return "SkipBlock"
        }

        if ($key.Key -eq [ConsoleKey]::Spacebar -or $key.Key -eq [ConsoleKey]::S) {
            Set-FastTextEnabled -Enabled (-not (Get-FastTextEnabled))
            return "ToggleFastText"
        }
    }
    catch {
        return ""
    }

    return ""
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

    if (Get-FastTextEnabled) {
        Write-Host $Text -ForegroundColor $Color
        return ""
    }

    $characters = $Text.ToCharArray()

    for ($i = 0; $i -lt $characters.Length; $i++) {
        Write-Host -NoNewline $characters[$i] -ForegroundColor $Color

        $action = Get-TypewriterInputAction

        if ($action -eq "SkipBlock" -or $action -eq "ToggleFastText") {
            if ($i -lt ($characters.Length - 1)) {
                Write-Host -NoNewline (-join $characters[($i + 1)..($characters.Length - 1)]) -ForegroundColor $Color
            }

            break
        }

        $remainingDelay = [Math]::Max(0, $Delay)

        while ($remainingDelay -gt 0) {
            $sleepSlice = [Math]::Min(10, $remainingDelay)
            Start-Sleep -Milliseconds $sleepSlice
            $remainingDelay -= $sleepSlice

            $action = Get-TypewriterInputAction

            if ($action -eq "SkipBlock" -or $action -eq "ToggleFastText") {
                if ($i -lt ($characters.Length - 1)) {
                    Write-Host -NoNewline (-join $characters[($i + 1)..($characters.Length - 1)]) -ForegroundColor $Color
                }

                $remainingDelay = 0
                break
            }
        }
    }

    Write-Host ""
    return $action
}

function Write-TypeBlock {
    param(
        [string[]]$Lines,
        [int]$Delay,
        [string]$Color
    )

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $action = Write-TypeLine -Text $Lines[$i] -Delay $Delay -Color $Color

        if ($action -eq "SkipBlock") {
            for ($remainingIndex = $i + 1; $remainingIndex -lt $Lines.Count; $remainingIndex++) {
                Write-Host $Lines[$remainingIndex] -ForegroundColor $Color
            }

            return
        }
    }
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

    $lines = @(Split-DisplayText -Text $Text | ForEach-Object { "  " + $_ })
    Write-TypeBlock -Lines $lines -Delay 35 -Color "Gray"
}

function Write-Action {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    $lines = @(Split-DisplayText -Text $Text | ForEach-Object { "  " + $_ })
    Write-TypeBlock -Lines $lines -Delay 16 -Color $Color
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
