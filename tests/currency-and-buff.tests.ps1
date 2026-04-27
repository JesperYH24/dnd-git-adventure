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
    $global:RollDiceOverride = $null
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
    function global:Write-SectionTitle { param([string]$Text, [string]$Color) }
    function global:Write-EmphasisLine { param([string]$Text, [string]$Color) }
}

function Test-GoldPouchCapsAtOneHundredFiftyGP {
    $hero = Get-Hero

    $firstAdd = Add-HeroCurrency -Hero $hero -Denomination "GP" -Amount 150
    $secondAdd = Add-HeroCurrency -Hero $hero -Denomination "GP" -Amount 5

    Assert-Equal -Actual $firstAdd.StoredCopper -Expected 15000 -Message "The gold pouch should hold 150 GP."
    Assert-Equal -Actual $secondAdd.StoredCopper -Expected 0 -Message "The pouch should be full after 150 GP."
    Assert-Equal -Actual $secondAdd.LeftoverCopper -Expected 500 -Message "Extra GP should be left over when the pouch is full."
    Assert-Equal -Actual $hero.CurrencyCopper -Expected 15000 -Message "Stored currency should stay capped at 150 GP."
}

function Test-HasteBuffGrantsInitiativeAdvantage {
    Set-TestOutputStubs

    $hero = Get-Hero
    Apply-HeroBuff -Hero $hero -BuffType "Haste" -BuffName "Potion of Haste"
    $monster = @{
        definite = "The Test Monster"
        initiativeBonus = 0
    }

    $script:rollIndex = 0
    $global:RollDiceOverride = {
        param([int]$Sides = 20)

        $script:rollIndex += 1
        switch ($script:rollIndex) {
            1 { return 4 }
            2 { return 15 }
            3 { return 14 }
            default { return 1 }
        }
    }

    $heroStarts = $false
    $monsterStarts = $false

    Start-DetectionPhase `
        -Hero $hero `
        -Monster $monster `
        -HeroStarts ([ref]$heroStarts) `
        -MonsterStarts ([ref]$monsterStarts)

    Assert-Equal -Actual $heroStarts -Expected $true -Message "Haste should let the hero take the better initiative roll."
    Assert-Equal -Actual $monsterStarts -Expected $false -Message "The monster should not start if haste lets the hero win initiative."
    $global:RollDiceOverride = $null
}

function Test-ShadowSanctumGoldRollOverflowStaysInRoom {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)

        return ""
    }

    $global:RollDiceOverride = {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 20 }
        return 1
    }

    $game = Initialize-Game
    $game.Hero.CurrencyCopper = 14900

    Resolve-ShadowSanctumReward -Game $game

    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 15000 -Message "The gold pouch should only fill to its capacity."
    Assert-Equal -Actual $game.Rooms["ashen_threshold"].Loot.Count -Expected 1 -Message "Overflowing sanctum gold should remain in the cave as loot."
    Assert-Equal -Actual $game.Rooms["ashen_threshold"].Loot[0].Type -Expected "Currency" -Message "The leftover sanctum reward should still be currency."
    Assert-Equal -Actual $game.Rooms["ashen_threshold"].Loot[0].Denomination -Expected "GP" -Message "The leftover sanctum reward should keep its gold denomination."
    Assert-Equal -Actual $game.Rooms["ashen_threshold"].Loot[0].Amount -Expected 5 -Message "A natural 20 should be capped at a non-breaking 6 GP reward."
    $global:RollDiceOverride = $null
}

function Test-ShadowSanctumGoldRewardTableCapsNaturalTwenty {
    Assert-Equal -Actual (Get-ShadowSanctumGoldRewardGP -Roll 1) -Expected 1 -Message "A low sanctum gold roll should still grant a small reward."
    Assert-Equal -Actual (Get-ShadowSanctumGoldRewardGP -Roll 10) -Expected 3 -Message "A middling sanctum gold roll should grant a modest reward."
    Assert-Equal -Actual (Get-ShadowSanctumGoldRewardGP -Roll 20) -Expected 6 -Message "A natural 20 should feel good without breaking the early economy."
}

Test-GoldPouchCapsAtOneHundredFiftyGP
Test-HasteBuffGrantsInitiativeAdvantage
Test-ShadowSanctumGoldRollOverflowStaysInRoom
Test-ShadowSanctumGoldRewardTableCapsNaturalTwenty

Write-Host "Currency and buff tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
if (Test-Path Function:\global:Roll-Dice) {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}
