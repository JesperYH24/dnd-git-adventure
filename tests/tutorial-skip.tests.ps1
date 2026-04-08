. "$PSScriptRoot\..\setup.ps1"

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected: $Expected, Actual: $Actual"
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Set-TestOutputStubs {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
    function global:Write-SectionTitle { param([string]$Text, [string]$Color) }
    function global:Write-EmphasisLine { param([string]$Text, [string]$Color) }
}

function Test-TutorialSkipCompletesTutorialState {
    Set-TestOutputStubs

    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    $result = Complete-TutorialAndEnterTown -Game $game -HeroHP ([ref]$heroHP) -DebugSkip $true

    Assert-Equal -Actual $result -Expected "EnterTown" -Message "Tutorial skip should send the hero to town."
    Assert-Equal -Actual $game.Quest.SeenDragon -Expected $true -Message "Tutorial skip should mark the dragon warning as seen."
    Assert-Equal -Actual $game.Quest.Completed -Expected $true -Message "Tutorial skip should complete the tutorial quest."
    Assert-Equal -Actual $game.ShadowSanctumRewardTaken -Expected $true -Message "Tutorial skip should lock in the sanctum reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 200 -Message "Tutorial skip should always grant the reduced sanctum gold reward."
    Assert-True -Condition ($null -eq $game.Hero.ActiveBuff) -Message "Tutorial skip should not grant the haste reward."
    Assert-Equal -Actual $game.Hero.Level -Expected 2 -Message "Tutorial skip should apply the tutorial level up."
    Assert-True -Condition ($heroHP -eq $game.Hero.HP) -Message "Tutorial skip should leave the hero fully rested."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $game.Hero) -Expected 11 -Message "Tutorial skip should not change Borzig's armor class."
}

Test-TutorialSkipCompletesTutorialState

Write-Host "Tutorial skip tests passed." -ForegroundColor Green
