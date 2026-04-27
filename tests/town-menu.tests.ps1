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
    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $false -Message "The docks should not be open from the town menu before the docks story chain is solved."

    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Test-DocksDistrictUnlocked -Game $game) -Expected $true -Message "The docks district should unlock once Lady Veyra's identity becomes part of the story."
    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $false -Message "The Veyra reveal should unlock the docks lead, not the open town district."
}

function Test-DocksDistrictFirstVisitDiscoversOddityShop {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopDiscovered -Game $game) -Expected $true -Message "The first docks visit should discover Auntie Brindle's shop before other dock leads expand."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 1 -Message "The docks district menu should allow the player to back out cleanly after the first discovery."
}

function Test-DocksDistrictRequiresOddityShopBeforeTallyShack {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("2", "0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopDiscovered -Game $game) -Expected $true -Message "Entering the docks should still discover Auntie Brindle first."
    Assert-Equal -Actual (Test-DocksOddityShopVisited -Game $game) -Expected $false -Message "Trying to skip ahead should not count as visiting the oddity shop."
    Assert-Equal -Actual (Test-DocksTallyShackDiscovered -Game $game) -Expected $false -Message "The tide-ledger shack should stay locked until Auntie Brindle has been visited."
}

function Test-DocksDistrictOddityShopUnlocksTallyShackLead {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("1", "0", "2", "0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopVisited -Game $game) -Expected $true -Message "Visiting Auntie Brindle should mark the first docks step complete."
    Assert-Equal -Actual (Test-DocksTallyShackDiscovered -Game $game) -Expected $true -Message "Asking Auntie about the clue should unlock the tide-ledger shack."
}

function Test-DocksDistrictOpensFromTownAfterBlackContractChain {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["DocksOddityShopDiscovered"] = $true
    $game.Town.StoryFlags["DocksOddityShopVisited"] = $true
    $game.Town.StoryFlags["DocksTallyShackDiscovered"] = $true
    $game.Town.StoryFlags["NamedVeyraContractBroker"] = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    Set-TestReadHostSequence -Values @("6", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $true -Message "Completing the first docks chain should open the docks as a town district."
    Assert-Equal -Actual ([bool]$game.Town.StoryFlags["HigherPatronSuspected"]) -Expected $false -Message "Opening the docks should not require discovering the higher patron yet."
    Assert-Equal -Actual $result -Expected "EndGame" -Message "The player should be able to visit the open docks district from town and return."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 3 -Message "The town menu should route into the opened docks district without extra prompts."
}

Test-TownMainMenuUsesSubmenus
Test-TownHeroHudShowsNameHpAndCoin
Test-DocksDistrictUnlocksAfterLadyVeyraReveal
Test-DocksDistrictFirstVisitDiscoversOddityShop
Test-DocksDistrictRequiresOddityShopBeforeTallyShack
Test-DocksDistrictOddityShopUnlocksTallyShackLead
Test-DocksDistrictOpensFromTownAfterBlackContractChain

Write-Host "Town menu tests passed." -ForegroundColor Green
