. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-TestReadHostSequence {
    param([string[]]$Values)

    $script:ReadHostSequence = @($Values)
    $script:ReadHostIndex = 0

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:ReadHostIndex -ge $script:ReadHostSequence.Count) {
            throw "Read-Host was called more times than the test expected."
        }

        $value = $script:ReadHostSequence[$script:ReadHostIndex]
        $script:ReadHostIndex += 1
        return $value
    }
}

function Test-TownMainMenuUsesSubmenus {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    Set-TestReadHostSequence -Values @("2", "0", "3", "0", "5", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "EndGame" -Message "The town menu should still exit normally after entering and leaving its core submenus."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 7 -Message "The town main menu should route through shops, work, and character submenus without extra prompts."
}

function Test-TownHeroHudShowsNameHpAndCoin {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.CurrencyCopper = 234

    $hud = Get-TownHeroHudText -Game $game -HeroHP 7

    Assert-True -Condition ($hud -like "*Gariand*") -Message "The compact town HUD should always show the current hero name."
    Assert-True -Condition ($hud -like "*HP 7/$($game.Hero.HP)*") -Message "The compact town HUD should show current and max HP when current HP is provided."
    Assert-True -Condition ($hud -like "*Coin*2 GP*3 SP*4 CP*") -Message "The compact town HUD should show the hero's current coin."
}

function Test-DocksDistrictUnlocksAfterLadyVeyraReveal {
    $game = Initialize-Game

    Assert-Equal -Actual (Test-DocksDistrictUnlocked -Game $game) -Expected $false -Message "The docks district should stay locked before Lady Veyra is revealed."

    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Test-DocksDistrictUnlocked -Game $game) -Expected $true -Message "The docks district should unlock once Lady Veyra's identity becomes part of the story."
}

Test-TownMainMenuUsesSubmenus
Test-TownHeroHudShowsNameHpAndCoin
Test-DocksDistrictUnlocksAfterLadyVeyraReveal

Write-Host "Town menu tests passed." -ForegroundColor Green
